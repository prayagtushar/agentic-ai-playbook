# Agent Template

> A template for implementing a single agent with best practices.

---

## Base Agent Class

```python
# src/base_agent.py
from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional
from pydantic import BaseModel
import structlog

logger = structlog.get_logger()

class Tool(BaseModel):
    """Tool definition."""
    name: str
    description: str
    func: callable
    
class AgentState(BaseModel):
    """Agent state."""
    query: str
    history: List[Dict] = []
    tool_calls: List[Dict] = []
    response: Optional[str] = None
    status: str = "idle"  # idle, running, done, error

class BaseAgent(ABC):
    """Base class for all agents."""
    
    def __init__(self, name: str, llm_client, tools: List[Tool] = None):
        self.name = name
        self.llm = llm_client
        self.tools = {t.name: t for t in (tools or [])}
        self.logger = logger.bind(agent=name)
    
    @abstractmethod
    async def run(self, query: str) -> str:
        """Execute the agent."""
        pass
    
    async def use_tool(self, name: str, params: Dict) -> Any:
        """Execute a tool with logging."""
        self.logger.info("tool_call", tool=name, params=params)
        
        if name not in self.tools:
            raise ValueError(f"Unknown tool: {name}")
        
        try:
            result = await self.tools[name].func(**params)
            self.logger.info("tool_result", tool=name, result=str(result)[:100])
            return result
        except Exception as e:
            self.logger.error("tool_error", tool=name, error=str(e))
            raise
    
    def log_state(self, state: AgentState):
        """Log current state."""
        self.logger.debug(
            "agent_state",
            status=state.status,
            history_length=len(state.history),
            tool_calls=len(state.tool_calls),
        )
```

## ReAct Agent Implementation

```python
# src/react_agent.py
import json
from typing import List
from base_agent import BaseAgent, Tool, AgentState

class ReActAgent(BaseAgent):
    """ReAct agent implementation."""
    
    def __init__(self, llm_client, tools: List[Tool], max_steps: int = 5):
        super().__init__("ReActAgent", llm_client, tools)
        self.max_steps = max_steps
    
    async def run(self, query: str) -> str:
        state = AgentState(query=query, status="running")
        
        for step in range(self.max_steps):
            self.log_state(state)
            
            # Build prompt
            prompt = self._build_prompt(state)
            
            # Get LLM response
            response = await self.llm.ainvoke(prompt)
            state.history.append({"step": step, "thought": response.content})
            
            # Parse action
            action = self._parse_action(response.content)
            
            if action["type"] == "final":
                state.response = action["content"]
                state.status = "done"
                return state.response
            
            if action["type"] == "tool":
                result = await self.use_tool(
                    action["name"],
                    action["params"]
                )
                state.tool_calls.append({
                    "tool": action["name"],
                    "result": str(result),
                })
        
        state.status = "error"
        return "Max steps reached without conclusion"
    
    def _build_prompt(self, state: AgentState) -> str:
        tools_desc = "\n".join(
            f"- {name}: {tool.description}"
            for name, tool in self.tools.items()
        )
        
        history = "\n".join(
            f"Step {h['step']}: {h['thought']}"
            for h in state.history
        )
        
        return f"""You are a ReAct agent. Solve the task step by step.

Available tools:
{tools_desc}

Task: {state.query}

History:
{history}

Respond in this format:
THOUGHT: your reasoning
ACTION: tool_name | {{"param": "value"}}
or
THOUGHT: your reasoning
FINAL: your final answer"""
    
    def _parse_action(self, text: str) -> dict:
        """Parse agent response into action."""
        if "FINAL:" in text:
            return {
                "type": "final",
                "content": text.split("FINAL:")[1].strip(),
            }
        
        if "ACTION:" in text:
            action_part = text.split("ACTION:")[1].strip()
            name, params_str = action_part.split("|", 1)
            return {
                "type": "tool",
                "name": name.strip(),
                "params": json.loads(params_str.strip()),
            }
        
        return {"type": "unknown", "content": text}
```

## Tool Definition Pattern

```python
# src/tools.py
from base_agent import Tool

async def search_web(query: str) -> str:
    """Search the web."""
    # Implementation
    return f"Results for: {query}"

async def calculate(expression: str) -> float:
    """Evaluate math expression."""
    return eval(expression)

def get_tools() -> list:
    """Get all available tools."""
    return [
        Tool(name="search", description="Search the web", func=search_web),
        Tool(name="calculate", description="Calculate expressions", func=calculate),
    ]
```

## Test Template

```python
# tests/test_agent.py
import pytest
from src.react_agent import ReActAgent
from src.tools import get_tools

@pytest.fixture
def agent(mock_llm):
    return ReActAgent(llm_client=mock_llm, tools=get_tools())

@pytest.mark.asyncio
async def test_agent_run(agent):
    result = await agent.run("What is 2+2?")
    assert result is not None
    assert len(result) > 0

@pytest.mark.asyncio
async def test_agent_tool_call(agent):
    await agent.run("Search for Python")
    assert len(agent.state.tool_calls) > 0

@pytest.mark.asyncio
async def test_agent_max_steps(mock_llm):
    agent = ReActAgent(llm_client=mock_llm, tools=get_tools(), max_steps=2)
    result = await agent.run("Complex task")
    assert "Max steps" in result or result is not None
```

## Usage

```python
from langchain_openai import ChatOpenAI
from src.react_agent import ReActAgent
from src.tools import get_tools
import asyncio

async def main():
    llm = ChatOpenAI(model="gpt-4o-mini")
    agent = ReActAgent(llm, get_tools())
    
    result = await agent.run("Research AI agents and summarize")
    print(result)

asyncio.run(main())
```

## Key Features

- **Type-safe**: Pydantic models for state and tools
- **Structured logging**: Every action logged
- **Error handling**: Try/catch around tool calls
- **Testable**: Abstract base class, easy to mock
- **Extensible**: Inherit from BaseAgent for custom agents
