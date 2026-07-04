# Cost Optimization

> Agent costs can spiral. Control them from day one.

---

## Understanding LLM Pricing

Pricing is per-token (input + output). Models vary 100x in cost.

| Model | Input (per 1M) | Output (per 1M) | Relative Cost |
|-------|---------------|-----------------|---------------|
| GPT-4o | $5.00 | $15.00 | 10x |
| Claude Sonnet | $3.00 | $15.00 | 8x |
| GPT-4o-mini | $0.15 | $0.60 | 1x |
| Gemini 2.5 Flash | $0.075 | $0.30 | 0.5x |
| Claude Haiku | $0.25 | $1.25 | 1x |

**India-specific**: Gemini API is the cheapest for Indian users. Use it for prototyping.

---

## Cost Estimation

```python
def estimate_cost(input_tokens: int, output_tokens: int, model: str) -> float:
    """Estimate cost in USD for a request."""
    pricing = {
        "gpt-4o": {"input": 5, "output": 15},
        "gpt-4o-mini": {"input": 0.15, "output": 0.60},
        "claude-sonnet": {"input": 3, "output": 15},
        "gemini-flash": {"input": 0.075, "output": 0.30},
    }
    
    p = pricing.get(model, pricing["gpt-4o-mini"])
    input_cost = (input_tokens / 1_000_000) * p["input"]
    output_cost = (output_tokens / 1_000_000) * p["output"]
    
    return input_cost + output_cost

# Example: A typical agent run
# Input: 2000 tokens (prompt + context)
# Output: 500 tokens (response)
# Model: GPT-4o

print(f"Cost per run: ${estimate_cost(2000, 500, 'gpt-4o'):.4f}")
# ~$0.0175 per run

# At 1000 runs/day
print(f"Daily cost: ${estimate_cost(2000, 500, 'gpt-4o') * 1000:.2f}")
# ~$17.50/day = ~$525/month
```

---

## Model Routing

Route simple queries to cheap models, complex ones to expensive models.

```python
class ModelRouter:
    """Route requests to appropriate model based on complexity."""
    
    MODELS = {
        "cheap": "gemini-2.5-flash",      # Simple tasks
        "medium": "gpt-4o-mini",           # Standard tasks
        "expensive": "gpt-4o",             # Complex tasks
        "vision": "claude-sonnet",         # Vision tasks
    }
    
    def classify_complexity(self, query: str) -> str:
        """Classify query complexity."""
        # Simple heuristics
        if len(query) < 50 and "?" not in query:
            return "cheap"  # Simple greeting/ack
        
        complex_indicators = [
            "analyze", "compare", "research", "evaluate",
            "detailed", "comprehensive", "multi-step",
        ]
        if any(indicator in query.lower() for indicator in complex_indicators):
            return "expensive"
        
        return "medium"
    
    def route(self, query: str) -> str:
        """Get the right model for the query."""
        complexity = self.classify_complexity(query)
        return self.MODELS[complexity]

# Usage
router = ModelRouter()
model = router.route("Explain quantum computing in detail")
# Returns: "gpt-4o" (complex query)

model = router.route("Hi there!")
# Returns: "gemini-2.5-flash" (simple greeting)
```

---

## Token Optimization

```python
def optimize_prompt(prompt: str, max_tokens: int = 2000) -> str:
    """Optimize prompt to reduce token usage."""
    
    # Remove unnecessary whitespace
    prompt = " ".join(prompt.split())
    
    # Summarize long context
    if len(prompt) > max_tokens * 4:  # Rough chars-to-tokens
        prompt = summarize_context(prompt, max_tokens)
    
    return prompt

def summarize_context(context: str, max_tokens: int) -> str:
    """Summarize long context to fit within token limit."""
    # Use a cheap model to summarize
    summary = cheap_llm.invoke(
        f"Summarize this context in {max_tokens} tokens:\n\n{context}"
    )
    return summary.content
```

---

## Caching

Cache repeated queries to avoid redundant LLM calls:

```python
import hashlib
from functools import lru_cache
import redis

redis_client = redis.Redis(host='localhost', port=6379)

def cache_key(query: str) -> str:
    return f"agent:cache:{hashlib.md5(query.encode()).hexdigest()}"

def get_cached(query: str, ttl: int = 3600):
    key = cache_key(query)
    cached = redis_client.get(key)
    if cached:
        return json.loads(cached)
    return None

def set_cache(query: str, result: dict, ttl: int = 3600):
    key = cache_key(query)
    redis_client.setex(key, ttl, json.dumps(result))
```

---

## Budget Enforcement

```python
class BudgetEnforcer:
    """Enforce spending limits."""
    
    def __init__(self, daily_budget_usd: float):
        self.daily_budget = daily_budget_usd
        self.spent_today = 0
        self.last_reset = datetime.now().date()
    
    def can_spend(self, estimated_cost: float) -> bool:
        # Reset at midnight
        if datetime.now().date() != self.last_reset:
            self.spent_today = 0
            self.last_reset = datetime.now().date()
        
        return (self.spent_today + estimated_cost) <= self.daily_budget
    
    def record_spend(self, cost: float):
        self.spent_today += cost
    
    def get_status(self) -> dict:
        return {
            "daily_budget": self.daily_budget,
            "spent_today": self.spent_today,
            "remaining": self.daily_budget - self.spent_today,
            "utilization": self.spent_today / self.daily_budget * 100,
        }

# Usage
budget = BudgetEnforcer(daily_budget_usd=50)  # $50/day

if not budget.can_spend(estimated_cost):
    return "Budget limit reached. Try again tomorrow."
```

---

## India-Specific Cost Tips

1. **Use Gemini for prototyping**: Cheapest API for Indian users
2. **Bedrock for production**: Bulk pricing on AWS
3. **Vertex AI on GCP**: Good pricing for Gemini models
4. **Avoid GPT-4o for simple tasks**: 10x more expensive than mini
5. **Cache aggressively**: Reduce redundant calls
6. **Monitor daily**: Set up cost alerts

## Monthly Cost Calculator

```python
def calculate_monthly_cost(
    requests_per_day: int,
    avg_input_tokens: int,
    avg_output_tokens: int,
    model: str,
) -> dict:
    """Calculate estimated monthly cost."""
    cost_per_request = estimate_cost(avg_input_tokens, avg_output_tokens, model)
    daily_cost = cost_per_request * requests_per_day
    monthly_cost = daily_cost * 30
    
    # Convert to INR (approximate)
    monthly_inr = monthly_cost * 83
    
    return {
        "cost_per_request_usd": cost_per_request,
        "daily_cost_usd": daily_cost,
        "monthly_cost_usd": monthly_cost,
        "monthly_cost_inr": monthly_inr,
    }

# Example: 1000 requests/day on GPT-4o-mini
costs = calculate_monthly_cost(1000, 2000, 500, "gpt-4o-mini")
print(f"Monthly cost: ${costs['monthly_cost_usd']:.2f} (₹{costs['monthly_cost_inr']:.0f})")
# ~$135/month (₹11,200)
```
