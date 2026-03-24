# Reporting Hub

This repository is the portfolio home for the reporting system.

It is designed to scale across multiple department-specific report projects while keeping shared standards, shared assets, and portfolio-level context in one place.

## Portfolio Layout

- `Reports/`
  - self-contained report modules such as Finance, HR, Sales, Service, Inventory, and Logistics
- `Shared/`
  - reusable design, data, SQL, DAX, template, and benchmark assets
  - includes portfolio-level snapshot exchange lane at `Shared/Data Drops/`
- `Portfolio Memory/`
  - cross-report decisions, status, standards, and report catalog
- `docs/`
  - portfolio-level onboarding and architecture docs
- `Archive/`
  - retired reports, old benchmarks, and legacy experiments

## Current Active Report

The current live report module is:
- `Reports/Finance`

Its active editable PBIP remains:
- `Reports/Finance/Financial Report/Financial Report.pbip`

## Start Here

If you are entering this repository for the first time, read these in order:
- [`AGENTS.md`](AGENTS.md)
- [`docs/foundation.md`](docs/foundation.md)
- [`docs/portfolio-architecture.md`](docs/portfolio-architecture.md)
- [`docs/structure.md`](docs/structure.md)
- [`Portfolio Memory/REPORT_CATALOG.md`](Portfolio%20Memory/REPORT_CATALOG.md)
- [`Portfolio Memory/CURRENT_STATUS.md`](Portfolio%20Memory/CURRENT_STATUS.md)
- [`Reports/Finance/README.md`](Reports/Finance/README.md)
- [`Reports/Finance/AGENTS.md`](Reports/Finance/AGENTS.md)

## Working Model

- Each report should live in its own folder under `Reports/`.
- Shared logic and standards should not be duplicated across reports when a shared layer is more appropriate.
- Live report truth should stay inside each report's own memory/docs layer.
- Portfolio-wide truth should stay in `Portfolio Memory/`.
- Historical material should be archived explicitly, not left mixed into active working folders.

## Current Direction

This repository has been restructured from a single-report root into a portfolio-style reporting hub so future report modules can be added cleanly without confusing active work, history, and shared assets.
