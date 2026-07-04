# Agentic AI Playbook - Makefile
.PHONY: help setup setup-langgraph setup-crewai setup-autogen setup-llamaindex \
	test lint format clean docker-build docker-run docker-stop docs-serve

PYTHON := python3
PIP := pip3

help:
	@echo "Agentic AI Playbook - Available Commands:"
	@echo "=========================================="
	@echo "  make setup              Install all dependencies"
	@echo "  make setup-langgraph    Install LangGraph only"
	@echo "  make setup-crewai       Install CrewAI only"
	@echo "  make setup-autogen      Install AutoGen only"
	@echo "  make setup-llamaindex   Install LlamaIndex only"
	@echo "  make test               Run test suite"
	@echo "  make lint               Run ruff + mypy"
	@echo "  make format             Format with black + ruff"
	@echo "  make clean              Clean generated files"
	@echo "  make docker-build       Build Docker image"
	@echo "  make docker-run         Run with docker-compose"
	@echo "  make docker-stop        Stop docker-compose"
	@echo "  make docs-serve         Serve docs locally"

# Setup
setup:
	$(PIP) install -e ".[all]"

setup-langgraph:
	$(PIP) install -e ".[langgraph]"

setup-crewai:
	$(PIP) install -e ".[crewai]"

setup-autogen:
	$(PIP) install -e ".[autogen]"

setup-llamaindex:
	$(PIP) install -e ".[llamaindex]"

# Testing
test:
	pytest tests/ -v --tb=short

test-cov:
	pytest tests/ -v --cov=src --cov-report=html --cov-report=term

# Linting & Formatting
lint:
	ruff check src/ tests/
	mypy src/

format:
	black src/ tests/
	ruff check --fix src/ tests/

format-check:
	black --check src/ tests/

# Cleanup
clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name "*.egg-info" -exec rm -rf {} +
	rm -rf .pytest_cache/ .mypy_cache/ htmlcov/ .coverage build/ dist/

# Docker
docker-build:
	docker build -t agentic-ai-playbook .

docker-run:
	docker-compose up --build

docker-stop:
	docker-compose down

docker-logs:
	docker-compose logs -f

# Docs
docs-serve:
	@echo "Serving documentation..."
	@echo "Open http://localhost:8000"
	python -m http.server 8000 --directory .

# Development
dev:
	$(PYTHON) -m uvicorn src.main:app --reload --port 8000

# Security scan
security:
	bandit -r src/
	safety check

# CI helpers
ci: lint test security

.DEFAULT_GOAL := help
