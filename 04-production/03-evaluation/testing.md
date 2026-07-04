# Evaluation & Testing

> Agents are non-deterministic. Traditional unit tests aren't enough. You need a new approach.

---

## Why Agent Testing is Hard

1. **Non-deterministic**: Same input, different outputs
2. **No ground truth**: What's the "correct" agent behavior?
3. **Multi-step**: Failures can happen at any step
4. **External dependencies**: Tools, APIs can fail
5. **Subjective quality**: What's a "good" response?

---

## Evaluation Dimensions

Evaluate agents across these dimensions:

| Dimension | What to Measure | How |
|-----------|----------------|-----|
| **Correctness** | Did it do the right thing? | LLM-as-a-Judge |
| **Latency** | How fast? | p50, p95, p99 |
| **Cost** | How expensive? | Tokens × price |
| **Safety** | Did it do anything harmful? | Guardrails, content filters |
| **Completeness** | Did it finish the task? | Task-specific checks |

---

## LLM-as-a-Judge

Use an LLM to evaluate agent outputs.

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o")

def evaluate_response(query: str, response: str, criteria: str) -> dict:
    """Evaluate agent response using LLM."""
    prompt = f"""You are an expert evaluator. Evaluate this agent response.
    
    Query: {query}
    Response: {response}
    
    Evaluation Criteria: {criteria}
    
    Score from 1-5 and explain why.
    Format: SCORE: X\nREASON: ..."""
    
    result = llm.invoke(prompt)
    
    # Parse score
    content = result.content
    score_line = [l for l in content.split("\n") if l.startswith("SCORE:")][0]
    score = int(score_line.replace("SCORE:", "").strip())
    
    return {"score": score, "reasoning": content}

# Usage
eval_result = evaluate_response(
    query="What's India's population?",
    response="India's population is approximately 1.45 billion.",
    criteria="Accuracy and completeness",
)
print(f"Score: {eval_result['score']}/5")
```

## Evaluation Harness

```python
# tests/eval_harness.py
import pytest
import json
from src.agent import run_agent
from src.eval import evaluate_response

# Test cases
test_cases = [
    {
        "query": "What is 25 * 48?",
        "expected_contains": "1200",
        "criteria": "Mathematical accuracy",
    },
    {
        "query": "Search for Python async tutorials",
        "expected_tool": "search_web",
        "criteria": "Uses correct tool",
    },
    {
        "query": "Explain quantum computing simply",
        "min_length": 100,
        "criteria": "Completeness and clarity",
    },
]

@pytest.mark.parametrize("test_case", test_cases)
def test_agent(test_case):
    # Run agent
    result = run_agent(test_case["query"])
    
    # Check correctness
    if "expected_contains" in test_case:
        assert test_case["expected_contains"] in result["response"]
    
    if "expected_tool" in test_case:
        assert any(
            t["name"] == test_case["expected_tool"]
            for t in result["tool_calls"]
        )
    
    if "min_length" in test_case:
        assert len(result["response"]) >= test_case["min_length"]
    
    # LLM evaluation
    eval_result = evaluate_response(
        test_case["query"],
        result["response"],
        test_case["criteria"],
    )
    
    assert eval_result["score"] >= 4, f"Low score: {eval_result['reasoning']}"
```

## Regression Testing

Prevent quality degradation over time:

```python
# tests/regression_test.py
import json
from src.agent import run_agent

def test_regression():
    """Run golden set and compare scores."""
    
    # Load golden set
    with open("tests/golden_set.json") as f:
        golden_set = json.load(f)
    
    scores = []
    for case in golden_set:
        result = run_agent(case["query"])
        score = evaluate_response(case["query"], result["response"], case["criteria"])
        scores.append(score["score"])
    
    avg_score = sum(scores) / len(scores)
    
    # Compare with baseline
    with open("tests/baseline_score.txt") as f:
        baseline = float(f.read().strip())
    
    assert avg_score >= baseline - 0.5, f"Regression detected: {avg_score} < {baseline}"
```

## A/B Testing

Test new agent versions against the current one:

```python
import random

def run_with_ab_test(query: str):
    """Route to A or B version."""
    if random.random() < 0.1:  # 10% to B
        result = agent_v2.run(query)
        result["version"] = "B"
    else:
        result = agent_v1.run(query)
        result["version"] = "A"
    
    # Log version in LangSmith/Langfuse
    return result
```

## CI Integration

```yaml
# .github/workflows/eval.yml
name: Evaluation

on: [push]

jobs:
  eval:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt
      - run: pytest tests/eval_harness.py -v
      - run: pytest tests/regression_test.py -v
```

## Key Takeaways

1. **LLM-as-a-Judge is essential**: Automate quality evaluation
2. **Golden sets**: Maintain a set of test cases that represent your use case
3. **Regression tests**: Catch quality drops before they reach production
4. **A/B testing**: Validate improvements with real traffic
5. **Track over time**: Quality metrics should trend up, not down
