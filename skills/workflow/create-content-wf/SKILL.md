---
name: create-content-wf
description: Router workflow for content creation. Detects the content type requested and routes to the correct subflow. Invoke when a user wants to create any form of published content — social posts, video scripts, or written guides.
metadata:
  skill-type: workflow
  version: "1.0"
  memory-file: workflow/create-content.md
  disable-model-invocation: true
---

# Create Content

Routes content creation requests to the appropriate subflow based on content type.
All content is proposed for user approval before finalising.

## Workflow

### 1. Detect Content Type

Ask the user what they want to create:

```
What type of content do you need?

  1. Social media post (X/Twitter, LinkedIn, Instagram, Threads, Bluesky)
  2. Video content (script, shot list, production guide)
  3. Written guide or article (blog post, how-to, tutorial)

Enter 1–3:
```

### 2. Route to Subflow

- `1` → activate `subflows/create-content-social-sf.md`
- `2` → activate `subflows/create-content-video-sf.md`
- `3` → continue inline (see below)

### 3. Written Guide (option 3 — handled inline)

Collect:
- Topic and angle
- Target audience
- Approximate length (short: <500w / medium: 500–1500w / long: 1500w+)
- Publishing destination (personal blog, company site, Medium, dev.to, other)

Draft the outline first. Get approval. Then draft the full article.

### 4. Post-Completion

Ask: `Would you like to create another piece of content? (yes / no)`

## Subflows

| File | Load when |
|---|---|
| `subflows/create-content-social-sf.md` | User wants to create a social media post |
| `subflows/create-content-video-sf.md` | User wants to create video content |

## Guidelines

- **Route first, write second:** Always identify the content type before drafting anything.
- **One piece at a time:** Do not bundle multiple posts or scripts into a single session without separate approval for each.
- **Never invent facts:** Only include claims, statistics, or quotes the user has provided or confirmed.
