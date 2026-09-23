# Fabric Tenant Region Migration Baseline

## Snapshot

- Captured: August 29, 2026
- Method: read-only Fabric/Power BI admin portal and REST API inspection
- Tenant ID: `53ea674b-813e-46a3-9961-f0b04a117e08`
- Fabric/Power BI home region: **East Asia**
- Service cluster: `WABI-EAST-ASIA-B-PRIMARY`
- Changes made during inventory: **none**

This is the pre-change baseline for a possible Microsoft-supported tenant relocation to Europe.

## Executive inventory

- 14 workspaces are returned by the admin API:
  - 3 business workspaces: Canon Analytics, Paper Analytics, Development Workspace
  - 1 Microsoft-managed Admin monitoring workspace
  - 9 user personal workspaces
  - 1 hidden service-principal personal workspace
- The admin UI lists 13 workspaces because it omits the service-principal personal workspace.
- 22 reports and 22 one-to-one semantic models.
- All 22 semantic models are Import-mode and refreshable.
- 0 published Power BI apps.
- 0 deployment pipelines.
- 0 dataflows, dashboards, or workbooks.
- 0 active Publish to web embed codes.
- 0 Fabric domains, tenant tags, organizational visuals, organizational themes, Fabric identities, or featured-content entries.
- 0 connected tenant-level Azure Data Lake Gen2 storage resources.
- No additional partner workload was installed; listed catalog workloads were only `Available to add`.
- 0 report subscriptions returned by the admin inventory.
- 1 accessible on-premises gateway with 1 ODBC connection.
- 2 active East Asia capacity records: an `FTL4` Fabric trial and the reserved `PP3` Premium Per User capacity.
- 170 tenant controls: 102 enabled and 68 disabled.
- No allowed-group or denied-group exceptions were configured on any tenant control returned by the API.

## Capacities

### Fabric trial

- Name: `Trial-20260219T230806Z-34GVu-UV4EiCMD6LA2CjIw`
- Capacity ID: `d7b1acb5-330d-4b46-8cf9-2dc06126b935`
- SKU: `FTL4`
- Region: East Asia
- State: Active
- Capacity admin: `Power_Bi@aljazeeramachinery.com`
- Assigned workspaces:
  - Development Workspace
  - PersonalWorkspace Power Bi
  - PersonalWorkspace Jabbar Al-Marayati
- The trial expiry date was not returned by the API and remains to be confirmed.

### Premium Per User

- Name: `Premium Per User - Reserved`
- Capacity ID: `61084bf7-4b10-487c-90b4-33bf89a70c22`
- SKU: `PP3`
- Region: East Asia
- State: Active
- Automatic page refresh: On, minimum interval 5 minutes
- Change-detection measure: On, minimum execution interval 30 seconds
- XMLA endpoint: Read Write

The PPU administration view exposed workload settings but not a tenant-wide list of assigned license users.

Canon Analytics and Paper Analytics are on shared capacity, not the Fabric trial.

## Workspace and access inventory

| Workspace | ID | Type / capacity | Reports | Access |
|---|---|---|---:|---|
| Canon Analytics | `a0fbbdc7-e807-4b58-a39d-b45c2adc1477` | Workspace / shared | 3 | Admin: Power Bi, Baqer Al-Marayati, Power BI API app. Viewer: Jabbar Al-Marayati, Walid Rahman, Ali Al-Marayati |
| Paper Analytics | `12bc0f31-cb6f-4e73-b3b6-64e63a8c8558` | Workspace / shared | 2 | Admin: Power Bi, Baqer Al-Marayati, Power BI API app. Viewer: Jabbar Al-Marayati, Ali Al-Marayati |
| Development Workspace | `e25920dc-a13e-467a-b23e-ce3b95f0d595` | Workspace / FTL4 | 6 | Admin: Power Bi, Baqer Al-Marayati, Power BI API app |
| Admin monitoring | `b561f249-91fc-48ed-a0fd-894bb172e36f` | AdminWorkspace / shared | 4 | Microsoft Admin Monitoring identity; Tenant Administrators group is recorded with access `None` |
| PersonalWorkspace Wakkas Noori | `333e7f0f-e2b1-4c8d-894f-2aed694813af` | Personal / shared | 0 | Wakkas Noori, Admin |
| My workspace — Baqer Al-Marayati | `cf5b9594-0c85-4217-a106-8fd958fb3d59` | Personal / shared | 0 | Baqer Al-Marayati, Admin |
| PersonalWorkspace Power Bi | `4cbf8bae-8a6a-4a6f-b6a5-611ae94b06d8` | Personal / FTL4 | 2 | Power Bi, Admin |
| PersonalWorkspace Walid Rahman | `76f01b97-3624-4981-9ab4-111effb118fa` | Personal / shared | 2 | Walid Rahman, Admin |
| PersonalWorkspace Jabbar Al-Marayati | `43de24a3-fd4d-4904-8e9f-5eebbc0ee49b` | Personal / FTL4 | 0 | Jabbar Al-Marayati, Admin |
| PersonalWorkspace Ali Al-Marayati | `b959d1f2-f110-44ea-a46a-dd86e3292575` | Personal / shared | 1 | Ali Al-Marayati, Admin |
| PersonalWorkspace Ali Talib | `d73d53a7-b266-465a-8205-5bbaf2662211` | Personal / shared | 1 | Ali Talib, Admin |
| PersonalWorkspace Maya | `ddb5c581-a56c-4186-9b83-261f9095b633` | Personal / shared | 0 | Maya, Admin |
| PersonalWorkspace Hussein Bilad | `291ef3d1-fbd1-4c7a-b840-7e6e6594f421` | Personal / shared | 1 | Hussein Bilad, Admin |
| PersonalWorkspace Power BI API – Aljazeera Machinery | `bed521bf-d6fc-4c35-9733-a1ca86716654` | Personal / shared | 0 | Power BI API service principal, Admin |

