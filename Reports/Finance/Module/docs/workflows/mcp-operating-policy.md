# MCP Operating Policy (Finance)

## Purpose

Standardize how AI agents and operators use MCP so semantic-model changes are safer and more repeatable.

## Approved MCP Server

- Server: `powerbi-modeling-mcp`
- Scope: semantic model operations (tables, columns, measures, relationships, DAX query validation, and related model metadata)
- Non-scope: report page JSON layout and visual shell edits

## Default Operating Mode

- Start with inspection-first behavior (read-only intent) before write operations.
- Keep confirmation prompts enabled by default.
- Do not use skip-confirmation mode unless explicitly approved for a controlled batch task.

## Required Workflow

1. Connect to the semantic model target (PBIP definition path, Desktop model, or Fabric model).
2. Inspect dependencies and likely impact before modifying objects.
3. Apply the smallest safe change set.
4. Reopen/validate in Power BI Desktop.
5. Record durable truth in `Project Memory` when behavior or strategy changed.

## Fallback Rule

If MCP is unavailable:

- Continue with direct TMDL edits only when necessary.
- State assumptions explicitly.
- Increase validation depth and document known risk in handoff notes.

## Security and Governance

- Treat model metadata and query output as sensitive.
- Use least-privilege credentials and approved environments.
- Avoid sharing raw sensitive query output in broad chat logs.
