# README.md — 2026 Standard Template

SEO-optimised layout for maximum discoverability on GitHub, GitLab, and web search.

---

```markdown
<!-- SOCIAL PREVIEW: Set a 1280×640 repository social image in repo Settings → Social preview -->

<div align="center">

<!-- PROJECT LOGO — replace or remove if no logo -->
<!-- <img src="docs/assets/logo.svg" alt="Logo" width="120" /> -->

# <!-- PROJECT NAME -->

<!-- One-line tagline: what it does + who it's for. Use natural keywords. -->
**<!-- tagline -->**

<!-- BADGES ROW — only include badges you have confirmed are available -->
<!-- CI/CD status -->
[![CI](<!-- ci-badge-url -->)](<!-- ci-workflow-url -->)
<!-- Test coverage -->
[![Coverage](<!-- coverage-badge-url -->)](<!-- coverage-report-url -->)
<!-- Package version -->
[![Version](<!-- version-badge-url -->)](<!-- package-url -->)
<!-- License -->
[![License](<!-- license-badge-url -->)](LICENSE)
<!-- Latest release -->
[![Release](<!-- release-badge-url -->)](<!-- releases-url -->)

<!-- QUICK NAVIGATION -->
[Demo](<!-- demo-url -->) · [Docs](<!-- docs-url -->) · [Report Bug](<!-- issues-url -->) · [Request Feature](<!-- issues-url -->)

</div>

---

## Overview

<!-- 2–3 sentences. Lead with the problem this project solves, then what it does, then why it's better.
     Use the keywords your target audience would search for. -->
> TODO: 2–3 sentence project overview with searchable keywords.

---

## Features

<!-- Up to 5 key features. Start each with a relevant emoji for visual scanning. -->
- ✨ **<!-- Feature 1 -->** — <!-- brief description -->
- ⚡ **<!-- Feature 2 -->** — <!-- brief description -->
- 🔒 **<!-- Feature 3 -->** — <!-- brief description -->
- 📦 **<!-- Feature 4 -->** — <!-- brief description -->
- 🌐 **<!-- Feature 5 -->** — <!-- brief description -->

---

## Tech Stack

<!-- Badge grid — use https://shields.io or https://img.shields.io for custom badges -->
![<!-- Language -->](https://img.shields.io/badge/<!-- language -->-<!-- version -->-<!-- colour -->?logo=<!-- logo-slug -->)
![<!-- Framework -->](https://img.shields.io/badge/<!-- framework -->-<!-- version -->-<!-- colour -->?logo=<!-- logo-slug -->)
![<!-- Cloud -->](https://img.shields.io/badge/<!-- cloud -->-<!-- service -->-<!-- colour -->?logo=<!-- logo-slug -->)

---

## Quick Start

> **Prerequisites:** <!-- list runtime, tools, accounts needed — e.g. Node.js ≥ 20, Docker, GCP project -->

```bash
# 1. Clone the repository
git clone <!-- repo-url -->
cd <!-- repo-name -->

# 2. Install dependencies
<!-- install command -->

# 3. Configure environment
cp .env.example .env
# Edit .env with your values

# 4. Run
<!-- run command -->
```

---

## Installation

<!-- Full installation steps for non-trivial setups. Link to docs if too long. -->
> TODO: Detailed installation steps.

---

## Usage

<!-- One or more real usage examples with code blocks. Show the most common use case first. -->

```<!-- language -->
<!-- usage example -->
```

<!-- Add more examples as needed:
### Example: <!-- title -->
```<!-- language -->
<!-- example -->
```
-->

---

## Configuration

All configuration is supplied via environment variables. Copy `.env.example` to `.env` to get started.

| Variable | Required | Default | Description |
|---|---|---|---|
| `<!-- VAR_NAME -->` | ✅ | — | <!-- description --> |
| `<!-- VAR_NAME -->` | ⬜ | `<!-- default -->` | <!-- description --> |

---

## Project Structure

```
<!-- repo-name -->/
├── <!-- dir-or-file -->    # <!-- purpose -->
├── <!-- dir-or-file -->    # <!-- purpose -->
└── <!-- dir-or-file -->    # <!-- purpose -->
```

---

## API Reference

<!-- Remove this section if not applicable -->
> TODO: Link to API docs or inline key endpoints here.

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

```bash
# Fork → clone → create a branch
git checkout -b feat/your-feature

# Make changes, commit, push
git push origin feat/your-feature

# Open a pull request against main
```

---

## Roadmap

<!-- Link to GitHub Projects board or list upcoming milestones -->
- [ ] <!-- planned feature or improvement -->
- [ ] <!-- planned feature or improvement -->

See [open issues](<!-- issues-url -->) for the full list of proposed features and known bugs.

---

## License

Distributed under the **<!-- LICENSE -->** license. See [`LICENSE`](LICENSE) for details.

---

## Acknowledgements

<!-- Credit libraries, tools, or people that made this project possible -->
- <!-- acknowledgement -->
- <!-- acknowledgement -->

---

<!-- SEO FOOTER — helps search engines and repo scrapers -->
<!-- TOPICS: Add relevant topics in repository Settings → Topics
     Examples: nodejs, typescript, gcp, cloud-run, rest-api, open-source -->

<div align="center">
  <sub>Built with ❤️ by <!-- author/org --> · <a href="<!-- repo-url -->">Star this repo ⭐</a></sub>
</div>
```

---

## Discoverability Checklist

Apply these after writing to maximise search ranking:

| Item | Where |
|---|---|
| Add 5–20 relevant topics/tags | Repo Settings → Topics |
| Set a social preview image (1280×640px) | Repo Settings → Social preview |
| Write a repository description (≤ 350 chars, keyword-rich) | Repo Settings → About |
| Ensure `README.md` contains the project name in the first `<h1>` | README heading |
| Use the project name and key technologies in the first paragraph | Overview section |
| Add a website URL if a demo or docs site exists | Repo Settings → Website |
| Pin the repository on your profile (GitHub) | Profile → Pinned repos |
