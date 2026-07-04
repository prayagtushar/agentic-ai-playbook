# Scaling Agent Systems

> As your agent system grows, you'll hit bottlenecks. Here's how to handle them.

---

## Common Bottlenecks

| Bottleneck | Symptom | Solution |
|-----------|---------|----------|
| LLM latency | Slow responses | Async, model routing, caching |
| Tool latency | Hanging tool calls | Timeouts, async, fallbacks |
| Context window | Token limit errors | Summarization, chunking |
| Rate limits | 429 errors | Backoff, request queuing |
| Memory | OOM crashes | Checkpoint cleanup, streaming |
| Cost | Budget overrun | Model routing, caching |

---

## Async Execution

```python
import asyncio
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(model="gpt-4o")

async def run_tool(tool, params):
    """Run a tool asynchronously."""
    return await tool.arun(params)

async def parallel_tools(tools_with_params):
    """Run multiple tools in parallel."""
    tasks = [
        run_tool(tool, params)
        for tool, params in tools_with_params
    ]
    results = await asyncio.gather(*tasks, return_exceptions=True)
    return results

# Usage
results = await parallel_tools([
    (search_tool, "AI agents"),
    (search_tool, "LLM frameworks"),
    (search_tool, "agent patterns"),
])
```

## Caching

```python
import hashlib
from functools import lru_cache
import redis

redis_client = redis.Redis(host='localhost', port=6379, db=0)

def cache_key(query: str) -> str:
    return f"agent:cache:{hashlib.md5(query.encode()).hexdigest()}"

def get_cached(query: str):
    """Get cached result if available."""
    key = cache_key(query)
    cached = redis_client.get(key)
    if cached:
        return json.loads(cached)
    return None

def set_cache(query: str, result: dict, ttl: int = 3600):
    """Cache result for TTL seconds."""
    key = cache_key(query)
    redis_client.setex(key, ttl, json.dumps(result))

# Usage in agent
def run_agent_with_cache(query: str):
    cached = get_cached(query)
    if cached:
        return cached
    
    result = run_agent(query)
    set_cache(query, result)
    return result
```

## Connection Pooling

```python
from openai import AsyncOpenAI

# Create client with connection pooling
client = AsyncOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    max_retries=3,
    timeout=30.0,
)

# Reuse across requests
async def generate(query: str):
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": query}],
    )
    return response.choices[0].message.content
```

## Rate Limiting

```python
import asyncio
from datetime import datetime, timedelta

class RateLimiter:
    def __init__(self, max_requests: int, window_seconds: int):
        self.max_requests = max_requests
        self.window = timedelta(seconds=window_seconds)
        self.requests = []
    
    async def acquire(self):
        now = datetime.now()
        # Remove old requests
        self.requests = [r for r in self.requests if now - r < self.window]
        
        if len(self.requests) >= self.max_requests:
            sleep_time = (self.requests[0] + self.window - now).total_seconds()
            await asyncio.sleep(sleep_time)
        
        self.requests.append(now)

# Usage
limiter = RateLimiter(max_requests=10, window_seconds=60)

async def call_with_rate_limit(query):
    await limiter.acquire()
    return await llm.ainvoke(query)
```

## Message Queues for Background Work

```python
from celery import Celery

celery_app = Celery('agents', broker='redis://redis:6379')

@celery_app.task(bind=True, max_retries=3)
def process_agent_task(self, query: str):
    try:
        result = run_agent(query)
        return result
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)

# Enqueue
task = process_agent_task.delay("Research AI agents")

# Check status
task.status  # PENDING, SUCCESS, FAILURE
```

## Scaling Checklist

- [ ] Async tool execution
- [ ] Redis caching for tool results
- [ ] Connection pooling for LLM APIs
- [ ] Rate limiting with backoff
- [ ] Celery workers for background tasks
- [ ] Horizontal pod autoscaling (K8s)
- [ ] Database connection pooling
- [ ] Streaming responses to users

## Performance Targets

| Metric | Target | Good | Poor |
|--------|--------|------|------|
| p50 latency | < 5s | 5-10s | > 10s |
| p95 latency | < 30s | 30-60s | > 60s |
| Error rate | < 1% | 1-5% | > 5% |
| Cost/request | < $0.10 | $0.10-0.50 | > $0.50 |
| Cache hit rate | > 50% | 30-50% | < 30% |
