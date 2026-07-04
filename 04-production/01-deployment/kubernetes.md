# Kubernetes Deployment

Run your agents on Kubernetes for production-grade orchestration, scaling, and reliability.

---

## Architecture

```mermaid
graph TB
    User[User] --> Ingress[Ingress Controller]
    Ingress --> SVC[Service]
    SVC --> Pod1[Pod]
    SVC --> Pod2[Pod]
    SVC --> Pod3[Pod]
    
    Pod1 --> DB[(PostgreSQL)]
    Pod1 --> Redis[(Redis)]
    
    HPA[HPA] --> Pod1
    HPA --> Pod2
    HPA --> Pod3
    
    style Ingress fill:#e3f2fd
    style SVC fill:#e8f5e9
    style Pod1 fill:#fff3e0
    style HPA fill:#fce4ec
```

---

## Complete Manifests

### Namespace

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: agentic-ai
  labels:
    name: agentic-ai
```

### ConfigMap

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: agent-config
  namespace: agentic-ai
data:
  DATABASE_URL: "postgresql://postgres:postgres@postgres:5432/agents"
  REDIS_URL: "redis://redis:6379"
  LOG_LEVEL: "INFO"
  MAX_ITERATIONS: "10"
  TIMEOUT: "60"
```

### Secret

```yaml
# secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: agent-secrets
  namespace: agentic-ai
type: Opaque
stringData:
  OPENAI_API_KEY: "sk-..."
  ANTHROPIC_API_KEY: "sk-ant-..."
  DATABASE_PASSWORD: "postgres"
  LANGFUSE_PUBLIC_KEY: "pk-..."
  LANGFUSE_SECRET_KEY: "sk-..."
```

### Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent-service
  namespace: agentic-ai
  labels:
    app: agent-service
spec:
  replicas: 2
  selector:
    matchLabels:
      app: agent-service
  template:
    metadata:
      labels:
        app: agent-service
    spec:
      containers:
      - name: agent-service
        image: agentic-ai-playbook:latest
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: agent-config
              key: DATABASE_URL
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: agent-secrets
              key: OPENAI_API_KEY
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
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 10"]
      terminationGracePeriodSeconds: 30
```

### Service

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: agent-service
  namespace: agentic-ai
spec:
  selector:
    app: agent-service
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
```

### Ingress

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: agent-ingress
  namespace: agentic-ai
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

### Horizontal Pod Autoscaler

```yaml
# hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-hpa
  namespace: agentic-ai
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent-service
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### Pod Disruption Budget

```yaml
# pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: agent-pdb
  namespace: agentic-ai
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: agent-service
```

---

## Deploy

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check status
kubectl get pods -n agentic-ai
kubectl get svc -n agentic-ai
kubectl get ingress -n agentic-ai

# Logs
kubectl logs -f deployment/agent-service -n agentic-ai

# Scale manually
kubectl scale deployment agent-service --replicas=5 -n agentic-ai

# Rollout status
kubectl rollout status deployment/agent-service -n agentic-ai

# Rollback
kubectl rollout undo deployment/agent-service -n agentic-ai
```

## Resource Guidelines

| Workload | CPU Request | CPU Limit | Memory Request | Memory Limit |
|----------|------------|-----------|----------------|--------------|
| API Server | 250m | 500m | 256Mi | 512Mi |
| Agent Worker | 500m | 1000m | 512Mi | 1Gi |
| Background Job | 250m | 500m | 256Mi | 512Mi |

## Tips

1. **Always set resource limits**: Prevents one pod from consuming all resources
2. **Use PDBs**: Ensures minimum availability during updates
3. **HPA over manual scaling**: Let K8s handle scaling decisions
4. **Readiness probes**: Don't send traffic until pod is ready
5. **Graceful shutdown**: Handle SIGTERM to finish in-flight requests
