# Data Platform

## Purpose

Use this file for portfolio-level assumptions about shared databases, servers, schemas, refresh patterns, and cross-report data contracts.

Current high-level assumption:
- future report modules are expected to share major parts of the same broader data platform, even when their business logic differs by department

Add durable cross-report platform decisions here as the reporting ecosystem grows.

## Fabric tenant baseline (August 29, 2026)

- Fabric/Power BI tenant `53ea674b-813e-46a3-9961-f0b04a117e08` is homed in **East Asia** on `WABI-EAST-ASIA-B-PRIMARY`.
- The production and development business semantic models all use the single East Asia on-premises gateway `SAPB1_GATEWAY`, connection `B1HANA`, and ODBC DSN `HANA_B1`.
- Canon Analytics and Paper Analytics use shared capacity. Development Workspace uses the active East Asia `FTL4` trial capacity.
- The complete pre-relocation inventory, IDs, roles, refresh schedules, tenant controls, and validation checklist are in `FABRIC_TENANT_REGION_MIGRATION_BASELINE_2026-08-29.md`.

## Workspace content state (September 24, 2026)

- Production workspaces are not Git-connected (shared capacity keeps them Pro-viewable); the only Git-synced Fabric folder is `Fabric/DevelopmentWorkspace/`.
- **Canon Analytics** (Financial, Inventory, Sales, Service) and **Paper Analytics** (Financial, Inventory) match the Development Workspace as of Sep 24, 2026. Their repo mirrors are `Fabric/CanonAnalytics/` and `Fabric/PaperAnalytics/`.
- Promotion is now scripted: `Portfolio/scripts/fabric_release.py` uses the Power BI API service principal to update the live items in place (Fabric `updateDefinition`), keep the gateway binding, refresh, and smoke-check. It replaces the manual Desktop publish from the server. Deployment pipelines are still not used.
- The service principal must be a **User** on the **B1HANA** connection (granted 24 Sep 2026). Without it, a model the API creates binds to a personal gateway with no credentials, and refresh fails with "data source is missing credentials."
- Models the API creates are owned by the service principal. Only the owner can change their gateway binding, so rebinding them from the Power BI UI needs a "Take over" first.
