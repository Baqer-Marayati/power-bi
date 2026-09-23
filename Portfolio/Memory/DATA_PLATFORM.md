# Data Platform

## Purpose

Use this file for portfolio-level assumptions about shared databases, servers, schemas, refresh patterns, and cross-report data contracts.

Current high-level assumption:
- future report modules are expected to share major parts of the same broader data platform, even when their business logic differs by department

Add durable cross-report platform decisions here as the reporting ecosystem grows.

## Fabric tenant baseline (August 29, 2026)

- Fabric/Power BI tenant `53ea674b-813e-46a3-9961-f0b04a117e08` is homed in **East Asia** on `WABI-EAST-ASIA-B-PRIMARY`.
- The five production and six development business semantic models all use the single East Asia on-premises gateway `SAPB1_GATEWAY`, connection `B1HANA`, and ODBC DSN `HANA_B1`.
- Canon Analytics and Paper Analytics use shared capacity. Development Workspace uses the active East Asia `FTL4` trial capacity.
- The complete pre-relocation inventory, IDs, roles, refresh schedules, tenant controls, and validation checklist are in `FABRIC_TENANT_REGION_MIGRATION_BASELINE_2026-08-29.md`.
