# Finance Semantic Patterns

Reusable semantic-model guidance for Finance company PBIPs belongs here when it is not company-specific.

Current shared patterns to preserve:
- Prefer SAP-backed facts and conformed dimensions over compatibility aliases when practical.
- Keep provisional compatibility objects clearly labeled in Project Memory.
- Avoid risky relationship experimentation unless the relationship is clearly valid and Desktop validation is planned.
- Company schema names and DSNs belong in `Companies/<CODE>/config` and `Reports/Finance/module.manifest.json`.

Keep live TMDL changes inside the company `.SemanticModel/` folders under `Fabric/DevelopmentWorkspace/`. Use this folder for reusable patterns, not active semantic-model source.
