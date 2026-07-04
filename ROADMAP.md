# 8-Week Learning Roadmap

> Follow this roadmap to go from agent beginner to production-ready agent engineer.

---

## Overview

| Week | Focus | Time/Day | Key Deliverable |
|------|-------|----------|----------------|
| 1 | Foundations | 2-3 hrs | Understand what agents are |
| 2 | Architecture Patterns | 2-3 hrs | Know 6 patterns, when to use |
| 3 | LangGraph | 3-4 hrs | Build stateful agents |
| 4 | LangGraph Deep Dive | 3-4 hrs | Checkpointing, HITL, streaming |
| 5 | CrewAI + AutoGen | 3-4 hrs | Multi-agent orchestration |
| 6 | Projects 1-3 | 4-5 hrs | Research, coding, support agents |
| 7 | Projects 4-5 | 4-5 hrs | Data analysis, browser agents |
| 8 | Production + Capstone | 4-6 hrs | Deploy, monitor, capstone |

---

## Week 1: Foundations — What Are Agents?

**Goal**: Understand the fundamentals deeply.

### Day 1-2: Core Concepts
- [ ] Read [01-what-are-agents.md](./01-foundations/01-what-are-agents.md)
- [ ] Read [03-core-concepts.md](./01-foundations/03-core-concepts.md)
- [ ] Run the minimal agent example in 01-what-are-agents.md

### Day 3-4: Architecture Patterns
- [ ] Read [02-agent-architecture-patterns.md](./01-foundations/02-agent-architecture-patterns.md)
- [ ] Draw the 6 patterns on paper (teaching is learning)

### Day 5-6: Agent vs LLM vs RAG
- [ ] Read [04-agent-vs-llm-vs-rag.md](./01-foundations/04-agent-vs-llm-vs-rag.md)
- [ ] Map your existing RAG knowledge to agent concepts

### Day 7: Types of Agents
- [ ] Read [05-types-of-agents.md](./01-foundations/05-types-of-agents.md)
- [ ] Write a SimpleReflex and ModelBased agent from scratch

**Deliverable**: A simple agent that uses tools + memory.

---

## Week 2: Architecture Patterns Deep Dive

**Goal**: Internalize when to use which pattern.

### Day 1-2: ReAct + Plan-and-Execute
- [ ] Implement ReAct agent pattern from scratch
- [ ] Compare with Plan-and-Execute for a research task

### Day 3-4: Multi-Agent + Hierarchical
- [ ] Read CrewAI and LangGraph multi-agent sections
- [ ] Build a 2-agent system (researcher + writer)

