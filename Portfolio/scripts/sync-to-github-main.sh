#!/usr/bin/env bash
# Reset this clone to match GitHub origin/main and remove common local-only clutter.
# Run from anywhere; operates on the repository root (parent of Portfolio/).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

BRANCH="${1:-main}"
REMOTE="${REMOTE:-origin}"

echo "Fetching ${REMOTE}/${BRANCH}..."
git fetch "${REMOTE}" "${BRANCH}"

echo "Hard reset to ${REMOTE}/${BRANCH}..."
git reset --hard "${REMOTE}/${BRANCH}"

echo "Removing untracked files and empty dirs (repo-wide)..."
git clean -fd

echo "Removing ignored Finder/PBI noise under Reports/Finance only..."
git clean -fdX -- "Reports/Finance"

echo "Done. HEAD: $(git rev-parse --short HEAD)"
