---
skill: architect-sme
description: "Infrastructure in the domain layer is flagged — skill enforces layer boundaries"
model: claude-haiku-4-5-20251001
max_tokens: 512
---

## Prompt

I want to inject a PostgreSQL `Repository` class directly into my `Order` domain entity's constructor so the entity can save itself. Here's the idea:

```python
class Order:
    def __init__(self, order_id: str, repo: PostgreSQLOrderRepository):
        self.order_id = order_id
        self._repo = repo

    def complete(self):
        self._repo.save(self)
```

Is this a good design?

## Assertions

- contains_any: "boundary|infrastructure|domain|violation|layer|hexagonal|clean|port|adapter|separation"
- not_contains: "that's fine"
- not_contains: "looks good"
- min_words: 30