### Day 5-6: HITL + Swarms
- [ ] Add human approval to an agent workflow
- [ ] Understand swarm patterns (read, don't implement yet)

### Day 7: Review + Quiz Yourself
- [ ] Review all 6 patterns
- [ ] Answer: When would you use Multi-Agent vs Hierarchical?

**Deliverable**: Architecture decision doc for your first project.

---

## Week 3: LangGraph — The #1 Framework

**Goal**: Build stateful agents with LangGraph.

### Day 1: Setup
- [ ] Install: `make setup-langgraph`
- [ ] Read [LangGraph guide](./02-frameworks/01-langgraph/README.md)

### Day 2-3: Basics
- [ ] Build a 2-node graph (search → summarize)
- [ ] Add conditional edges
- [ ] Run with different inputs

### Day 4-5: State Management
- [ ] Define typed state with TypedDict
- [ ] Pass state between nodes
- [ ] Add memory to the graph

### Day 6-7: Tool Integration
- [ ] Add 2+ tools to your agent
- [ ] Handle tool errors gracefully

**Deliverable**: A LangGraph agent with 3+ nodes that uses tools.

---

## Week 4: LangGraph Advanced

**Goal**: Production patterns with LangGraph.

### Day 1-2: Checkpointing
- [ ] Configure SQLite checkpointer
- [ ] Test crash recovery (kill mid-run, resume)
- [ ] Switch to Postgres checkpointer

### Day 3-4: Human-in-the-Loop
- [ ] Add interrupt nodes
- [ ] Implement approval workflows
- [ ] Handle human input and resume

### Day 5-6: Streaming + Async
- [ ] Stream intermediate steps to UI
- [ ] Convert graph to async
- [ ] Handle concurrent tool calls

### Day 7: Integration Testing
- [ ] Write tests for each node
- [ ] Write integration test for full graph

**Deliverable**: Production-ready LangGraph agent with checkpointing + HITL.

---

## Week 5: CrewAI + AutoGen

**Goal**: Build multi-agent systems.

### Day 1-3: CrewAI
- [ ] Read [CrewAI guide](./02-frameworks/02-crewai/README.md)
- [ ] Build a researcher + writer crew
- [ ] Try hierarchical process

### Day 4-5: AutoGen/AG2
- [ ] Read [AutoGen guide](./02-frameworks/03-autogen-ag2/README.md)
- [ ] Build a coding assistant with UserProxyAgent

### Day 6: Comparison
- [ ] Same task in CrewAI vs AutoGen vs LangGraph
- [ ] Document trade-offs

### Day 7: LlamaIndex Agents
- [ ] Read [LlamaIndex guide](./02-frameworks/04-llamaindex-agents/README.md)
- [ ] Connect agent to a vector index

**Deliverable**: 2 multi-agent systems (CrewAI + one other).

---

## Week 6: Projects 1-3

**Goal**: Build real projects.

### Day 1-2: Research Assistant
- [ ] Read [project spec](./03-projects/01-research-assistant/README.md)
- [ ] Set up project structure
- [ ] Implement the crew

### Day 3-4: Coding Agent
- [ ] Read [project spec](./03-projects/02-coding-agent/README.md)
- [ ] Build the iterative loop
- [ ] Add error recovery

### Day 5-6: Support Agent
- [ ] Read [project spec](./03-projects/03-support-agent/README.md)
- [ ] Implement routing logic
- [ ] Add HITL for refunds

### Day 7: Review + Polish
- [ ] Add READMEs to all 3 projects
- [ ] Push to your GitHub

**Deliverable**: 3 working projects on your GitHub profile.

---

## Week 7: Projects 4-5

**Goal**: More complex agent types.

### Day 1-3: Data Analysis Agent
- [ ] Read [project spec](./03-projects/04-data-analysis-agent/README.md)
- [ ] Build SQL generation + execution
- [ ] Add chart generation

### Day 4-6: Browser Agent
- [ ] Read [project spec](./03-projects/05-browser-agent/README.md)
- [ ] Set up Playwright
- [ ] Build screenshot → action loop

### Day 7: Documentation
- [ ] Write blog posts about each project
- [ ] Add to portfolio

**Deliverable**: 5 projects on GitHub + blog posts.

---

## Week 8: Production + Capstone

**Goal**: Deploy and build the capstone.

### Day 1-2: Deployment
- [ ] Containerize a project with Docker
- [ ] Deploy to cloud (AWS/GCP)
- [ ] Set up domain/endpoint

### Day 3-4: Monitoring
- [ ] Integrate LangSmith or Langfuse
- [ ] Set up alerts
- [ ] Create a Grafana dashboard

### Day 5-6: Capstone Project
- [ ] Read [capstone spec](./03-projects/06-autonomous-workflow/README.md)
- [ ] Build the autonomous workflow system
- [ ] Add monitoring + evaluation

### Day 7: Polish + Launch
- [ ] Write final README
- [ ] Create demo video/GIF
- [ ] Share on LinkedIn/Twitter

**Deliverable**: Production-deployed capstone + portfolio update.

---

## Ongoing: Interview Prep

- [ ] Read [interview-prep.md](./05-resources/interview-prep.md)
- [ ] Practice 5 questions/week
- [ ] Build a "agent system design" cheat sheet
- [ ] Apply to jobs!

---

## Time Commitment

| Phase | Daily | Weekly | Duration |
|-------|-------|--------|----------|
| Weeks 1-2 (Foundations) | 2-3 hrs | 14-21 hrs | 2 weeks |
| Weeks 3-5 (Frameworks) | 3-4 hrs | 21-28 hrs | 3 weeks |
| Weeks 6-7 (Projects) | 4-5 hrs | 28-35 hrs | 2 weeks |
| Week 8 (Production) | 4-6 hrs | 28-42 hrs | 1 week |
| **Total** | | | **8 weeks** |

---

## Cost Estimate (India)

| Category | Estimated Cost (₹) |
|----------|-------------------|
| LLM API usage (learning) | ₹2,000-5,000 |
| Cloud deployment (hobby) | ₹500-1,000/month |
| Vector DB (free tier) | ₹0 |
| Monitoring (free tier) | ₹0 |
| **Total** | **₹2,500-6,000** |

Pro tip: Use Gemini API (cheapest in India) for prototyping. Switch to Claude/GPT-4o for production evaluation.

---

## Track Your Progress

Copy this checklist and check off as you go:

```markdown
- [ ] Week 1: Foundations
  - [ ] Day 1-2: Core concepts
  - [ ] Day 3-4: Architecture patterns
  - [ ] Day 5-6: Agent vs LLM vs RAG
  - [ ] Day 7: Types of agents
- [ ] Week 2: Patterns Deep Dive
- [ ] Week 3: LangGraph Basics
- [ ] Week 4: LangGraph Advanced
- [ ] Week 5: CrewAI + AutoGen
- [ ] Week 6: Projects 1-3
- [ ] Week 7: Projects 4-5
- [ ] Week 8: Production + Capstone
```

---

## After This Roadmap

1. **Contribute to OSS**: CrewAI, LangGraph, LlamaIndex — all welcome contributors
2. **Write about it**: Blog posts, Twitter threads, LinkedIn articles
3. **Speak at meetups**: IndiaAI, local Python/AI meetups
4. **Build in public**: Share your projects, get feedback
5. **Apply aggressively**: Target agent roles at startups and global remote

---

## Questions?

- Read the [full docs](./) in this repo
- Join [communities](./05-resources/communities.md)
- DM me: [prayagtushar](https://twitter.com/prayagcodes)

Now go build something. 🚀
