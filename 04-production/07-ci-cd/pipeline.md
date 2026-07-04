# CI/CD for Agent Systems

> Agent deployments need special handling: prompts, models, and tools all change independently.

---

## GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Lint
        run: |
          ruff check src/ tests/
          mypy src/
      
      - name: Unit tests
        run: pytest tests/unit/ -v
      
      - name: Evaluation tests
        run: pytest tests/eval/ -v
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      
      - name: Regression test
        run: pytest tests/regression/ -v
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker image
        run: docker build -t agentic-ai-playbook:${{ github.sha }} .
      
      - name: Push to registry
        run: |
          docker tag agentic-ai-playbook:${{ github.sha }} ${{ secrets.REGISTRY }}/agentic-ai-playbook:${{ github.sha }}
          docker push ${{ secrets.REGISTRY }}/agentic-ai-playbook:${{ github.sha }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          kubectl set image deployment/agent-service agent-service=${{ secrets.REGISTRY }}/agentic-ai-playbook:${{ github.sha }} -n staging
          kubectl rollout status deployment/agent-service -n staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production (canary)
        run: |
          # Deploy to 10% of pods
          kubectl set image deployment/agent-service agent-service=${{ secrets.REGISTRY }}/agentic-ai-playbook:${{ github.sha }} -n production
          kubectl rollout status deployment/agent-service -n production --timeout=5m
      
      - name: Smoke test
        run: |
          curl -f https://api.yourapp.com/health || exit 1
      
      - name: Full rollout
        if: success()
        run: |
          # Roll out to 100%
          kubectl scale deployment/agent-service --replicas=10 -n production
```

## Prompt Versioning

Store prompts separately and version them:

```
prompts/
├── v1.0.0/
│   ├── research.txt
│   ├── analysis.txt
│   └── writing.txt
├── v1.1.0/
│   ├── research.txt
│   ├── analysis.txt
│   └── writing.txt
└── current -> v1.1.0/
```

```python
# Load prompts by version
from pathlib import Path

def load_prompt(name: str, version: str = "current") -> str:
    prompt_file = Path(f"prompts/{version}/{name}.txt")
    return prompt_file.read_text()

# Usage
research_prompt = load_prompt("research", version="v1.1.0")
```

## Model A/B Testing

```python
import random
from datetime import datetime

class ModelRouter:
    def __init__(self, ab_test_config: dict):
        self.config = ab_test_config
    
    def route(self, query: str) -> str:
        """Route to A or B model."""
        roll = random.random()
        
        if roll < self.config["b_percentage"]:
            return self.config["model_b"]
        return self.config["model_a"]
    
    def log_result(self, model: str, query: str, score: float):
        """Log result for comparison."""
        # Send to your analytics
        pass

# Usage
router = ModelRouter({
    "model_a": "gpt-4o",
    "model_b": "claude-sonnet",
    "b_percentage": 0.1,  # 10% to B
})
```

## Rollback Strategy

```bash
# Quick rollback script
#!/bin/bash
PREVIOUS_IMAGE=$(kubectl get deployment agent-service -o jsonpath='{.spec.template.spec.containers[0].image}' | sed 's/:.*//'):$(kubectl rollout history deployment/agent-service | tail -2 | head -1 | awk '{print $1}')

kubectl rollout undo deployment/agent-service
kubectl rollout status deployment/agent-service

echo "Rolled back to: $PREVIOUS_IMAGE"
```

## Terraform for Infrastructure

```hcl
# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  
  cluster_name = "agentic-ai-cluster"
  
  services = {
    agent-service = {
      cpu    = 512
      memory = 1024
      
      container_definitions = {
        agent-service = {
          image = "${aws_ecr_repository.agent_repo.repository_url}:latest"
          port_mappings = [
            {
              containerPort = 8000
              protocol      = "tcp"
            }
          ]
        }
      }
    }
  }
}
```

## Best Practices

1. **Separate prompt changes from code changes**: Version independently
2. **Evaluation in CI**: Never deploy without running evals
3. **Canary deployments**: Roll out to 10% first
4. **Automatic rollback**: Roll back if error rate spikes
5. **Feature flags**: Enable features without deploying
6. **Immutable infrastructure**: Never modify running containers
