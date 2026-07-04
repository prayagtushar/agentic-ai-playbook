# Project 4: Data Analysis Agent

An agent that connects to databases, writes SQL queries, analyzes data, and generates visualizations.

**Framework**: LangGraph | **Pattern**: Tool Chaining | **Difficulty**: Intermediate

---

## Overview

Describe what you want to know about your data in natural language:

```
User: "What were the top 5 products by revenue last quarter?"

Agent:
→ Understands: needs product revenue data, last quarter filter, top 5
→ Generates: SQL query
→ Executes: Gets results
→ Analyzes: Identifies top performers
→ Visualizes: Creates bar chart
→ Responds: "Here are the top 5 products by revenue in Q4 2025..."
```

---

## Architecture

```mermaid
graph LR
    U[NL Query] --> UU[Understand]
    UU --> SQL[Generate SQL]
    SQL --> EX[Execute]
    EX --> AN[Analyze]
    AN --> VI[Visualize]
    VI --> RE[Respond]
    
    style UU fill:#e3f2fd
    style SQL fill:#e8f5e9
    style EX fill:#fff3e0
    style AN fill:#fce4ec
    style VI fill:#f3e5f5
    style RE fill:#c8e6c9
```

---

## Key Implementation

### SQL Generation Tool

```python
from langchain_openai import ChatOpenAI
from sqlalchemy import create_engine, text
import pandas as pd

llm = ChatOpenAI(model="gpt-4o")
engine = create_engine("postgresql://user:pass@localhost/db")

def get_schema() -> str:
    """Get database schema for context."""
    schema = """
    Tables:
    - orders (id, product_id, quantity, total, created_at)
    - products (id, name, category, price)
    - customers (id, name, email, created_at)
    """
    return schema

def generate_sql(question: str) -> str:
    """Generate SQL from natural language."""
    schema = get_schema()
    
    prompt = f"""Given this database schema:
    {schema}
    
    Generate a SQL query for: {question}
    
    Return ONLY the SQL query, no explanation."""
    
    response = llm.invoke(prompt)
    return response.content.strip().strip("`").replace("sql", "").strip()

def execute_sql(query: str) -> pd.DataFrame:
    """Execute SQL and return results."""
    with engine.connect() as conn:
        return pd.read_sql(text(query), conn)

def analyze_data(df: pd.DataFrame, question: str) -> str:
    """Analyze data and generate insights."""
    summary = df.describe().to_string()
    
    prompt = f"""Analyze this data and answer the question.
    
    Question: {question}
    
    Data Summary:
    {summary}
    
    Data (first 10 rows):
    {df.head(10).to_string()}
    
    Provide key insights in 2-3 sentences."""
    
    response = llm.invoke(prompt)
    return response.content

def create_visualization(df: pd.DataFrame, question: str) -> str:
    """Create a chart from data."""
    import matplotlib.pyplot as plt
    import base64
    from io import BytesIO
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    if len(df.columns) >= 2:
        df.plot(kind="bar", x=df.columns[0], y=df.columns[1], ax=ax)
    
    ax.set_title(question)
    plt.xticks(rotation=45)
    plt.tight_layout()
    
    # Save to base64
    buffer = BytesIO()
    plt.savefig(buffer, format="png")
    buffer.seek(0)
    image_base64 = base64.b64encode(buffer.read()).decode()
    plt.close()
    
    return image_base64
```

### LangGraph Pipeline

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

class AnalysisState(TypedDict):
    question: str
    sql: str
    results: str
    analysis: str
    chart: str
    response: str

def understand(state: AnalysisState) -> AnalysisState:
    return state

def generate_sql_node(state: AnalysisState) -> AnalysisState:
    sql = generate_sql(state["question"])
    return {**state, "sql": sql}

def execute_node(state: AnalysisState) -> AnalysisState:
    try:
        df = execute_sql(state["sql"])
        return {**state, "results": df.to_json()}
    except Exception as e:
        return {**state, "results": f"Error: {str(e)}"}

def analyze_node(state: AnalysisState) -> AnalysisState:
    df = pd.read_json(state["results"])
    analysis = analyze_data(df, state["question"])
    return {**state, "analysis": analysis}

def visualize_node(state: AnalysisState) -> AnalysisState:
    df = pd.read_json(state["results"])
    chart = create_visualization(df, state["question"])
    return {**state, "chart": chart}

# Build graph
workflow = StateGraph(AnalysisState)
workflow.add_node("understand", understand)
workflow.add_node("generate_sql", generate_sql_node)
workflow.add_node("execute", execute_node)
workflow.add_node("analyze", analyze_node)
workflow.add_node("visualize", visualize_node)

workflow.set_entry_point("understand")
workflow.add_edge("understand", "generate_sql")
workflow.add_edge("generate_sql", "execute")
workflow.add_edge("execute", "analyze")
workflow.add_edge("analyze", "visualize")
workflow.add_edge("visualize", END)

analysis_graph = workflow.compile()
```

---

## Running

```bash
cd 03-projects/04-data-analysis-agent
pip install -r requirements.txt
python src/main.py

# API
uvicorn src.api:app --reload

# Query
curl -X POST http://localhost:8000/analyze \
  -d '{"question": "Top 5 products by revenue last quarter"}'
```

---

## What You Learned

- SQL generation from natural language
- Database schema introspection
- Tool chaining in LangGraph
- Data visualization generation
- Structured data analysis

**Next**: Build the [Browser Agent](../05-browser-agent/) for web automation.
