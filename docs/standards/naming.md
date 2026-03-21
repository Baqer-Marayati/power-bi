# Naming Standard

## Purpose

Use clear, business-readable names wherever possible.

The repository should be understandable both to technical editors and business reviewers.

## General Rules

- Prefer descriptive names over abbreviated internal shorthand.
- Keep business-facing names readable and stable.
- Avoid introducing multiple names for the same concept.
- Do not rename objects casually if report bindings already depend on them.

## Measures

- Prefer names that describe the business meaning, not only the calculation style.
- Temporary helper measures should be visibly identifiable as helpers.
- Compatibility measures should be identifiable as compatibility logic when they are not real SAP truth.

## Tables

- Preserve real SAP-backed table meaning where possible.
- Avoid creating vaguely named helper tables.
- If a compatibility table is temporary, its purpose should be obvious from the name.

## Pages

- Page names should reflect business purpose, not implementation detail.
- Avoid near-duplicate page naming that causes confusion.
- If two pages answer the same question, redefine one rather than keeping overlapping names and stories.

## Files And Docs

- Use concise, plain-English markdown file names in `docs/`.
- Keep documentation names stable once linked from `README.md`.

## Naming Change Rule

If a rename changes report behavior, model meaning, or team understanding, document it in `Project Memory`.
