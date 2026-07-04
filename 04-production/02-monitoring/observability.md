# Observability for Agents

> You can't improve what you can't see. Agent observability is non-negotiable in production.

---

## The Problem

LLMs are black boxes. Agents compound this by making the black box multi-step, non-deterministic, and stateful. Without observability, debugging is impossible.

```
User: "Why did my agent spend $5 on this request?"
You without observability: "...I don't know"
You with observability: "It looped 12 times because the search tool returned empty results"
```

---

## LangSmith (Recommended)

Official observability platform from LangChain.

### Setup

```python
import os
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_API_KEY"] = "ls-..."
os.environ["LANGCHAIN_PROJECT"] = "agentic-ai-playbook"

# Automatic tracing with LangGraph
from langgraph.graph import StateGraph

# All graph runs are automatically traced
graph = workflow.compile()
result = graph.invoke(state)  # Appears in LangSmith dashboard
```

### Custom Tracing

```python
from langsmith import traceable

@traceable(run_type="tool", name="web_search")
def search_web(query: str) -> str:
    """This function call will appear as a span in LangSmith."""
    # ... implementation
    return results

@traceable(run_type="llm", name="planning")
def plan_task(task: str) -> list:
    """LLM calls are traced with token usage."""
    response = llm.invoke(task)
    return response
```

### Dashboard

The LangSmith dashboard shows:
- **Traces**: End-to-end agent runs
- **Spans**: Individual steps (tool calls, LLM calls)
- **Latency**: Per-step timing
- **Token usage**: Input/output tokens per call
- **Cost**: Estimated cost per run
- **Feedback**: Human ratings on outputs

---

## Langfuse (Open Source Alternative)

Self-hosted, data stays with you.

### Setup

```python
from langfuse import Langfuse

langfuse = Langfuse(
    public_key="pk-...",
    secret_key="sk-...",
    host="http://localhost:3000",  # Self-hosted
)

# Create a trace
trace = langfuse.trace(
    name="customer_support",
    user_id="user_123",
    metadata={"channel": "slack"},
)

# Add spans
span = trace.span(
    name="intent_classification",
    input={"query": "Where's my order?"},
    output={"intent": "order_status"},
)
span.end()

# Add LLM generation
generation = trace.generation(
    name="response_generation",
    model="gpt-4o",
    input=prompt,
    output=response,
    usage={"input": 100, "output": 50, "total": 150},
)
```

### Self-Host with Docker

```yaml
# docker-compose.yml
version: '3'
services:
  langfuse:
    image: langfuse/langfuse:latest
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/langfuse
      - NEXTAUTH_SECRET=your-secret
      - SALT=your-salt
      - ENCRYPTION_KEY=your-key
```

---

## Key Metrics to Track

| Metric | Why It Matters | Alert Threshold |
|--------|---------------|----------------|
| **Request latency** | User experience | p95 > 30s |
| **Token usage** | Cost control | Per request > 10K tokens |
| **Cost per request** | Budget | Per request > $0.50 |
| **Error rate** | Reliability | > 5% errors |
| **Tool failure rate** | Tool health | > 10% failures |
| **Loop count** | Efficiency | > 5 iterations |
| **Human escalation rate** | Agent capability | > 20% escalations |

---

## Structured Logging

```python
import logging
import structlog

structlog.configure(
    processors=[
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ]
)

logger = structlog.get_logger()

def run_agent(query: str):
    correlation_id = str(uuid.uuid4())
    
    logger.info(
        "agent_run_started",
        correlation_id=correlation_id,
        query=query,
    )
    
    try:
        result = agent.run(query)
        logger.info(
            "agent_run_completed",
            correlation_id=correlation_id,
            iterations=result.iterations,
            cost=result.cost,
            latency_ms=result.latency,
        )
        return result
    except Exception as e:
        logger.error(
            "agent_run_failed",
            correlation_id=correlation_id,
            error=str(e),
            error_type=type(e).__name__,
        )
        raise
```

## Alerting Rules

```yaml
# alerts.yml
groups:
  - name: agent_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(agent_errors_total[5m]) > 0.05
        for: 5m
        annotations:
          summary: "Agent error rate is high"
          
      - alert: HighLatency
        expr: histogram_quantile(0.95, agent_latency_seconds) > 30
        for: 5m
        annotations:
          summary: "Agent p95 latency exceeds 30s"
          
      - alert: CostSpike
        expr: increase(agent_cost_dollars[1h]) > 50
        annotations:
          summary: "Agent cost exceeded $50 in last hour"
```

## Grafana Dashboard

Create dashboards for:
1. **Overview**: Request rate, latency, error rate
2. **Cost**: Daily spend, per-request cost, model breakdown
3. **Agent Health**: Tool success rates, loop counts, escalation rate
4. **LLM Performance**: Token usage, model distribution

---

## Best Practices

1. **Trace every run**: No exceptions. You will need it for debugging.
2. **Add correlation IDs**: Link logs, traces, and metrics together.
3. **Track costs per request**: Know which requests are expensive.
4. **Set up alerts**: Catch issues before users complain.
5. **Review traces weekly**: Patterns in failures reveal improvement areas.
6. **Human feedback**: Let users rate agent outputs. Track quality over time.
