# Security & Guardrails

> Agents have access to tools, data, and APIs. Security is not optional.

---

## Threat Model

| Threat | Impact | Mitigation |
|--------|--------|------------|
| **Prompt injection** | Agent executes attacker commands | Input validation, sandboxing |
| **Data exfiltration** | Sensitive data leaked | PII detection, output filtering |
| **Tool abuse** | Expensive/unauthorized tool use | Rate limiting, permission checks |
| **Jailbreak** | Bypass safety instructions | Multi-layer defenses |
| **DoS** | System overload | Rate limiting, resource quotas |

---

## Input Validation

```python
import re
from pydantic import BaseModel, validator

class AgentRequest(BaseModel):
    query: str
    user_id: str
    
    @validator('query')
    def validate_query(cls, v):
        # Block common injection patterns
        blocked_patterns = [
            r'ignore previous instructions',
            r'ignore all rules',
            r'system prompt',
            r'you are now',
            r'DAN mode',
        ]
        
        for pattern in blocked_patterns:
            if re.search(pattern, v, re.IGNORECASE):
                raise ValueError(f"Potentially unsafe query detected")
        
        # Length limit
        if len(v) > 4000:
            raise ValueError("Query too long (max 4000 characters)")
        
        return v
```

## PII Detection & Redaction

```python
import re

# Indian PII patterns
PII_PATTERNS = {
    'aadhaar': r'\b\d{4}\s?\d{4}\s?\d{4}\b',
    'pan': r'\b[A-Z]{5}\d{4}[A-Z]\b',
    'phone': r'\b(\+91[\s-]?)?[6-9]\d{9}\b',
    'email': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    'upi': r'\b[A-Za-z0-9._-]+@[A-Za-z]+\b',
}

def redact_pii(text: str) -> str:
    """Remove PII from text before sending to LLM."""
    redacted = text
    for pii_type, pattern in PII_PATTERNS.items():
        redacted = re.sub(pattern, f'[{pii_type}_REDACTED]', redacted)
    return redacted

# Usage
clean_query = redact_pii("My Aadhaar is 1234 5678 9012 and phone is 9876543210")
# Result: "My Aadhaar is [aadhaar_REDACTED] and phone is [phone_REDACTED]"
```

## Prompt Injection Defense

```python
class PromptInjectionDetector:
    """Multi-layer prompt injection detection."""
    
    def __init__(self):
        self.blocked_patterns = [
            r'ignore previous',
            r'forget (your|all) (instructions|rules)',
            r'new instructions?:',
            r'you are (now|no longer)',
            r'system:',
            r'admin:',
            r'owner:',
            r'<.*?>' ,  # HTML/JS injection
            r'javascript:',
            r'on\w+=',  # Event handlers
        ]
    
    def scan(self, text: str) -> dict:
        """Scan for injection attempts."""
        findings = []
        
        for pattern in self.blocked_patterns:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                findings.append({
                    "pattern": pattern,
                    "match": match.group(),
                    "position": match.span(),
                })
        
        return {
            "safe": len(findings) == 0,
            "findings": findings,
            "risk_score": min(len(findings) * 0.25, 1.0),
        }

# Usage
detector = PromptInjectionDetector()
result = detector.scan(user_input)
if not result["safe"]:
    raise SecurityError(f"Prompt injection detected: {result['findings']}")
```

## Output Filtering

```python
from transformers import pipeline

# Load content moderation model
moderator = pipeline("text-classification", model="unitary/toxic-bert")

def filter_output(text: str) -> str:
    """Filter toxic or unsafe content."""
    results = moderator(text[:512])  # Check first 512 chars
    
    for result in results:
        if result["label"] == "toxic" and result["score"] > 0.8:
            return "[Content filtered due to safety policy]"
    
    return text
```

## Tool Permission System

```python
from enum import Enum

class PermissionLevel(Enum):
    READ = "read"
    WRITE = "write"
    ADMIN = "admin"

class ToolGuard:
    """Guard tool access based on user permissions."""
    
    TOOL_PERMISSIONS = {
        "search_web": PermissionLevel.READ,
        "read_file": PermissionLevel.READ,
        "write_file": PermissionLevel.WRITE,
        "execute_code": PermissionLevel.ADMIN,
        "send_email": PermissionLevel.WRITE,
        "process_refund": PermissionLevel.ADMIN,
    }
    
    @classmethod
    def can_use(cls, user_level: PermissionLevel, tool_name: str) -> bool:
        required = cls.TOOL_PERMISSIONS.get(tool_name, PermissionLevel.ADMIN)
        
        hierarchy = {
            PermissionLevel.READ: 0,
            PermissionLevel.WRITE: 1,
            PermissionLevel.ADMIN: 2,
        }
        
        return hierarchy[user_level] >= hierarchy[required]

# Usage
if not ToolGuard.can_use(user.permission_level, "process_refund"):
    raise PermissionError("User cannot process refunds")
```

## Rate Limiting

```python
from fastapi import FastAPI, HTTPException
from fastapi_limiter import FastAPILimiter
import redis.asyncio as redis

app = FastAPI()

@app.on_event("startup")
async def startup():
    redis_client = redis.from_url("redis://localhost:6379")
    await FastAPILimiter.init(redis_client)

@app.post("/agent")
@limiter.limit("10/minute")  # 10 requests per minute per user
async def run_agent(request: Request):
    # ...
    pass
```

## Security Checklist

- [ ] Input validation on all user queries
- [ ] PII redaction before LLM calls
- [ ] Prompt injection detection
- [ ] Output content filtering
- [ ] Tool permission system
- [ ] Rate limiting per user
- [ ] Secrets in environment variables
- [ ] Audit logging for all actions
- [ ] HTTPS everywhere
- [ ] Regular security reviews

## Secret Management

```python
# NEVER do this
OPENAI_API_KEY = "sk-abc123"  # ❌ BAD

# ALWAYS do this
import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    openai_api_key: str
    database_url: str
    
    class Config:
        env_file = ".env"

settings = Settings()
# Key is loaded from environment, never in code
```