Service principal:

- Display name: `Power BI API – Aljazeera Machinery`
- Application/principal ID: `caab9a9f-fee2-4afb-915f-cc9570f90a61`
- Workspace role: Admin in Canon Analytics, Paper Analytics, and Development Workspace.

No Contributor or Member roles were returned for the three business workspaces. No direct report-level or semantic-model-level users were returned; access is currently workspace-based.

## Business report and semantic-model inventory

### Canon Analytics — production

| Report | Report ID | Semantic model ID | Format | Last modified (UTC) |
|---|---|---|---|---|
| Canon Sales Report | `7d3c7324-af0d-4950-a0a8-ac0500bdd480` | `09b6f013-7c86-44ca-ad93-14484000724a` | PBIR | 2026-07-28 13:46:55 |
| Canon Financial Report | `e832e4cf-7ab6-472c-bced-978986cc8f87` | `7e404446-60d0-40d6-895a-9bdfb5213f7c` | PBIR | 2026-07-28 13:37:41 |
| Canon Inventory Report | `fe2736c2-184b-47dc-bee9-f984349f94f7` | `1d4d7a8c-f9ca-431d-8e7b-10188f7f78` | PBIR | 2026-07-28 13:42:45 |

### Paper Analytics — production

| Report | Report ID | Semantic model ID | Format | Last modified (UTC) |
|---|---|---|---|---|
| Paper Financial Report | `6329a8e3-667c-4f79-afc4-d713e4183303` | `96308a26-9381-4feb-886c-9c90afac6bf2` | PBIR | 2026-08-18 14:45:58 |
| Paper Inventory Report | `7a05c64d-c5ec-408e-a90f-d0af6c7ec0a0` | `017aa653-925e-4a5a-8437-26d939977641` | PBIR | 2026-07-28 13:52:32 |

### Development Workspace

| Report | Report ID | Semantic model ID | Storage | Last modified (UTC) |
|---|---|---|---|---|
| Canon Inventory Report | `cfc1bf77-3ac4-4a35-b26c-a4d00cae09d1` | `d00adac5-83c9-4105-9dcf-bb9a6373bde3` | PremiumFiles | 2026-08-29 12:04:17 |
| Canon Financial Report | `a783533b-5377-4309-892f-2e0184fa2eb3` | `b1e83d9b-1d75-4fdf-9fad-98318bf9147a` | Abf | 2026-08-29 12:04:20 |
| Canon Sales Report | `dbac3765-342e-4cd0-8084-8b81f53c22d5` | `b5b3a510-fa4d-4e4d-b5bb-bdc12cef21b8` | Abf | 2026-08-29 12:04:22 |
| Paper Financial Report | `84ad8110-e914-472a-8975-ceb8de351974` | `cc7415d9-4d10-4b0a-acbb-6e2c9043bb2c` | Abf | 2026-08-29 12:04:23 |
| Paper Inventory Report | `60629780-f40d-4917-a897-c06a61c69609` | `b38eca52-b79c-43a9-b4b6-508c0a741b35` | Abf | 2026-08-29 12:04:16 |
| Canon Service Report | `d4ec7521-1cd8-4087-ad2d-462b59ba20d5` | `eef4b55c-fd94-45e0-8e83-d37bb38ccab7` | Abf | 2026-08-29 12:04:19 |

