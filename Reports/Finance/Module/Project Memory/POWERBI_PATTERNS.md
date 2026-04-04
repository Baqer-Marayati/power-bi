# Power BI Patterns

## Purpose
This file captures what we have learned about handling PBIP report files, TMDL semantic-model files, and repeated Power BI repair patterns in this project.

## PBIP File Handling
- PBIP report definitions are editable and useful when a visual's structure is understood clearly.
- Report-side JSON edits are often the safest way to fix bindings, filters, slicer layout, and repeated styling patterns.
- Repeated visual patterns should be repaired as systems, not one screenshot at a time.
- Page and visual JSON should be read before making assumptions about what Power BI is actually doing.
- `PBIP` should remain the development master even when a `PBIX` review snapshot is created for convenience or faster server transfer.
- If a `PBIX` review copy exists, treat it as disposable output, not as the place where new fixes should live.
- For server handoff, use a generated zip package instead of copying the whole PBIP folder manually.
- The standard package path is `Exports/Server Packages/Financial Report - ready.zip`, created by `./scripts/package-report.sh`.
- Generated server-transfer zips should stay out of Git history; the export folder exists in the repo, but the zip outputs are ignored.
- In this project, user review should default to the generated zip package, not the raw PBIP folder. If the user is about to check changes, regenerate the package first.
- Power BI debugging in this project must follow the artifact chain explicitly:
- source PBIP files
- rebuilt packaged zip
- user-opened review artifact
- screenshot of what Desktop actually rendered
- Most recent user screenshot beats assumptions. If the screenshot and source disagree, verify whether the user opened an older package, an unsynced Desktop copy, or a broken build.

## TMDL Handling
- TMDL is useful for adding compatibility tables, measures, and semantic aliases.
- Custom relationship edits are high risk in this project because Power BI has already rejected some with invalid column-ID errors.
- Compatibility logic is acceptable when it helps a page bind and render, but it must be labeled clearly if it is not real SAP business truth.
- When a semantic-model change causes load instability, stabilize the PBIP first before continuing design polish.

## Safe Repair Order
1. inspect the page and visual JSON
2. inspect the bound table or measure in TMDL
3. decide whether the problem is:
   - stale benchmark binding
   - filter/drillthrough problem
   - disconnected helper object
   - missing SAP truth
   - compatibility-layer weakness
4. fix the safest layer first
5. reopen the PBIP and verify with screenshots

## Safe Sync And Packaging Order
1. make or sync the intended source changes
2. validate `Financial Report.Report/definition/*.json`
3. validate `Financial Report.Report/StaticResources/RegisteredResources/*`
4. rebuild `Exports/Server Packages/Financial Report - ready.zip`
5. sanity-check the packaged contents when the last pass touched definitions or static resources
6. only then ask the user to review

## Report-Side Discoveries
- Hard-coded benchmark drillthrough filters can silently break otherwise valid pages.
- Slicer polish sometimes requires structural changes such as separating labels from controls.
- IQD formatting affects layout; a card that fit in USD may crowd in IQD.
- KPI rows and slicer rails should be treated as reusable components across pages.
- The old helper `... KPI` / `... KPI Plain` aliases are retired. They leaked internal captions in live Desktop validation and should not be reintroduced.
- For the repeated top monetary KPI cards, card-level `labelPrecision` and `labelDisplayUnits` alone are not reliable enough when Power BI insists on compact text like `2bn`.
- The safer current pattern for those repeated top monetary cards is:
- bind the card to a dedicated numeric `... Card Display` measure with fixed scaling
- hide the built-in card label
- set the card title explicitly to the business caption
- keep the value typography on the card itself
- use the measure format string to enforce compact `bn / M` output with two decimals
- Do not mix that newer KPI-row card pattern with the older `labels/categoryLabels` card styling on adjacent top-row cards. Percent and count cards in the same KPI row should also use the explicit-title + hidden-label structure so the whole row renders as one component family.
- If two pages answer the same question with nearly the same visual, reassign one of them to a different business angle instead of keeping both. In the current 7-page set:
- `Income Statement` should own profitability mix
- `Revenue Insights` should own sales-type revenue mix
- `Cost Structure` should own department-opex concentration
- `Executive Overview` should summarize by sales type rather than repeat department opex
- The cleanest slicer rail in this report uses separate text labels plus compact dropdowns. Copy that pattern to older sidebar pages instead of trying to force a native slicer header to look elegant.
- `Performance Details` is the visual master for the five-control left sidebar rail. Matching it means matching not only label/dropdown positions, but also removing extra slicer-level styling overrides so the controls render with the lighter default look.

