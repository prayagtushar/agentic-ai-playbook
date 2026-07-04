# GCP Deployment

Deploy your agents on Google Cloud Platform.

---

## Cloud Run (Recommended)

Serverless containers. Automatic scaling. Pay per request.

```bash
# Build and push to GCR
gcloud builds submit --tag gcr.io/PROJECT_ID/agentic-ai-playbook

# Deploy to Cloud Run
gcloud run deploy agentic-ai-playbook \
    --image gcr.io/PROJECT_ID/agentic-ai-playbook \
    --platform managed \
    --region asia-south1 \
    --allow-unauthenticated \
    --set-env-vars DATABASE_URL=...,REDIS_URL=... \
    --set-secrets OPENAI_API_KEY=openai-api-key:latest

# Get URL
gcloud run services describe agentic-ai-playbook --region asia-south1 --format 'value(status.url)'
```

## Cloud Run with Cloud SQL

```bash
# Create Cloud SQL instance
gcloud sql instances create agent-db \
    --database-version POSTGRES_16 \
    --tier db-f1-micro \
    --region asia-south1

# Connect Cloud Run to Cloud SQL
gcloud run services update agentic-ai-playbook \
    --add-cloudsql-instances PROJECT_ID:asia-south1:agent-db
```

## GKE (For Complex Workloads)

```bash
# Create cluster
gcloud container clusters create agentic-ai-cluster \
    --zone asia-south1-a \
    --num-nodes 2 \
    --machine-type e2-medium

# Get credentials
gcloud container clusters get-credentials agentic-ai-cluster --zone asia-south1-a

# Deploy
kubectl apply -f k8s/
```

## Vertex AI Integration

Use Gemini through Vertex AI:

```python
import vertexai
from vertexai.generative_models import GenerativeModel

vertexai.init(project="PROJECT_ID", location="asia-south1")

model = GenerativeModel("gemini-2.5-flash")

def call_gemini(prompt: str) -> str:
    response = model.generate_content(prompt)
    return response.text
```

**Cost**: Gemini through Vertex AI is the cheapest option for Indian users.

## Cloud Tasks for Async Work

```python
from google.cloud import tasks_v2

client = tasks_v2.CloudTasksClient()

def enqueue_task(queue_name: str, payload: dict):
    task = {
        "http_request": {
            "http_method": tasks_v2.HttpMethod.POST,
            "url": "https://agent-service-url/run-agent",
            "headers": {"Content-type": "application/json"},
            "body": json.dumps(payload).encode(),
        }
    }
    
    client.create_task(request={"parent": queue_name, "task": task})
```

## Cost Estimate (asia-south1)

| Service | Monthly Cost (₹) |
|---------|-----------------|
| Cloud Run (100K requests) | ₹500-1,000 |
| Cloud SQL | ₹1,500-3,000 |
| Memorystore Redis | ₹1,000-2,000 |
| Vertex AI (Gemini) | ₹2,000-5,000 |
| **Total** | **₹5,000-11,000** |

GCP is generally cheaper than AWS for agent workloads in India.
