# Deployment Template

> Complete deployment setup: Docker, Kubernetes, CI/CD, Terraform.

---

## Docker Compose (Local)

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/agents
      - REDIS_URL=redis://redis:6379
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=agents
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - app

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    depends_on:
      - prometheus

volumes:
  postgres_data:
```

## Kubernetes Manifests

### Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: agents
```

### ConfigMap

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
  namespace: agents
data:
  LOG_LEVEL: "INFO"
  MAX_ITERATIONS: "10"
```

### Secret

```yaml
# k8s/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: agent-secrets
  namespace: agents
type: Opaque
stringData:
  OPENAI_API_KEY: "sk-..."
```

### Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent-app
  namespace: agents
spec:
  replicas: 2
  selector:
    matchLabels:
      app: agent-app
  template:
    metadata:
      labels:
        app: agent-app
    spec:
      containers:
      - name: agent
        image: agent-app:latest
        ports:
        - containerPort: 8000
        envFrom:
        - configMapRef:
            name: agent-config
        envFrom:
        - secretRef:
            name: agent-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Service

```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: agent-service
  namespace: agents
spec:
  selector:
    app: agent-app
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

### Ingress

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: agent-ingress
  namespace: agents
  annotations:
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  ingressClassName: nginx
  rules:
  - host: agents.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: agent-service
            port:
              number: 80
```

### HPA

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-hpa
  namespace: agents
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### PDB

```yaml
# k8s/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: agent-pdb
  namespace: agents
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: agent-app
```

## GitHub Actions CI/CD

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

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
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt
      - run: pytest tests/ -v
      - run: ruff check src/
      - run: mypy src/

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pip install bandit safety
      - run: bandit -r src/
      - run: safety check

  build:
    needs: [test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t agent-app:${{ github.sha }} .
      - name: Push to registry
        run: |
          echo ${{ secrets.REGISTRY_PASSWORD }} | docker login ${{ secrets.REGISTRY }} -u ${{ secrets.REGISTRY_USERNAME }} --password-stdin
          docker push agent-app:${{ github.sha }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        run: |
          kubectl set image deployment/agent-app agent-app=agent-app:${{ github.sha }} -n staging
          kubectl rollout status deployment/agent-app -n staging

  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        run: |
          kubectl set image deployment/agent-app agent-app=agent-app:${{ github.sha }} -n production
          kubectl rollout status deployment/agent-app -n production
```

## Terraform

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

# ECR Repository
resource "aws_ecr_repository" "agent_app" {
  name = "agent-app"
}

# ECS Cluster
resource "aws_ecs_cluster" "agent_cluster" {
  name = "agent-cluster"
}

# Outputs
output "ecr_repository_url" {
  value = aws_ecr_repository.agent_app.repository_url
}
```

## Deployment Commands

```bash
# Local development
docker-compose up --build

# Kubernetes
kubectl apply -f k8s/

# Check status
kubectl get pods -n agents
kubectl logs -f deployment/agent-app -n agents

# Scale
kubectl scale deployment agent-app --replicas=5 -n agents

# Rollback
kubectl rollout undo deployment/agent-app -n agents
```

## Monitoring Stack

- **Prometheus**: Metrics collection (port 9090)
- **Grafana**: Dashboards (port 3000, admin/admin)
- **Langfuse**: Agent tracing (port 3000)
- **Nginx**: Load balancing and rate limiting

Deploy and monitor!
