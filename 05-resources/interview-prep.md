# Interview Preparation

> Agent roles are new. Interviewers are still figuring out what to ask. Be prepared for everything.

---

## Conceptual Questions (and Answers)

### Q1: What is an AI Agent? How is it different from an LLM?
**A**: An LLM generates text. An agent is an LLM + tools + memory + planning. An agent can take actions (call APIs, query databases), remember context across sessions, and plan multi-step tasks. An LLM just responds; an agent acts.

### Q2: Explain the ReAct pattern.
**A**: ReAct = Reasoning + Acting. The agent alternates between reasoning (thinking about what to do) and acting (calling tools). After each action, it observes the result and decides the next step. This loop continues until the task is complete.

### Q3: When would you use multi-agent vs single-agent?
**A**: Single-agent for simple, sequential tasks. Multi-agent when:
- Tasks require different expertise areas
- Work can be parallelized
- Quality requires review/checking
- Tasks naturally decompose into roles (researcher, writer, editor)

### Q4: How do you handle agent failures?
**A**: Multiple layers:
1. **Retry**: Exponential backoff for transient failures
2. **Fallback**: Alternative tools/models
3. **Decomposition**: Break complex tasks into simpler ones
4. **HITL**: Escalate to humans when stuck
5. **Circuit breaker**: Stop calling failing tools
6. **Checkpointing**: Resume from last good state

### Q5: How do you prevent prompt injection?
**A**: Defense in depth:
1. Input validation and sanitization
2. Block known injection patterns
3. PII redaction before LLM calls
4. Output filtering
5. Tool permission system
6. Rate limiting per user
7. Regular security audits

### Q6: How do you make agents cost-effective?
**A**: 
1. Model routing: Cheap models for simple tasks
2. Caching: Redis for repeated queries
3. Token optimization: Shorter prompts, summarization
4. Budget enforcement: Hard limits per request/user
5. Async execution: Parallel tool calls
6. Monitoring: Track cost per request

### Q7: Explain checkpointing in LangGraph.
**A**: Checkpoints save the agent's state after each step. If the process crashes, the agent can resume from the last checkpoint. This enables:
- Crash recovery
- Human-in-the-loop (pause and resume)
- Time-travel debugging
- Long-running workflows

### Q8: What is human-in-the-loop (HITL)?
**A**: HITL is a pattern where the agent pauses at critical decision points and waits for human approval. Used for:
- High-stakes decisions (refunds, transactions)
- Uncertain situations
- Learning phase of deployment
- Building trust with users

### Q9: How do you evaluate agent performance?
**A**: Multiple dimensions:
- Correctness: LLM-as-a-Judge, ground truth comparison
- Latency: p50, p95 response times
- Cost: Per-request cost tracking
- Safety: Guardrail effectiveness
- Human feedback: User ratings

### Q10: What frameworks have you used? Compare them.
**A**: (Have a comparison ready)
- **LangGraph**: Best for complex stateful workflows, production-ready
- **CrewAI**: Fastest for role-based multi-agent prototypes
- **AutoGen**: Good for conversational multi-agent
- **CrewAI vs LangGraph**: CrewAI for quick multi-agent, LangGraph for production control

---

## Coding Questions

### Q11: Implement a simple ReAct agent.

```python
def react_agent(query: str, tools: dict, llm, max_steps: int = 5) -> str:
    """Implement a ReAct agent from scratch."""
    history = [f"Task: {query}"]
    
    for step in range(max_steps):
        # Reason
        prompt = f"""History: {' | '.join(history)}
        Available tools: {', '.join(tools.keys())}
        Decide: ACTION: tool_name input | FINAL: answer"""
        
        response = llm.invoke(prompt).content.strip()
        
        if response.startswith("FINAL:"):
            return response.replace("FINAL:", "").strip()
        
        if response.startswith("ACTION:"):
            parts = response.replace("ACTION:", "").strip().split(" ", 1)
            tool_name = parts[0]
            tool_input = parts[1] if len(parts) > 1 else ""
            
            # Act
            if tool_name in tools:
                observation = tools[tool_name](tool_input)
                history.append(f"{tool_name}({tool_input}) -> {observation}")
            else:
                history.append(f"Error: Unknown tool {tool_name}")
    
    return "Max steps reached"
```

### Q12: Design a multi-agent system for customer support.

