# Project Template

> Copy this template to start any new agent project. Everything is pre-configured.

---

## Quick Start

```bash
# Copy template
cp -r 06-templates/project-template my-new-agent-project
cd my-new-agent-project

# Setup
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your API keys

# Run
python src/main.py
```

---

## Folder Structure

```
my-new-agent-project/
├── src/
│   ├── __init__.py
│   ├── main.py              # Entry point
│   ├── agent.py             # Agent definition
│   ├── tools.py             # Custom tools
│   ├── config.py            # Settings (Pydantic)
│   └── models.py            # Data models
├── tests/
│   ├── __init__.py
│   ├── test_agent.py
│   └── test_tools.py
├── prompts/                 # Prompt templates
│   └── system.txt
├── data/                    # Local data
│   └── .gitkeep
├── reports/                 # Output files
│   └── .gitkeep
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── requirements-dev.txt
├── pyproject.toml
├── .env.example
├── .gitignore
├── Makefile
└── README.md
```

---

## Files

### pyproject.toml

```toml
[project]
name = "my-agent-project"
version = "0.1.0"
description = "AI agent project"
requires-python = ">=3.11"
dependencies = [
    "langgraph>=0.4.0",
    "langchain-openai>=0.2.0",
    "pydantic>=2.0.0",
    "pydantic-settings>=2.0.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.3.0",
    "ruff>=0.9.0",
    "mypy>=1.14.0",
    "black>=24.0.0",
]
```

### src/config.py

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application settings loaded from environment."""
    
    # LLM
    openai_api_key: str
    default_model: str = "gpt-4o-mini"
    
    # App
    log_level: str = "INFO"
    max_iterations: int = 10
    timeout: int = 60
    
    # Optional
    langfuse_public_key: str = ""
    langfuse_secret_key: str = ""
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### .env.example

```env
# Required
OPENAI_API_KEY=sk-...

# Optional
DEFAULT_MODEL=gpt-4o-mini
LOG_LEVEL=INFO
MAX_ITERATIONS=10

# Observability (optional)
LANGFUSE_PUBLIC_KEY=pk-...
LANGFUSE_SECRET_KEY=sk-...
```

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
COPY prompts/ ./prompts/

CMD ["python", "src/main.py"]
```

### docker-compose.yml

```yaml
version: '3.8'
services:
  app:
    build: .
    env_file: .env
    volumes:
      - ./data:/app/data
      - ./reports:/app/reports
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

### Makefile

```makefile
.PHONY: setup test lint format run docker-build docker-run clean

setup:
	pip install -r requirements.txt

test:
	pytest tests/ -v

lint:
	ruff check src/ tests/
	mypy src/

format:
	black src/ tests/

run:
	python src/main.py

docker-build:
	docker build -t my-agent .

docker-run:
	docker-compose up --build

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
```

### src/main.py

```python
#!/usr/bin/env python3
"""Agent entry point."""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from agent import run_agent
from config import settings

async def main():
    query = input("Enter your query: ")
    result = await run_agent(query)
    print(f"\nResult: {result}")

if __name__ == "__main__":
    asyncio.run(main())
```

---

## Customization

1. **Rename**: Update `name` in pyproject.toml
2. **Add tools**: Edit `src/tools.py`
3. **Configure prompts**: Edit files in `prompts/`
4. **Add tests**: Create files in `tests/`
5. **Deploy**: Update Dockerfile and docker-compose.yml

Start building!
