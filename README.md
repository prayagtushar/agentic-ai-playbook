# Agentic AI Playbook

> **From zero to production-grade AI agents.** A complete, hands-on curriculum for building, deploying, and scaling autonomous AI agents in 2026.
> Built for the Indian AI engineer who wants to ship.

[![Python](https://img.shields.io/badge/Python-3.11%2B-blue)](https://python.org)
[![Frameworks](https://img.shields.io/badge/Frameworks-6-green)](./02-frameworks/)
[![Projects](https://img.shields.io/badge/Projects-6-orange)](./03-projects/)
[![License](https://img.shields.io/badge/License-MIT-black)](./LICENSE)

---

## What This Is

This repository is a **complete, production-oriented learning system** for AI agents. It is not a list of links. It is not a collection of notebooks. It is a **structured, end-to-end curriculum** that takes you from understanding what an agent is to deploying a multi-agent system handling real workflows at scale.

Every section includes:
- **Theory** — explained with analogies and architecture diagrams
- **Code** — complete, runnable Python examples
- **Production patterns** — error handling, monitoring, scaling, cost control
- **Projects** — 6 portfolio-grade builds with full architecture specs

---

## Quick Start

```bash
# Clone
git clone https://github.com/prayagtushar/agentic-ai-playbook.git
cd agentic-ai-playbook

# Install everything
make setup

# Or install only what you need
pip install -e ".[langgraph,crewai]"   # specific frameworks
pip install -e ".[deploy,observe]"      # production tooling

# Verify
make test
```

---

## Repo Structure

```
agentic-ai-playbook/
|
|__ 01-foundations/           # Theory, patterns, core concepts
|   |__ 01-what-are-agents.md
|   |__ 02-agent-architecture-patterns.md
|   |__ 03-core-concepts.md
|   |__ 04-agent-vs-llm-vs-rag.md
|   |__ 05-types-of-agents.md
|
|__ 02-frameworks/            # 6 frameworks, code for each
|   |__ comparison-matrix.md
|   |__ 01-langgraph/
|   |__ 02-crewai/
|   |__ 03-autogen-ag2/
|   |__ 04-llamaindex-agents/
|   |__ 05-openai-agents-sdk/
|   |__ 06-pydantic-ai/
|
|__ 03-projects/              # 6 portfolio-grade projects
|   |__ 01-research-assistant/
|   |__ 02-coding-agent/
|   |__ 03-support-agent/
|   |__ 04-data-analysis-agent/
|   |__ 05-browser-agent/
|   |__ 06-autonomous-workflow/      # Capstone
|
|__ 04-production/            # Deploy and operate at scale
|   |__ 01-deployment/
|   |   |__ docker.md
|   |   |__ kubernetes.md
|   |   |__ aws.md
|   |   |__ gcp.md
|   |   |__ serverless.md
|   |__ 02-monitoring/
|   |__ 03-evaluation/
|   |__ 04-scaling/
|   |__ 05-security/
|   |__ 06-cost-optimization/
|   |__ 07-ci-cd/
|   |__ 08-case-studies/
|
|__ 05-resources/             # Papers, courses, interview prep
|   |__ papers.md
|   |__ courses.md
|   |__ communities.md
|   |__ interview-prep.md
|   |__ indian-market-insights.md
|
|__ 06-templates/             # Boilerplate to start fast
|   |__ project-template/
|   |__ agent-template/
|   |__ deployment-template/
|
|__ ROADMAP.md                # 8-week structured learning plan
|__ Makefile                  # Common commands
|__ pyproject.toml            # Dependencies with optional extras
```

---

## The 8-Week Roadmap

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1-2 | [Foundations](./01-foundations/) | Understand agents, patterns, core concepts |
| 3-4 | [LangGraph](./02-frameworks/01-langgraph/) | Build stateful agents with checkpointing |
| 5 | [CrewAI + AutoGen](./02-frameworks/02-crewai/) | Multi-agent orchestration |
| 6 | [Projects 1-3](./03-projects/) | Research assistant, coding agent, support bot |
| 7 | [Projects 4-5](./03-projects/) | Data analysis agent, browser agent |
| 8 | [Production](./04-production/) + [Capstone](./03-projects/06-autonomous-workflow/) | Deploy agents, monitoring, security, scaling |
| Ongoing | [Interview Prep](./05-resources/interview-prep.md) | Crack agent roles at top companies |

[Full roadmap with daily schedule →](./ROADMAP.md)

---

## 6 Frameworks. One Comparison.

| Framework | Best For | Learning Curve | Production Ready |
|-----------|----------|---------------|-------------------|
| [LangGraph](./02-frameworks/01-langgraph/) | Complex stateful workflows | Medium | ★★★★★ |
| [CrewAI](./02-frameworks/02-crewai/) | Role-based multi-agent teams | Low | ★★★★ |
| [AutoGen/AG2](./02-frameworks/03-autogen-ag2/) | Conversational multi-agent | Medium | ★★★ |
| [LlamaIndex Agents](./02-frameworks/04-llamaindex-agents/) | RAG-grounded agents | Low | ★★★★ |
| [OpenAI Agents SDK](./02-frameworks/05-openai-agents-sdk/) | OpenAI-native quick builds | Low | ★★★★ |
| [Pydantic AI](./02-frameworks/06-pydantic-ai/) | Type-safe Python agents | Low | ★★★★ |

[Detailed comparison with code →](./02-frameworks/comparison-matrix.md)

---

## 6 Projects. Portfolio-Grade.

| # | Project | Framework | Pattern | Difficulty |
|---|---------|-----------|---------|------------|
| 1 | [Research Assistant](./03-projects/01-research-assistant/) | CrewAI | Hierarchical multi-agent | Intermediate |
| 2 | [Coding Agent](./03-projects/02-coding-agent/) | LangGraph | Iterative loop + recovery | Advanced |
| 3 | [Support Agent](./03-projects/03-support-agent/) | LangGraph | Conditional routing + HITL | Intermediate |
| 4 | [Data Analysis Agent](./03-projects/04-data-analysis-agent/) | LangGraph | Tool chaining (SQL + viz) | Intermediate |
| 5 | [Browser Agent](./03-projects/05-browser-agent/) | LangGraph + Vision | Web automation | Advanced |
| 6 | [Autonomous Workflow](./03-projects/06-autonomous-workflow/) | Mixed | Full production system | Expert |

Each project includes: architecture diagrams, tech stack, folder structure, key code, deployment notes.

---

## Production Checklist

Before your agent hits production, go through this:

- [ ] **Containerized** — Dockerfile + docker-compose ready
- [ ] **Deployed** — Kubernetes or cloud-run configured
- [ ] **Observable** — LangSmith/Langfuse tracing enabled
- [ ] **Evaluated** — LLM-as-a-Judge harness in CI
- [ ] **Secure** — Input validation, guardrails, PII filtering
- [ ] **Scalable** — Async execution, caching, connection pooling
- [ ] **Cost-controlled** — Model routing, token optimization, budgets
- [ ] **Tested** — Regression tests, A/B testing infrastructure
- [ ] **Monitored** — Alerts for cost spikes, error rates, latency
- [ ] **Documented** — Runbooks for on-call

[Full production guides →](./04-production/)

---

## Why This Exists

The AI agent landscape in 2026 is fragmented. Hundreds of tutorials. Dozens of frameworks. No clear path from "hello world" to production.

This repo solves that. It is:

- **Structured** — Follow the roadmap or jump to what you need
- **Practical** — Every concept has working code
- **Production-oriented** — Not just prototypes; patterns for real systems
- **India-aware** — Salary insights, company lists, remote work opportunities
- **Portfolio-optimized** — Projects you can show to recruiters

---

## Who This Is For

- **Software engineers** transitioning to AI/Agent engineering
- **AI engineers** who want to go deeper into agents
- **Founders** building agent-powered products
- **Students** preparing for AI roles in the Indian market

**Prerequisites:** Python, basic LLM API usage, Git. RAG experience helps (you probably have it).

---

## The Agent Landscape in India (2026)

| Metric | Detail |
|--------|--------|
| Role | Agentic AI Developer |
| Fresher Salary | ₹9-15 LPA |
| Mid-Level | ₹18-30 LPA |
| Senior | ₹25-50 LPA |
| Global Remote | ₹40-80 LPA |
| Demand | Very high — near-zero qualified supply |
| Top Skills | LangGraph, CrewAI, tool use, multi-agent orchestration |
| Companies | TCS, Infosys, startups, global remote |

[Full Indian market analysis →](./05-resources/indian-market-insights.md)

---

## Commands

```bash
make setup          # Install all dependencies
make test           # Run test suite
make lint           # Run ruff + mypy
make format         # Format code
make docker-build   # Build Docker image
make docker-run     # Run with docker-compose
make clean          # Clean up
make docs-serve     # Serve docs locally
```

---

## Resources

- [Must-Read Papers](./05-resources/papers.md) — 30 papers that shaped the field
- [Courses & Books](./05-resources/courses.md) — Free and paid learning paths
- [Communities](./05-resources/communities.md) — Discord, Reddit, conferences, hackathons
- [Interview Prep](./05-resources/interview-prep.md) — 30+ questions with answers
- [Templates](./06-templates/) — Start new projects in minutes

---

## License

MIT. Use it, fork it, share it, build with it.

---

## About

Built by [Prayag Tushar](https://prayagtushar.xyz) — AI Engineer, India.

If this repo helps you learn or land a role, let me know at [t.prayag.eng@gmail.com](mailto:t.prayag.eng@gmail.com).

**Star this repo if you find it useful.** It helps others discover it.

---

## Contributing

This is a living document. The agent space moves fast. If you find something outdated or want to add a project, open an issue or PR.

Focus areas for contributions:
- New framework sections as they emerge
- Additional production case studies
- More interview questions
- India-specific company hiring data
