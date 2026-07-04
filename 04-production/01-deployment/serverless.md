# Serverless Deployment

Run agents without managing servers. Best for intermittent workloads.

---

## When to Use Serverless

| Use Case | Serverless? | Why |
|----------|------------|-----|
| Slack bot (few requests/day) | Yes | Cost-effective |
| Customer support (business hours) | Yes | Auto-scale to zero |
| Batch processing | Maybe | Timeout limits |
| Real-time streaming | No | Cold start latency |
| Always-on agent | No | Expensive |

## AWS Lambda

### Function

```python
import json
import os
from src.agent import run_agent

def handler(event, context):
    """Lambda handler for agent requests."""
    body = json.loads(event.get("body", "{}"))
    query = body.get("query", "")
    
    # Run agent
    result = run_agent(query)
    
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"result": result})
    }
```

### SAM Template

```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 60
    MemorySize: 512

Resources:
  AgentFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: .
      Handler: app.handler
      Runtime: python3.11
      Events:
        ApiEvent:
          Type: Api
          Properties:
            Path: /agent
            Method: post
      Environment:
        Variables:
          OPENAI_API_KEY: !Ref OpenAIApiKey
```

### Container Lambda

For larger dependencies (LangGraph, etc.), use container images:

```dockerfile
FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ ${LAMBDA_TASK_ROOT}/src/
COPY app.py ${LAMBDA_TASK_ROOT}

CMD ["app.handler"]
```

## Cloudflare Workers

Edge-deployed. Lowest latency for global users.

```javascript
// worker.js
export default {
  async fetch(request, env) {
    const { query } = await request.json();
    
    // Call your agent API
    const response = await fetch(env.AGENT_API_URL, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${env.API_KEY}` },
      body: JSON.stringify({ query })
    });
    
    return response;
  }
};
```

## Cold Start Mitigation

| Strategy | Impact | How |
|----------|--------|-----|
| Provisioned concurrency | Eliminates cold start | Keep N instances warm |
| Container reuse | Reuses init | Initialize outside handler |
| Lazy loading | Faster init | Load deps on first request |
| Smaller packages | Faster startup | Remove unused deps |

```python
# Initialize outside handler for reuse
agent = None

def get_agent():
    global agent
    if agent is None:
        agent = create_agent()
    return agent

def handler(event, context):
    agent = get_agent()  # Reuses across invocations
    return agent.run(event["query"])
```

## Cost Comparison

| Platform | 1K req/day | 10K req/day | 100K req/day |
|----------|-----------|-------------|--------------|
| AWS Lambda | ₹150 | ₹1,500 | ₹15,000 |
| Cloud Run | ₹100 | ₹1,000 | ₹10,000 |
| Cloudflare Workers | ₹50 | ₹500 | ₹5,000 |
| ECS Fargate | ₹500 | ₹500 | ₹500 (flat) |

**Serverless wins** for low-volume, spiky workloads.
**Containers win** for steady, high-volume workloads.