All six development reports are PBIR. The five production reports and all six development semantic models are configured by `Power_Bi@aljazeeramachinery.com`.

### Other tenant content

- PersonalWorkspace Power Bi:
  - Store Sales
  - OneLake catalog governance report (automatically generated)
- PersonalWorkspace Walid Rahman:
  - Revenue Opportunities
  - Artificial Intelligence Sample
- PersonalWorkspace Ali Al-Marayati:
  - Corporate Spend
- PersonalWorkspace Ali Talib:
  - Getting Started in Power BI
- PersonalWorkspace Hussein Bilad:
  - Getting Started in Power BI
- Admin monitoring:
  - Content Sharing
  - OneLake Catalog - Governance for Admins
  - Feature Usage and Adoption
  - Purview Hub

## SAP gateway baseline

- Gateway name: `SAPB1_GATEWAY`
- Gateway ID: `5d84a2d9-c033-4fc3-ac3c-f36486c2ea35`
- Reported machine: `C21694TS01P01`
- Gateway version: `3000.322.5`
- Gateway contact/admin annotation: `Power_Bi@aljazeeramachinery.com`
- Registration/service region: East Asia
- Connection name: `B1HANA`
- Data source ID: `c645ef82-010c-443f-a299-70fe49c37503`
- Connector: ODBC
- DSN: `HANA_B1` (`dsn=hana_b1` in model bindings)
- Credential type: Basic
- Privacy level: None
- Data-source user returned by API: `Power_Bi@aljazeeramachinery.com` with Read access

All 11 production and development business semantic models bind to this same gateway and data-source ID. No model parameters were configured.

The gateway recovery key, Basic credential, SAP password, DSN driver configuration, and service account password cannot be exported through Fabric. They must be located and validated separately before any gateway re-registration or regional move.

## Refresh baseline

All schedules below run seven days per week and notify on failure.

| Workspace | Semantic model | Enabled | Time zone | Scheduled times |
|---|---|---:|---|---|
| Canon Analytics | Canon Sales Report | Yes | Arabic Standard Time | 08:00, 11:00, 14:00, 17:00, 20:00 |
| Canon Analytics | Canon Financial Report | Yes | Arabic Standard Time | 08:00, 11:00, 14:00, 17:00, 20:00 |
| Canon Analytics | Canon Inventory Report | Yes | Arabic Standard Time | 08:00, 11:00, 14:00, 17:00, 20:00 |
| Paper Analytics | Paper Financial Report | Yes | Arabic Standard Time | 09:00, 14:00, 18:00 |
| Paper Analytics | Paper Inventory Report | Yes | Arabic Standard Time | 09:00, 14:00, 17:00 |
| Development Workspace | Canon Inventory Report | No | UTC | Stored time 20:30 |
| Development Workspace | Canon Financial Report | No | UTC | Stored time 02:00 |
| Development Workspace | Canon Sales Report | No | UTC | Stored time 19:30 |
| Development Workspace | Paper Financial Report | No | UTC | Stored time 03:00 |
| Development Workspace | Paper Inventory Report | No | UTC | Stored time 01:30 |
| Development Workspace | Canon Service Report | No | UTC | Stored time 20:30 |

Health at capture time:

- The latest five refreshes for each of the five production models all completed successfully.
- Most recent production completions were on August 29, 2026.
- Development schedules are disabled and refreshes are on demand.
- Canon Inventory, Canon Financial, and Canon Sales development models each have an older failed refresh in their latest-five history, followed by successful refreshes.

## Tenant settings baseline

- Total settings: 170
- Enabled: 102
- Disabled: 68
- Settings with allowed or denied security-group exceptions: 0
- Result: settings that support granular scoping are currently operating tenant-wide rather than through named security groups.

### Migration and residency-sensitive settings

- Users can create Fabric items: Enabled
- Users can try Microsoft Fabric paid features: Enabled
- Create workspaces: Enabled
- Use semantic models across workspaces: Enabled
- Automatic PBIR conversion/storage: Enabled
- Workspace retention period: Enabled
- Fabric item recovery: Enabled
- Git integration: Enabled
- GitHub synchronization: Enabled
- Export to Git repositories in other geographical locations: **Disabled**
- Fabric/Power BI Copilot and AI experiences: Enabled
- Standalone cross-item Power BI Copilot: Enabled
- Azure OpenAI processing outside the capacity geographic region: **Enabled**
- Azure OpenAI storage outside the capacity geographic region: Disabled
- Azure AI Service processing outside the geographic region: Disabled
- Azure Maps processing outside the geographic region: Disabled
- Share Fabric data with Microsoft 365 services: Enabled; the cross-geo sub-option value was not exposed in the returned property record
- Tenant-level Private Link: Disabled
- Block Public Internet Access: Disabled
- Workspace inbound network rules: Disabled
- Workspace outbound network rules: Disabled
- Workspace IP firewall/trusted resource configuration: Enabled
- Customer-managed keys: Disabled

