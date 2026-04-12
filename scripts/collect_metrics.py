#!/usr/bin/env python3
"""
collect_metrics.py — nightly GitHub traffic collector for skill-forge.

Fetches the following from the GitHub API and appends rows to a Google Sheet:
  - Repo clones (unique + total, last 14 days)
  - Repo page views (unique + total, last 14 days)
  - Top referrers
  - Release download counts per version

Setup (one-time):
  1. Create a Google Sheet with two tabs:
       "traffic"   — columns: date, clones_total, clones_unique, views_total, views_unique
       "releases"  — columns: date, tag, download_count
       "referrers" — columns: date, referrer, total, uniques

  2. Create a Google Cloud service account:
       IAM → Service Accounts → Create
       Grant it "Editor" role on the Sheet only (share the Sheet with the SA email)
       Download the JSON key

  3. Add two GitHub repository secrets:
       SHEETS_SERVICE_ACCOUNT_JSON  — full contents of the service account JSON key
       METRICS_SHEET_ID             — the Google Sheet ID (from its URL)

  4. Ensure the workflow at .github/workflows/metrics.yml is enabled.

Environment variables (all required in CI):
  GH_TOKEN                     — GitHub token (provided automatically by Actions)
  SHEETS_SERVICE_ACCOUNT_JSON  — service account credentials JSON string
  METRICS_SHEET_ID             — target Google Sheet ID
"""

import json
import os
import sys
from datetime import date
from typing import Any

import requests

try:
    from google.oauth2 import service_account  # type: ignore[import]
    from googleapiclient.discovery import build  # type: ignore[import]
    SHEETS_AVAILABLE = True
except ImportError:
    SHEETS_AVAILABLE = False

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
REPO = "Choreogrifi/skill-forge"
GH_API = "https://api.github.com"
SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]

TODAY = date.today().isoformat()


# ---------------------------------------------------------------------------
# GitHub helpers
# ---------------------------------------------------------------------------
def gh_get(path: str, token: str) -> Any:
    """Make an authenticated GitHub API request."""
    response = requests.get(
        f"{GH_API}/{path}",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


def fetch_clones(token: str) -> list[dict[str, Any]]:
    data = gh_get(f"repos/{REPO}/traffic/clones", token)
    return data.get("clones", [])


def fetch_views(token: str) -> list[dict[str, Any]]:
    data = gh_get(f"repos/{REPO}/traffic/views", token)
    return data.get("views", [])


def fetch_referrers(token: str) -> list[dict[str, Any]]:
    return gh_get(f"repos/{REPO}/traffic/referrers", token)  # type: ignore[return-value]


def fetch_release_downloads(token: str) -> list[dict[str, Any]]:
    releases: list[dict[str, Any]] = gh_get(f"repos/{REPO}/releases", token)
    rows = []
    for release in releases:
        total = sum(a.get("download_count", 0) for a in release.get("assets", []))
        rows.append({"tag": release["tag_name"], "download_count": total})
    return rows


# ---------------------------------------------------------------------------
# Google Sheets helpers
# ---------------------------------------------------------------------------
def get_sheets_service(credentials_json: str) -> Any:
    """Build an authenticated Google Sheets service from a JSON credentials string."""
    if not SHEETS_AVAILABLE:
        raise RuntimeError("google-auth and google-api-python-client are required")
    info = json.loads(credentials_json)
    credentials = service_account.Credentials.from_service_account_info(  # type: ignore[possibly-unbound]
        info, scopes=SCOPES
    )
    return build("sheets", "v4", credentials=credentials, cache_discovery=False)  # type: ignore[possibly-unbound]


def append_rows(service, sheet_id: str, tab: str, rows: list[list]) -> None:
    """Append rows to a named tab in a Google Sheet."""
    service.spreadsheets().values().append(
        spreadsheetId=sheet_id,
        range=f"{tab}!A1",
        valueInputOption="RAW",
        insertDataOption="INSERT_ROWS",
        body={"values": rows},
    ).execute()
    print(f"  Appended {len(rows)} row(s) to '{tab}'")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> None:
    token = os.environ.get("GH_TOKEN")
    credentials_json = os.environ.get("SHEETS_SERVICE_ACCOUNT_JSON")
    sheet_id = os.environ.get("METRICS_SHEET_ID")

    if not token:
        print("[ERROR] GH_TOKEN is required", file=sys.stderr)
        sys.exit(1)

    if not credentials_json or not sheet_id:
        print(
            "[WARN] SHEETS_SERVICE_ACCOUNT_JSON or METRICS_SHEET_ID not set — "
            "printing metrics to stdout only (Sheets sync disabled)"
        )
        _print_only(token)
        return

    print(f"Collecting metrics for {REPO} on {TODAY}...")

    # Fetch
    clones = fetch_clones(token)
    views = fetch_views(token)
    referrers = fetch_referrers(token)
    releases = fetch_release_downloads(token)

    # Print summary
    print(f"  Clones (entries):    {len(clones)}")
    print(f"  Views (entries):     {len(views)}")
    print(f"  Referrers:           {len(referrers)}")
    print(f"  Releases:            {len(releases)}")

    # Build Sheets service
    service = get_sheets_service(credentials_json)

    # Append traffic rows — one row per day in the 14-day window
    traffic_rows = [
        [
            entry["timestamp"][:10],
            entry.get("count", 0),
            entry.get("uniques", 0),
        ]
        for entry in clones
    ]
    if traffic_rows:
        append_rows(service, sheet_id, "clones", traffic_rows)

    view_rows = [
        [
            entry["timestamp"][:10],
            entry.get("count", 0),
            entry.get("uniques", 0),
        ]
        for entry in views
    ]
    if view_rows:
        append_rows(service, sheet_id, "views", view_rows)

    # Append referrer snapshot (point-in-time)
    referrer_rows = [
        [TODAY, r.get("referrer", ""), r.get("count", 0), r.get("uniques", 0)]
        for r in referrers
    ]
    if referrer_rows:
        append_rows(service, sheet_id, "referrers", referrer_rows)

    # Append release download snapshot
    release_rows = [[TODAY, r["tag"], r["download_count"]] for r in releases]
    if release_rows:
        append_rows(service, sheet_id, "releases", release_rows)

    print("Done.")


def _print_only(token: str) -> None:
    """Fallback: print metrics to stdout when Sheets is not configured."""
    print(f"\n=== skill-forge metrics ({TODAY}) ===\n")

    clones = fetch_clones(token)
    views = fetch_views(token)
    referrers = fetch_referrers(token)
    releases = fetch_release_downloads(token)

    print("--- Clones (last 14 days) ---")
    for c in clones:
        print(f"  {c['timestamp'][:10]}  total={c['count']}  unique={c['uniques']}")

    print("\n--- Views (last 14 days) ---")
    for v in views:
        print(f"  {v['timestamp'][:10]}  total={v['count']}  unique={v['uniques']}")

    print("\n--- Top Referrers ---")
    for r in referrers:
        print(f"  {r.get('referrer', 'direct')}  total={r['count']}  unique={r['uniques']}")

    print("\n--- Release Downloads ---")
    for r in releases:
        print(f"  {r['tag']}  downloads={r['download_count']}")


if __name__ == "__main__":
    main()
