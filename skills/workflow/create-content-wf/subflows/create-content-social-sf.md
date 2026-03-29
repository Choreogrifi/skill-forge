# Social Media Post Subflow

Guides the user through creating a social media post for any platform.
Handles platform-specific formatting, character limits, and tone requirements.

## Supported Platforms

| Platform | Max length | Format notes |
|---|---|---|
| X / Twitter | 280 chars | Short, punchy; threads for longer ideas |
| LinkedIn | 3000 chars | Professional tone; line breaks for readability; hashtags at end |
| Instagram | 2200 chars | Visual-first; caption supports the image; hashtags |
| Threads | 500 chars | Conversational; close to X in tone |
| Bluesky | 300 chars | Open/tech-friendly audience; link cards supported |

## Workflow

### 1. Gather Post Details

Ask the user:

```
Social post details:
  Platform(s): [X / LinkedIn / Instagram / Threads / Bluesky / All]
  Topic or message:
  Audience (who will read this?):
  Tone: professional / casual / technical / motivational / other
  Include image or video? (yes — describe it / no):
  Call to action (what should the reader do?):
  Any hashtags or mentions to include?
```

### 2. Draft the Post

If the user selected multiple platforms, draft a separate version for each.
Adapt length, tone, and structure to each platform's norms.

Present each draft clearly labelled:

```
── X / Twitter ──────────────────────────
<draft — 280 chars max>

── LinkedIn ─────────────────────────────
<draft>

── [platform] ───────────────────────────
<draft>
─────────────────────────────────────────
Approve all / edit specific / cancel?
```

### 3. Refine on Request

If the user wants edits to a specific platform version, apply and re-present that version only.
Ask for final approval before completing.

### 4. Output

On approval, present the final version(s) ready to copy-paste.
Include a reminder for any manual steps: adding images, tagging people, scheduling.

## Handling Accounts for a New Brand

If the user does not have an account on a platform yet, provide a brief account creation guide:

```
Setting up <platform>:
  1. Visit <platform URL>
  2. Sign up with your business email
  3. Choose a username that matches your brand (e.g. @Choreogrifi)
  4. Complete your profile: photo, bio, website link
  5. Enable two-factor authentication
```

## Guidelines

- Never generate content that makes false claims, misrepresents the user, or plagiarises other creators.
- For LinkedIn, avoid excessive emoji use and corporate buzzwords — authenticity outperforms polish.
- For X/Twitter, if the post naturally exceeds 280 chars, suggest a thread structure.
- Always remind the user to proofread before posting — this draft is a starting point.