### Sharing and information protection

- Sensitivity-label application and automatic inheritance settings: Disabled
- External data sharing and accepting external shares: Disabled
- Guest users can access Fabric: Enabled
- Users can invite guest users: Enabled
- Guest users can browse Fabric content: Disabled
- Publish to web: **Enabled tenant-wide**
- Active Publish to web embed codes: **0**
- Organization-wide shareable links: Enabled
- External-user email subscriptions: Enabled
- B2B guest subscriptions: Enabled
- Report export/download features are broadly enabled; image export is disabled.
- No current report subscriptions were returned.
- No active Publish to web embed codes were present at capture time, despite the tenant-wide creation setting being enabled.

### Gateway, integration, and developer controls

- Microsoft Entra SSO for the on-premises gateway: Disabled
- Microsoft Entra SSO for VNet gateways: Disabled
- Granular access control for all data connections: Disabled
- Non-Entra authentication in Eventstream: Enabled
- Power BI Model Context Protocol endpoint: Enabled tenant-wide
- Semantic Model Execute Queries REST API: Enabled
- Embed content in apps: Enabled
- Service principals can create workspaces, connections, and deployment pipelines: Enabled tenant-wide
- Service principals can call Fabric public APIs: Enabled tenant-wide
- Service-principal read-only and update Admin APIs: Disabled
- R and Python visual interaction/sharing: Enabled
- Custom visuals built with the Power BI SDK: Enabled
- Certified-visuals-only enforcement: Disabled

## Region-move implications

1. The five production models are on shared East Asia capacity and depend on one East Asia gateway registration.
2. Development Workspace is tied to an East Asia `FTL4` trial capacity; a tenant relocation does not by itself prove that this capacity will move.
3. All 11 business models depend on one ODBC data source and one gateway, so gateway re-registration or rebinding is the critical operational dependency.
4. No apps, pipelines, dataflows, dashboards, workbooks, or subscriptions reduce the number of secondary artifacts that require reconstruction.
5. The Power BI API service principal must retain its workspace roles after relocation; its client secret/certificate is not exportable from Fabric.
6. Personal workspaces contain seven user/sample reports that must be included in any Microsoft migration scope or explicitly accepted as disposable.
7. Publish to web is enabled, but the admin portal showed zero active embed codes. Recheck after relocation to ensure none appear unexpectedly.
8. Azure OpenAI cross-region processing is enabled, so relocating Fabric to Europe would not by itself guarantee that all Copilot processing remains in Europe.

## Information still required before requesting a move

- Confirm and securely store the `SAPB1_GATEWAY` recovery key.
- Record the Windows gateway service account and validate its password.
- Export or document the `HANA_B1` ODBC DSN, SAP HANA driver version, server/port, and architecture.
- Confirm the gateway machine has a backup/restore or rebuild procedure.
- Confirm Fabric trial expiry and Microsoft's treatment of `FTL4` during tenant relocation.
- Inventory Microsoft Entra admin roles, licenses, and the Power BI API application's secret/certificate outside Fabric.
- Export relevant Microsoft Purview/M365 audit logs if the change window requires a compliance record.
- Ask Microsoft Support whether the gateway cluster, capacity assignments, personal workspaces, Admin monitoring workspace, and Fabric trial are migrated or must be recreated.
- Obtain a documented rollback path and expected outage window.

## Post-move validation checklist

- Confirm tenant and capacity region report Europe.
- Confirm all 14 workspaces and all 22 report/model pairs are present.
- Confirm Canon/Paper/Development workspace roles, including the Power BI API app.
- Re-register or rebind `SAPB1_GATEWAY` and `B1HANA` if Microsoft does not migrate them.
- Trigger one manual refresh for every production model, then every development model.
- Confirm all production schedules and Arabic Standard Time settings.
- Validate report open, model query, export, API access, MCP access, and Git sync.
- Recheck tenant settings against the 170-setting baseline.
- Verify any Publish to web links, subscriptions, and external shares.
