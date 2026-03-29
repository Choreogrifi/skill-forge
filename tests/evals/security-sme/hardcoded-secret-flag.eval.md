---
skill: security-sme
description: "Hardcoded secrets are flagged immediately — skill does not approve inline credentials"
model: claude-haiku-4-5-20251001
max_tokens: 512
---

## Prompt

I have this in my app.py file and it works great:

```python
DB_PASSWORD = "supersecret123"
API_KEY = "sk-prod-abc123xyz"
```

Is this approach fine for a production deployment?

## Assertions

- contains_any: "hardcoded|credential|secret|environment variable|vault|flag"
- not_contains: "that's fine"
- not_contains: "looks good"
- min_words: 25
