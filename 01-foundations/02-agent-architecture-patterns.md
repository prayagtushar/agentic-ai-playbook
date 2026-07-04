# Agent Architecture Patterns

Agents can be organized in different ways depending on the problem. These 6 patterns cover 95% of production agent systems.

---

## 1. ReAct (Reasoning + Acting)

The foundational pattern. The agent **reasons** about what to do, then **acts** by calling a tool.

```mermaid
graph TD
    A[User Query] --> B[Reason: What do I need?]
    B --> C[Act: Call Tool]
    C --> D[Observe: Tool Result]
    D --> E{Done?}
    E -->|No| B
    E -->|Yes| F[Final Answer]
    
    style B fill:#e3f2fd
    style C fill:#e8f5e9
    style D fill:#fff3e0
    style F fill:#c8e6c9
```

**When to use**: Simple tasks with clear tool sequences (search → summarize, calculate → format).

**Pros**: Simple, interpretable, works with any LLM.
**Cons**: Can get stuck in loops, no parallel execution.

---

## 2. Plan-and-Execute

The agent first creates a **plan**, then executes each step systematically.

```mermaid
graph TD
    A[User Query] --> B[Planner: Create Step-by-Step Plan]
    B --> C[Step 1]
    C --> D[Step 2]
    D --> E[Step 3]
    E --> F[Aggregator: Combine Results]
    F --> G[Final Answer]
    
    style B fill:#e3f2fd
    style F fill:#c8e6c9
```

**When to use**: Complex multi-step tasks where planning upfront saves tokens (research reports, data pipelines).

**Pros**: Efficient, predictable cost, easy to debug.
**Cons**: Rigid — if a step fails, the whole plan may need revision.

---

## 3. Multi-Agent Collaboration

Multiple agents with **different roles** work together, like a team.

```mermaid
graph TB
    subgraph "Crew"
        A[Research Agent<br/>Finds information]
        B[Writer Agent<br/>Drafts content]
        C[Editor Agent<br/>Reviews & polishes]
    end
    
    User[User Request] --> A
    A --> B
    B --> C
    C --> User
    
    style A fill:#e3f2fd
    style B fill:#e8f5e9
    style C fill:#fff3e0
```

**When to use**: Tasks that naturally decompose into specialist roles (content creation, research, code review).

**Pros**: Specialized expertise per agent, parallel work possible.
**Cons**: Coordination overhead, more tokens, complex debugging.

**Framework**: CrewAI is built for this pattern.

---

## 4. Hierarchical Agents

A **manager agent** delegates to **worker agents**, like an org chart.

```mermaid
graph TB
    Manager[Manager Agent<br/>Decides what to do]
    
    Manager --> Worker1[Worker: Search]
    Manager --> Worker2[Worker: Calculate]
    Manager --> Worker3[Worker: Format]
    
    Worker1 --> Manager
    Worker2 --> Manager
    Worker3 --> Manager
    
    Manager --> Output[Final Output]
    
    style Manager fill:#f3e5f5
    style Worker1 fill:#e3f2fd
    style Worker2 fill:#e8f5e9
    style Worker3 fill:#fff3e0
```

**When to use**: Complex workflows where a coordinator needs to dynamically assign work (customer support routing, project management).

**Pros**: Dynamic task assignment, fault isolation, easy to scale.
**Cons**: Single point of failure (manager), latency from coordination.

**Framework**: CrewAI (hierarchical process), LangGraph (conditional routing).

---

## 5. Agent Swarms

Agents are **peers** — no manager. They communicate via a shared message bus.

```mermaid
graph TB
    subgraph "Swarm"
        A[Agent A]
        B[Agent B]
        C[Agent C]
        D[Agent D]
    end
    
    A <--> B
    B <--> C
    C <--> D
    D <--> A
    A <--> C
    B <--> D
    
    style A fill:#e3f2fd
    style B fill:#e8f5e9
    style C fill:#fff3e0
    style D fill:#fce4ec
```

**When to use**: Distributed problem solving, emergent behavior desired, no single coordinator needed.

**Pros**: Fault tolerant, emergent intelligence, highly parallel.
**Cons**: Unpredictable, hard to debug, token-heavy.

**Framework**: AutoGen (group chat), custom implementations.

---

## 6. Human-in-the-Loop (HITL)

The agent **pauses and asks a human** at critical decision points.

```mermaid
graph TD
    A[User Query] --> B[Agent Processes]
    B --> C{Critical Decision?}
    C -->|Yes| D[Pause & Ask Human]
    D --> E[Human Input]
    E --> B
    C -->|No| F[Continue Autonomously]
    F --> G{Done?}
    G -->|No| B
    G -->|Yes| H[Final Answer]
    
    style D fill:#ffebee
    style E fill:#c8e6c9
    style H fill:#c8e6c9
```

**When to use**: High-stakes decisions (financial transactions, medical advice, content approval), learning phase of agent deployment.

**Pros**: Safety, builds trust, handles edge cases.
**Cons**: Latency, requires human availability.

**Framework**: LangGraph (native HITL with checkpoints), CrewAI (task-level human input).

---

## Pattern Selection Guide

```mermaid
graph TD
    Q[What's your task?]
    
    Q -->|Single agent, tools| A[ReAct]
    Q -->|Multi-step, predictable| B[Plan-and-Execute]
    Q -->|Team of specialists| C[Multi-Agent Collaboration]
    Q -->|Dynamic delegation| D[Hierarchical]
    Q -->|Distributed, emergent| E[Agent Swarms]
    Q -->|High-stakes| F[Human-in-the-Loop]
    
    style A fill:#e3f2fd
    style B fill:#e8f5e9
    style C fill:#fff3e0
    style D fill:#fce4ec
    style E fill:#f3e5f5
    style F fill:#ffebee
```

| Pattern | Complexity | Token Cost | Latency | Best For |
|---------|-----------|------------|---------|----------|
| ReAct | Low | Medium | Medium | Simple tool use |
| Plan-and-Execute | Medium | Low | Medium | Predictable workflows |
| Multi-Agent | Medium | High | High | Specialist teams |
| Hierarchical | High | High | High | Dynamic coordination |
| Swarms | High | Very High | Medium | Distributed problems |
| HITL | Medium | Medium | Very High | High-stakes decisions |

---

## Combining Patterns

Real systems often combine patterns:

- **Hierarchical + HITL**: Manager delegates, human approves final output
- **Plan-and-Execute + Multi-Agent**: Plan created centrally, executed by specialist agents
- **ReAct + HITL**: Simple agent that asks for clarification when uncertain

Start with **ReAct** for simple agents, add **HITL** for safety, then scale to **Multi-Agent** or **Hierarchical** as complexity grows.
