# Portfolio Architecture

## Target Structure

```text
Power BI/
├── AGENTS.md
├── README.md
├── Portfolio/
│   ├── docs/
│   ├── Shared/
│   ├── Memory/
│   ├── Archive/
│   ├── scripts/
│   └── CONTRIBUTING.md
├── Fabric/
│   ├── DevelopmentWorkspace/    # Git-connected; edit reports here
│   ├── CanonAnalytics/          # live mirror (release tool only)
│   ├── PaperAnalytics/          # live mirror (release tool only)
│   ├── workspaces.json
│   └── RELEASES.md
├── Reports/
│   ├── Finance/
│   ├── HR/
│   ├── Sales/
│   ├── Service/
│   ├── Marketing/
│   ├── Inventory/
│   └── DataExchange/            # parked
└── .cursor/, .github/, .vscode/
```

## Module Pattern

Each report module should follow this shape:

```text
Reports/<Department>/
├── AGENTS.md
├── README.md
├── module.manifest.json
├── Companies/
│   └── <CompanyCode>/
│       ├── config/
│       └── overlays/
└── Module/
    ├── Core/
    ├── docs/
    ├── Project Memory/
    ├── scripts/
    ├── Records/
    └── Archive/
```

The report itself (`<Name>.pbip`, `<Name>.Report/`, `<Name>.SemanticModel/`) lives in `Fabric/DevelopmentWorkspace/`, not in the module.

Detailed contract:
- `../Shared/Standards/report-module-contract.md`

## Starter Kit

Use the shared starter kit when creating a new module:

- template folder:
  - `../Shared/Templates/report-module-starter`
- scaffolding script:
  - `../scripts/create-report-module.sh`

Example:

```bash
./Portfolio/scripts/create-report-module.sh HR "HR Reporting"
```

That creates `Reports/HR` with standard docs/memory plus contract folders (`Core`, `Companies`, `scripts`, `Records`, `Archive`) and a starter `module.manifest.json`. When the report exists, put it in `Fabric/DevelopmentWorkspace/`, add it to `Fabric/workspaces.json`, and record the paths in the manifest.

## Why This Works

- It keeps active report work isolated.
- It gives AI agents one obvious path into the right report.
- It prevents old artifacts from looking as important as live ones.
- It allows shared design and logic to live once instead of being copied everywhere.

## Shared Layer Guidance

Use `../Shared/` for:
- design systems
- themes
- templates
- data contracts
- SQL assets
- DAX patterns
- shared benchmark references

Do not put report-specific live status in `../Shared/`.

## Portfolio Memory Guidance

Use `../Memory/` for:
- which reports exist
- which reports are planned
- cross-report standards
- portfolio-wide decisions
- shared data-platform assumptions

Do not use `../Memory/` for page-level repair notes inside one report.
