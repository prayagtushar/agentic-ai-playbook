# AWS Deployment

Deploy your agents on AWS using ECS Fargate, EKS, or Lambda.

---

## Option 1: ECS Fargate (Recommended for Start)

No server management. Pay per use.

### Step-by-Step

```bash
# 1. Create ECR repository
aws ecr create-repository --repository-name agentic-ai-playbook

# 2. Build and push
docker build -t agentic-ai-playbook .
aws ecr get-login-password | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com
docker tag agentic-ai-playbook:latest <account>.dkr.ecr.<region>.amazonaws.com/agentic-ai-playbook:latest
docker push <account>.dkr.ecr.<region>.amazonaws.com/agentic-ai-playbook:latest

# 3. Create ECS cluster
aws ecs create-cluster --cluster-name agentic-ai-cluster

# 4. Create task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# 5. Create service
aws ecs create-service \
    --cluster agentic-ai-cluster \
    --service-name agentic-ai-service \
    --task-definition agentic-ai-playbook \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

### Task Definition

```json
{
  "family": "agentic-ai-playbook",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::<account>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "agent-service",
      "image": "<account>.dkr.ecr.<region>.amazonaws.com/agentic-ai-playbook:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "DATABASE_URL", "value": "..."},
        {"name": "REDIS_URL", "value": "..."}
      ],
      "secrets": [
        {
          "name": "OPENAI_API_KEY",
          "valueFrom": "arn:aws:secretsmanager:<region>:<account>:secret:openai-api-key"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/agentic-ai",
          "awslogs-region": "ap-south-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

## Option 2: EKS (For Scale)

Managed Kubernetes on AWS.

```bash
# Create cluster with eksctl
eksctl create cluster \
    --name agentic-ai-cluster \
    --region ap-south-1 \
    --node-type t3.medium \
    --nodes-min 2 \
    --nodes-max 5 \
    --managed

# Deploy
kubectl apply -f k8s/

# Get ingress IP
kubectl get ingress -n agentic-ai
```

## Option 3: Lambda + API Gateway (For Simple Agents)

Serverless. Cold starts ~1-2s.

```python
# lambda_function.py
import json
from src.agent import run_agent

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))
    query = body.get("query", "")
    
    result = run_agent(query)
    
    return {
        "statusCode": 200,
        "body": json.dumps({"result": result})
    }
```

```bash
# Deploy with SAM
sam build
sam deploy --guided
```

## Bedrock Integration

Use AWS Bedrock for LLM calls to reduce costs:

```python
import boto3

bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

def call_bedrock(prompt: str) -> str:
    response = bedrock.invoke_model(
        modelId="anthropic.claude-sonnet-4-20250514-v1:0",
        body=json.dumps({
            "prompt": f"\n\nHuman: {prompt}\n\nAssistant:",
            "max_tokens_to_sample": 1000,
        })
    )
    result = json.loads(response["body"].read())
    return result["completion"]
```

**Cost savings**: Bedrock is ~20-30% cheaper than direct API calls for high volume.

## Cost Estimate (India Region: ap-south-1)

| Service | Monthly Cost (₹) |
|---------|-----------------|
| ECS Fargate (2 tasks) | ₹3,000-5,000 |
| RDS PostgreSQL | ₹2,000-4,000 |
| ElastiCache Redis | ₹1,500-2,500 |
| ALB | ₹1,500 |
| Bedrock (100K requests) | ₹5,000-10,000 |
| **Total** | **₹13,000-23,000** |

## Terraform

```hcl
# main.tf
provider "aws" {
  region = "ap-south-1"
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  
  cluster_name = "agentic-ai-cluster"
  
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}
```
