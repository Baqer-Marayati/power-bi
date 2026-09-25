# Releases to live workspaces

One row per publish, written by `Portfolio/scripts/fabric_release.py`. Do not edit rows by hand.

The first two rows record how the current live content got there. Those publishes happened before the release tool existed.

| When | Report | Workspace | Action | Commit | Pushed | Refresh | Smoke rows | Schedule |
|---|---|---|---|---|---|---|---|---|
| 2026-09-23 18:40 | Canon Financial, Canon Inventory, Canon Sales, Paper Financial, Paper Inventory | Canon Analytics, Paper Analytics | manual sync from Development Workspace in Power BI | `2ba401a2` | model, report | scheduled | n/a | on |
| 2026-09-24 00:54 | Canon Service Report | Canon Analytics | first publish (API test) | `345f40e8` | model, report | Completed | 1654 | off |
| 2026-09-24 01:55 | Canon Service Report | Canon Analytics | publish | `3297af78` | model, report | Completed | 1654 | off |
| 2026-09-24 10:17 | Canon Service Report | Canon Analytics | removed from Canon Analytics | `50330e1e` | report, model | n/a | n/a | n/a |
| 2026-09-25 15:33 | Canon Financial Report | Canon Analytics | publish | `d5aed973` | model | Completed | 18096 | on |
