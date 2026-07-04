# Projects

Six portfolio-grade projects that demonstrate every major agent pattern. Build them in order of increasing difficulty.

---

## Project Index

| # | Project | Framework | Pattern | Difficulty | Est. Time |
|---|---------|-----------|---------|------------|-----------|
| 1 | [Research Assistant](./01-research-assistant/) | CrewAI | Hierarchical multi-agent | Intermediate | 3-4 days |
| 2 | [Coding Agent](./02-coding-agent/) | LangGraph | Iterative loop + recovery | Advanced | 5-7 days |
| 3 | [Support Agent](./03-support-agent/) | LangGraph | Conditional routing + HITL | Intermediate | 4-5 days |
| 4 | [Data Analysis Agent](./04-data-analysis-agent/) | LangGraph | Tool chaining (SQL + viz) | Intermediate | 3-4 days |
| 5 | [Browser Agent](./05-browser-agent/) | LangGraph + Vision | Web automation | Advanced | 5-6 days |
| 6 | [Autonomous Workflow](./06-autonomous-workflow/) | Mixed | Full production system | Expert | 10-14 days |

---

## Learning Path

### Beginner Path (First 3)
Start here if you're new to agents. Each builds on the previous.

1. **Research Assistant** → Learn multi-agent collaboration
2. **Support Agent** → Learn routing and human-in-the-loop
3. **Data Analysis Agent** → Learn tool chaining

### Advanced Path (Last 3)
Build these after completing the beginner path.

4. **Coding Agent** → Learn iterative loops and error recovery
5. **Browser Agent** → Learn vision + web automation
6. **Autonomous Workflow** → Learn everything integrated

---

## Evaluation Rubric

A project is "complete" when:

- [ ] Architecture diagram drawn and documented
- [ ] Core agent logic implemented and tested
- [ ] At least 2 tools integrated
- [ ] Error handling (retry, fallback) implemented
- [ ] README with setup instructions
- [ ] Docker support (Dockerfile + docker-compose)
- [ ] Pushed to GitHub with clean commit history
- [ ] Demo recording or screenshots

---

## Tips for Success

1. **Don't copy-paste**: Type out the code. You'll understand it better.
2. **Modify**: After making it work, change something. Break it. Fix it.
3. **Document**: Write about what you learned. Blog posts > comments.
4. **Ship**: A working demo beats a perfect architecture.
5. **Show**: Share on LinkedIn, Twitter, Discord. Get feedback.

---

## Tech Stack Common to All Projects

| Layer | Technology |
|-------|-----------|
| Language | Python 3.11+ |
| Web Framework | FastAPI |
| Agent Framework | LangGraph / CrewAI |
| LLM | OpenAI GPT-4o / Claude Sonnet |
| Database | PostgreSQL + pgvector |
| Cache | Redis |
| Deployment | Docker + Docker Compose |
| Monitoring | Langfuse (self-hosted) |

Each project README has its specific stack.

---

## Getting Started

Pick a project, read its README, and start building:

```bash
cd 03-projects/01-research-assistant
# Follow the README instructions
```

Happy building! 🚀
