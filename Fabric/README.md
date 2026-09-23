# Fabric workspaces

This folder mirrors the three Power BI workspaces. Every report definition in the repo lives here, and nowhere else.

| Folder | Power BI workspace | Who writes it |
|---|---|---|
| `DevelopmentWorkspace/` | Development Workspace (Git-connected to this folder) | Report and model edits, by hand or by the agent |
| `CanonAnalytics/` | Canon Analytics (live, viewers use it) | `fabric_release.py` only |
| `PaperAnalytics/` | Paper Analytics (live, viewers use it) | `fabric_release.py` only |

- `workspaces.json` holds the workspace, report, model, and gateway connection IDs, plus a row-count query per report.
- `RELEASES.md` has one line per publish.

Canon Analytics and Paper Analytics cannot be Git-connected. Fabric Git integration needs Fabric or Premium capacity, and they stay on shared capacity so Pro users can open them. Their folders here are a record of what is live, written after each publish. Fabric never reads them.

Do not rename `DevelopmentWorkspace/`. The Development Workspace's Git connection points at that exact folder.

## Where things are

Anything that differs between `DevelopmentWorkspace/` and a live folder is waiting to go live.

Each report is always in the Development Workspace. Canon reports go live in Canon Analytics and Paper reports in Paper Analytics:

| Report | Live in |
|---|---|
| Canon Financial Report | Canon Analytics |
| Canon Inventory Report | Canon Analytics |
| Canon Sales Report | Canon Analytics |
| Canon Service Report | Canon Analytics |
| Paper Financial Report | Paper Analytics |
| Paper Inventory Report | Paper Analytics |

Modules under `Reports/<Domain>/` hold the docs, decisions, project memory, and company config for these reports. They do not hold report copies.

## Workflow

1. **Change.** Edit only `DevelopmentWorkspace/`. Run `python3 Portfolio/scripts/audit-report-consistency.py --strict Fabric/DevelopmentWorkspace`, then commit and push to `main`.
2. **Review.** In Fabric, open the Development Workspace, click **Source control > Update**, and review the report there.
3. **Approve.** The owner names the report and says to publish it. Nothing goes live without that.
4. **Dry run.** Run `python3 Portfolio/scripts/fabric_release.py publish "Canon Financial Report"`. It stops unless all of these are true:
   - `Fabric/` has no uncommitted changes, and local `main` equals `origin/main`.
   - The strict audit passes for that report.
   - The Development Workspace matches this commit, so what was reviewed is what ships.
   - What is live still matches the live mirror, so nobody changed production outside this workflow.
   - The live model is on the **B1HANA** gateway connection.

   It then lists the files that will change.
5. **Publish.** Re-run with `--apply`. The tool:
   - Saves the current live definitions to `Fabric/.release-backups/`, which stays on this machine.
   - Updates the existing live model and report in place, so links, viewers, and permissions stay the same.
   - Keeps the model on B1HANA, and refreshes it if the model changed.
   - Runs the row-count check and confirms the live content now matches what was sent.
   - Updates the live mirror folder and adds a line to `RELEASES.md`.
6. **Record.** Commit `Fabric/` and push. Update the module's `Project Memory/CURRENT_STATUS.md` with what went live.

`python3 Portfolio/scripts/fabric_release.py status` is read-only. For every report it shows pending changes, Development Workspace sync, live drift, the gateway, and the refresh schedule. The same check is the VS Code task **Fabric: Release status**.

## Rolling back

`python3 Portfolio/scripts/fabric_release.py rollback "Canon Financial Report" --to <commit>` publishes the live mirror as it was at that commit. Use the commit before the bad release; `git log -- Fabric/CanonAnalytics` lists them. The Development Workspace is left alone, so the rolled-back change then shows as pending again.

## A new report

1. Add it to `DevelopmentWorkspace/` and to `workspaces.json`, with the dev IDs and `liveReportId` / `liveModelId` set to `null`.
2. Publish with `publish "<Name>" --create`, then add `--apply`. The tool creates the model, binds it to B1HANA before the report exists, creates the report, refreshes, and writes the new IDs back to `workspaces.json`.
3. Turn on scheduled refresh in Power BI. New models start with it off.

## Access the release tool needs

- The **Power BI API** app (service principal in `Portfolio/scripts/powerbi-api-local.env`) is Admin on all three workspaces.
- The app is a **User** on the **B1HANA** connection (Manage connections and gateways > B1HANA > Manage users). Without that, a new model falls back to a personal gateway that has no credentials, and refresh fails.

Other reports that are not in any workspace are parked in their module's `Module/Archive/` folder.
