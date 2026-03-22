# Portfolio Architecture

## Target Structure

```text
Reporting Hub/
├── AGENTS.md
├── README.md
├── docs/
├── Shared/
├── Reports/
│   └── Finance/
├── Portfolio Memory/
└── Archive/
```

## Module Pattern

Each report module should follow this shape:

```text
Reports/<Department>/
├── AGENTS.md
├── README.md
├── docs/
├── Project Memory/
├── Financial Report or equivalent PBIP folder
├── Design Benchmarks/
├── Exports/
├── Records/
└── Archive/
```

## Why This Works

- It keeps active report work isolated.
- It gives AI agents one obvious path into the right report.
- It prevents old artifacts from looking as important as live ones.
- It allows shared design and logic to live once instead of being copied everywhere.

## Shared Layer Guidance

Use `Shared/` for:
- design systems
- themes
- templates
- data contracts
- SQL assets
- DAX patterns
- shared benchmark references

Do not put report-specific live status in `Shared/`.

## Portfolio Memory Guidance

Use `Portfolio Memory/` for:
- which reports exist
- which reports are planned
- cross-report standards
- portfolio-wide decisions
- shared data-platform assumptions

Do not use `Portfolio Memory/` for page-level repair notes inside one report.