## Model-Side Discoveries
- Working top cards usually mean the business domain exists; lower broken visuals often point to wiring problems, not missing SAP data.
- AP and AR pages are more stable when kept close to single-table behavior.
- Cross-domain compatibility aliases can create circular dependency risks.
- Cashflow and budget pages should not be described as source-of-truth if they still rely on compatibility logic.
- If a warning icon survives several report-side fixes, look for a compatibility table that still depends on another compatibility table. Flattening those dependencies back to `Fact_PNL` or another real fact is often the real fix.
- If a warning icon persists on both a source compatibility table and a downstream helper table, rebuild the downstream helper from the fact tables directly rather than waiting for the upstream warning to disappear.

## Design Discoveries
- The preferred design language is quiet, executive, and benchmark-led.
- Sample 2 is the strongest shell reference and should continue to guide layout, spacing, and page composition.
- Light theme nudges rarely overcome strong local visual formatting.
- Structural consistency matters more than flashy changes.
- Approved branding pattern for the first five core pages:
- top-right lockup inside the page margin, not touching the edge
- transparent `Al Jazeera Machinery` logo on the left
- thin vertical grey separator in the middle
- transparent `Canon` logo on the right
- treat the three elements as separate visuals so spacing, sizing, and future swaps stay controllable without disturbing titles or KPI cards
- keep `Actual vs Budget` and `Cashflow` out of that branding pass unless the user explicitly asks to extend it
- Important implementation lesson: a custom-image `actionButton` is not a safe stand-in for a true placed logo visual in this PBIP. In live Desktop validation it rendered as a tiny icon inside a large button container, so that pattern should not be reused for report branding.
- The safe implementation pattern is now confirmed from a user-edited Power BI Desktop file:
- add the logo files as registered resources in `definition/report.json`
- use two true `image` visuals that reference those registered resource item names
- use one `shape` visual with the `Divider - Vertical` preset for the separator
- wrap the three visuals in a `visualGroup` positioned at the top-right header zone
- when branding needs to be replicated to another page, copy the Desktop-generated group and child visual JSON structure instead of improvising a new pattern
- The logo work also taught a broader rule: when Power BI has already generated the correct visual structure once, reuse that exact pattern rather than reverse-engineering from appearance alone.
- A Codex-standardized KPI-row grid can be useful as a cleanup starting point, but once the user performs a later manual Desktop layout pass, that Desktop-edited file becomes the authoritative layout reference.
- In practice for this project: if the user tweaks spacing, stretching, or visual balance directly in Power BI Desktop and approves the result, sync that report definition back into source rather than forcing the prior Codex grid back onto the file.
- Longer page subtitles may need a wider/taller `Report Header` shape rather than text shortening. Preserve the user-approved Desktop result if it differs from the earlier Codex sizing.

## Working Style Discoveries
- The best workflow is iterative and evidence-based: change, reopen PBIP, inspect, then refine.
- Screenshots are essential for confirming what Power BI actually rendered.
- Project Memory should be treated as retained learning, not just status tracking.
- Delivery convenience and development truth should be separated: single-file review copies are fine, but the structured PBIP project is still the reliable build surface.
- After syncing a Desktop-edited PBIP back into source, validate both `Financial Report.Report/definition/*.json` and `Financial Report.Report/StaticResources/RegisteredResources/*` before packaging. We hit a real failure mode where a sync operation left `version.json`, `report.json`, theme JSON, SVG, and logo PNG resources filled with null bytes, which Power BI surfaced as `Error reading JToken from JsonReader` on load.
- Specific failure modes now known in this project:
- malformed `definition/version.json` can block PBIP open immediately
- malformed `definition/report.json` can block PBIP open immediately
- malformed registered-resource JSON such as the custom theme can fail under `StaticResources`
- binary resource corruption can survive packaging and keep breaking every exported zip until the underlying source files are repaired
- Finder metadata such as `__MACOSX` entries in the zip is noisy but was not the root cause of the Power BI load failure; the real issue was invalid resource file content
