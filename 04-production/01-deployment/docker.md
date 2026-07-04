# Docker Deployment

Containerize your agent application for consistent, reproducible deployments.

---

## Dockerfile

```dockerfile
# ==========================================
# Stage 1: Builder
# ==========================================
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ==========================================
# Stage 2: Production
# ==========================================
FROM python:3.11-slim as production

WORKDIR /app

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

# Copy application code
COPY src/ ./src/
COPY pyproject.toml .

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

EXPOSE 8000

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

# ==========================================
# Stage 3: Development
# ==========================================
FROM builder as development

WORKDIR /app

COPY requirements-dev.txt .
RUN pip install --no-cache-dir --user -r requirements-dev.txt

COPY . .

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

## docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      target: production
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/agents
      - REDIS_URL=redis://redis:6379
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - LANGFUSE_PUBLIC_KEY=${LANGFUSE_PUBLIC_KEY}
      - LANGFUSE_SECRET_KEY=${LANGFUSE_SECRET_KEY}
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
    restart: unless-stopped

  db:
    image: postgres:16
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=agents
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  langfuse:
    image: langfuse/langfuse:latest
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/langfuse
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - SALT=${SALT}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}

volumes:
  postgres_data:
```

## Commands

```bash
# Build
docker build -t agentic-ai-playbook .

# Run with compose
docker-compose up --build

# Run specific service
docker-compose up app

# Development mode
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Logs
docker-compose logs -f app

# Scale workers
docker-compose up --scale worker=3

# Clean up
docker-compose down -v
docker system prune
```

## Health Checks

```python
# src/main.py
from fastapi import FastAPI, status
from fastapi.responses import JSONResponse

app = FastAPI()

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    checks = {
        "database": await check_database(),
        "redis": await check_redis(),
        "llm_api": await check_llm_api(),
    }
    
    all_healthy = all(checks.values())
    status_code = status.HTTP_200_OK if all_healthy else status.HTTP_503_SERVICE_UNAVAILABLE
    
    return JSONResponse(
        content={"status": "healthy" if all_healthy else "unhealthy", "checks": checks},
        status_code=status_code,
    )

async def check_database():
    try:
        # Quick DB query
        return True
    except:
        return False

async def check_redis():
    try:
        # Quick Redis ping
        return True
    except:
        return False

async def check_llm_api():
    try:
        # Quick LLM API check
        return True
    except:
        return False
```

## Multi-Stage Build Benefits

| Stage | Size | Use Case |
|-------|------|----------|
| Builder | ~500MB | Building dependencies |
| Production | ~200MB | Running in production |
| Development | ~600MB | Local development |

The production image is 60% smaller because it excludes build tools.

## Best Practices

1. **Non-root user**: Always run as non-root in containers
2. **Health checks**: Verify app is actually working, not just running
3. **Resource limits**: Set memory and CPU limits
4. **Graceful shutdown**: Handle SIGTERM properly
5. **Layer caching**: Order Dockerfile commands by change frequency
6. **Secret management**: Never bake secrets into images
