---
name: Third-Party Services
description: All external services used by skill-forge, where to configure them, and what credentials are needed
type: reference
---

All services are free tier. Credentials are placeholders in the codebase — replace before merging the relevant PR.

---

## Google Analytics 4

**Purpose:** Track docs site visitors, page views, referral sources.
**Where:** [analytics.google.com](https://analytics.google.com)
**Setup:**
1. Create a GA4 property → Web stream → URL: `https://choreogrifi.github.io/skill-forge/`
2. Copy the Measurement ID (format: `G-XXXXXXXXXX`)
3. Replace `REPLACE_WITH_GA4_MEASUREMENT_ID` in `docs/_config.yml`
4. PR: `feat/ga4-analytics` (PR #1)

---

## Google Search Console

**Purpose:** Submit sitemap, monitor search indexing, track search queries.
**Where:** [search.google.com/search-console](https://search.google.com/search-console)
**Setup:**
1. Add property → URL prefix → `https://choreogrifi.github.io/skill-forge/`
2. Verify via HTML tag method — Google provides a tag like:
   `<meta name="google-site-verification" content="XXXX" />`
3. Replace `REPLACE_WITH_GOOGLE_SITE_VERIFICATION` in `docs/_config.yml`
4. After merging, submit sitemap at:
   Search Console → Sitemaps → enter `sitemap.xml`
5. Sitemap URL: `https://choreogrifi.github.io/skill-forge/sitemap.xml`
6. PR: `feat/ga4-analytics` (PR #1) — verification field is included

**Account:** Use any Google account associated with the Choreogrifi org.

---

## GoatCounter

**Purpose:** Count install.sh runs — privacy-first, no personal data.
**Where:** [goatcounter.com](https://goatcounter.com) — free for open source
**Setup:**
1. Sign up → choose "Open source / non-commercial"
2. Your account slug becomes: `https://<slug>.goatcounter.com`
3. Replace `REPLACE_WITH_GOATCOUNTER_ACCOUNT` in `scripts/install.sh`
4. PR: `feat/install-telemetry` (PR #2)

---

## Google Sheets (Metrics Pipeline)

**Purpose:** Store historical GitHub traffic metrics beyond the 14-day GitHub window.
**Where:** [sheets.google.com](https://sheets.google.com)
**Setup:**
1. Create a Google Sheet with four tabs: `clones`, `views`, `referrers`, `releases`
2. Copy the Sheet ID from its URL
3. Create a GCP service account with Sheets API access
4. Share the Sheet with the service account email (Editor)
5. Add two GitHub repository secrets:
   - `SHEETS_SERVICE_ACCOUNT_JSON` — service account JSON key contents
   - `METRICS_SHEET_ID` — Sheet ID from step 2
6. PR: `feat/metrics-pipeline` (PR #3)

---

## Looker Studio Dashboard

**Purpose:** Visualise metrics from Google Sheets.
**Where:** [lookerstudio.google.com](https://lookerstudio.google.com)
**Setup:** Create report → Add data → Google Sheets → select metrics sheet.
No credentials needed beyond Google account access to the Sheet.