```python
# High-level design
def support_system():
    """Design a customer support multi-agent system."""
    
    # Router: Classifies intent
    router = Agent(role="router", tools=[intent_classifier])
    
    # Specialized agents
    order_agent = Agent(role="order_specialist", tools=[order_db, tracking_api])
    refund_agent = Agent(role="refund_specialist", tools=[refund_processor], hitl=True)
    faq_agent = Agent(role="faq_specialist", tools=[vector_db])
    
    # Escalation
    human_agent = HumanAgent()
    
    # Workflow
    def handle(query):
        intent = router.classify(query)
        
        if intent == "order":
            return order_agent.handle(query)
        elif intent == "refund":
            return refund_agent.handle(query)  # May pause for HITL
        elif intent == "faq":
            return faq_agent.handle(query)
        else:
            return human_agent.handle(query)
    
    return handle
```

### Q13: Implement tool error handling.

```python
from tenacity import retry, stop_after_attempt, wait_exponential

class ToolExecutor:
    """Execute tools with retry and fallback."""
    
    def __init__(self, tools: dict, fallbacks: dict = None):
        self.tools = tools
        self.fallbacks = fallbacks or {}
    
    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=4, max=10),
        reraise=True,
    )
    def execute(self, tool_name: str, params: dict) -> str:
        try:
            tool = self.tools[tool_name]
            return tool(**params)
        except Exception as e:
            # Try fallback
            if tool_name in self.fallbacks:
                fallback = self.fallbacks[tool_name]
                return fallback(**params)
            raise ToolExecutionError(f"{tool_name} failed: {e}")
```

---

## System Design Questions

### Q14: Design an agent that can book flights.

**Answer outline**:
1. **Requirements**: Search flights, compare prices, book, handle errors
2. **Architecture**: Router → Search Agent → Comparison Agent → Booking Agent
3. **Tools**: Flight API, payment gateway, email service
4. **Safety**: HITL for booking confirmation, idempotent bookings
5. **State**: User preferences, search results, booking state
6. **Error handling**: API failures, payment failures, seat unavailability
7. **Monitoring**: Track booking success rate, API latency

### Q15: How would you scale an agent system to 10K users?

**Answer outline**:
1. **Horizontal scaling**: Multiple agent instances behind load balancer
2. **Async processing**: Queue requests with Celery + Redis
3. **Caching**: Cache frequent queries and tool results
4. **Connection pooling**: Reuse LLM API connections
5. **Rate limiting**: Per-user limits to prevent abuse
6. **Database**: Read replicas for agent state
7. **Monitoring**: Track per-user costs and latency

---

## Company-Specific Prep

### TCS / Infosys / Wipro
- Focus on: Enterprise patterns, security, compliance
- Questions: Integration with existing systems, data privacy
- Prepare: Architecture diagrams, security considerations

### Startups
- Focus on: Speed, iteration, practical implementation
- Questions: Build an agent in 30 minutes, debugging
- Prepare: Working code, GitHub projects

### Global Remote (US/EU)
- Focus on: System design, scale, best practices
- Questions: Design a system for X users, handle failures
- Prepare: Strong system design skills, English communication

---

## Salary Negotiation (India)

### Know Your Worth
| Experience | Expected Range (₹ LPA) |
|-----------|----------------------|
| 0-1 years | 9-15 |
| 1-3 years | 15-25 |
| 3-5 years | 25-40 |
| 5+ years | 40-60+ |

### Negotiation Tips
1. **Have multiple offers**: Creates leverage
2. **Show your projects**: GitHub speaks louder than words
3. **Know market rates**: Use Levels.fyi, Glassdoor
4. **Negotiate total comp**: Base + equity + benefits
5. **Don't accept first offer**: Always counter

### Script
> "Thank you for the offer. Based on my research of market rates for agent engineers with my experience, and considering the projects I've built (reference your GitHub), I was expecting a package closer to ₹X LPA. Is there flexibility?"

---

## Portfolio Tips

What impresses interviewers:
1. **Working demos**: Not just READMEs
2. **Production patterns**: Docker, tests, CI/CD
3. **Unique projects**: Not just tutorial copies
4. **Blog posts**: Show deep understanding
5. **Contributions**: OSS contributions
6. **Metrics**: "Reduced cost by 40%" beats "I built an agent"

---

## Quick Reference Card

Keep this handy before interviews:

```
Agent = LLM + Tools + Memory + Planning

Patterns: ReAct, Plan-and-Execute, Multi-Agent, Hierarchical, HITL

Frameworks: LangGraph (production), CrewAI (prototyping), AutoGen (conversational)

Production: Docker, K8s, Langfuse, LLM-as-a-Judge, Guardrails

Key Concepts: Tool use, Checkpoints, State management, Streaming

India Market: ₹9-15 LPA fresher, high demand, low supply
```
