# MCP Server Playbook

## Overview

MCP (Model Context Protocol) servers extend Claude Code with new tools. This playbook covers running servers on a Macbook and migrating to a Mac mini as a dedicated host.

---

## Part 1 — Macbook Setup

### Prerequisites

```bash
brew install node          # or: brew install nvm && nvm install --lts
brew install python@3.12   # or: brew install pyenv
brew install uv            # fast Python package manager — replaces pip for MCP servers
```

### Transport types

| Transport | How Claude connects | Best for |
|---|---|---|
| **stdio** | Claude spawns the process on demand | Local servers, no daemon needed |
| **SSE** | Claude connects to a running URL | Remote servers, persistent state |

### Registering servers — `~/.claude/settings.json`

**stdio (spawned on demand — simplest):**

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "~/projects"]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    },
    "skills-validator": {
      "command": "uv",
      "args": ["run", "--with", "python-frontmatter", "~/.llm-assets/mcp/skills_validator.py"]
    }
  }
}
```

**SSE (persistent server, survives Claude restarts):**

```json
{
  "mcpServers": {
    "skills": {
      "url": "http://localhost:3100/sse"
    }
  }
}
```

### Keeping SSE servers alive with launchd

For stdio servers: no daemon needed — Claude Code spawns and tears them down automatically.

For SSE servers, create `~/Library/LaunchAgents/com.user.mcp-<name>.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.mcp-skills</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/uv</string>
    <string>run</string>
    <string>/Users/leond/.llm-assets/mcp/skills_server.py</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>/tmp/mcp-skills.log</string>
  <key>StandardErrorPath</key><string>/tmp/mcp-skills.err</string>
</dict>
</plist>
```

```bash
launchctl load   ~/Library/LaunchAgents/com.user.mcp-skills.plist   # start
launchctl unload ~/Library/LaunchAgents/com.user.mcp-skills.plist   # stop
launchctl list | grep mcp                                            # status
```

### Recommended servers for current skills

| Server | Package | Transport | Skill it enhances |
|---|---|---|---|
| Filesystem | `@modelcontextprotocol/server-filesystem` | stdio | manage-skills: safer `references/` writes |
| Git | `mcp-server-git` (uvx) | stdio | git-commit: richer diff/log data |
| Bandit wrapper | custom Python | stdio | security: static analysis on staged files |
| Skills validator | custom Python | stdio | manage-skills: SKILL.md frontmatter check |

---

## Part 2 — Mac Mini Migration Roadmap

### Why migrate

| Macbook | Mac mini |
|---|---|
| Sleeps — interrupts long tasks | Always on |
| Shares CPU/RAM with dev work | Dedicated to serving |
| stdio only (local process) | Exposes SSE over LAN or VPN |

### Phase 1 — Same network, local SSE

1. Give Mac mini a static LAN IP or stable mDNS name (`mac-mini.local`).
2. Install servers on Mac mini; register them as launchd agents using the plist pattern above.
3. Update `~/.claude/settings.json` on Macbook:
   ```json
   "skills": { "url": "http://mac-mini.local:3100/sse" }
   ```
4. Firewall rule: allow port 3100 inbound on Mac mini from LAN only.

### Phase 2 — Secure remote access via Tailscale

1. Install Tailscale on both machines:
   ```bash
   brew install --cask tailscale
   ```
2. Join the same Tailnet. Mac mini gets a stable `100.x.x.x` address that works from anywhere.
3. Replace `mac-mini.local` with the Tailscale IP in `settings.json`.
4. No router port-forwarding needed — Tailscale handles the encrypted tunnel.

### Phase 3 — Centralised MCP proxy

Run one multiplexing proxy on Mac mini so Macbook makes a single SSE connection:

```
Macbook (Claude Code)
    │  SSE :3100
    ▼
Mac mini  ←  mcp-proxy
    ├── :3101  skills-validator  (Python/uv)
    ├── :3102  git server        (Node/npx)
    └── :3103  bandit wrapper    (Python/uv)
```

Use [`mcp-proxy`](https://github.com/sparfenyuk/mcp-proxy) or a minimal nginx SSE reverse proxy to multiplex.

### Migration checklist

- [ ] Static IP or mDNS name assigned on Mac mini
- [ ] launchd plists deployed and verified (`launchctl list | grep mcp`)
- [ ] LAN ports confirmed reachable from Macbook (`curl http://mac-mini.local:3100/sse`)
- [ ] `~/.claude/settings.json` updated to SSE URLs
- [ ] Logs tailed on first use (`tail -f /tmp/mcp-*.log`)
- [ ] Tailscale installed and joined (Phase 2)
- [ ] Proxy configured with routing rules (Phase 3)
