  - Open-item sets include negative amounts; confirm credit-note handling and sign convention.
- Low severity:
  - Some journal lines have zero debit/credit; verify source extraction or balancing logic.

## Prioritized Recommendations

### High Impact (0-4 weeks)
1. Fill missing master-data attributes in export tables (`bp_group`, `payment_terms`, `uom`) or map them explicitly as unavailable.
2. Add company identifier from source (not constant) when multiple companies are in scope.
3. Keep only canonical file names (remove `__YYYY-MM-DD__v1.csv.csv` duplicates from incoming).

### Medium Impact (1-3 months)
1. Add reconciliation checks against source counts by date and company.
2. Add unique-key assertions for each dataset before snapshot acceptance.
3. Add user ID extraction for journal entries (replace placeholder `unknown`).

### Longer Horizon (3-12 months)
1. Expand export pack to include sales/purchase open orders and inventory movement sets.
2. Add automated trend and anomaly baselines across rolling snapshots.
3. Version data dictionary with explicit schema-change notes per batch.