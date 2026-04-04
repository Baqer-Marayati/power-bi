# Shared themes

## Canonical JSON

- **File:** `Custom_Theme49412231581938193.json`  
- **Role:** Portfolio custom theme (navy / light canvas / data colors / semantic colors). Same content as registered in the Finance PBIP unless a deliberate refresh is documented.

## Keeping modules aligned

Power BI expects the theme file under each report’s:

`…Report/StaticResources/RegisteredResources/`

**After editing the canonical copy here:**

1. Copy `Shared/Themes/Custom_Theme49412231581938193.json` into each module’s `RegisteredResources` folder (overwrite the existing file of the same name), **or**
2. Run from repo root (optional check only):

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/validate-theme-vs-canonical.ps1 -All
   ```

Modules that use a **different filename** (for example Inventory) should still match this file’s **token values**; see `Shared/Standards/portfolio-theme.tokens.json`. The `scripts/validate-theme-vs-canonical.ps1` script only compares modules that register this exact filename under `RegisteredResources/`.

## Related docs

- `Shared/Standards/portfolio-visual-identity.md`
- `Shared/Standards/page-layout-spec.md`
