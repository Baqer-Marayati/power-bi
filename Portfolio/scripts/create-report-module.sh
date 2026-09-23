#!/bin/zsh

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <ModuleName> <ReportTitle>"
  echo "Example: $0 HR 'HR Reporting'"
  exit 1
fi

MODULE_NAME="$1"
REPORT_TITLE="$2"
PORTFOLIO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$PORTFOLIO_DIR/.." && pwd)"
TEMPLATE_DIR="$PORTFOLIO_DIR/Shared/Templates/report-module-starter"
TARGET_DIR="$REPO_ROOT/Reports/$MODULE_NAME"
DATE_LABEL="$(date +'%B %d, %Y')"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template directory not found: $TEMPLATE_DIR" >&2
  exit 1
fi

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target module already exists: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$REPO_ROOT/Reports"
cp -R "$TEMPLATE_DIR" "$TARGET_DIR"

find "$TARGET_DIR" -type f \( -name '*.md' -o -name '*.json' \) -print0 | xargs -0 perl -0pi -e \
  "s#<MODULE_NAME>#$MODULE_NAME#g; s#<REPORT_TITLE>#$REPORT_TITLE#g; s#<DATE>#$DATE_LABEL#g"

echo "Created report module: $TARGET_DIR"
echo "Next steps:"
echo "1. Copy $TARGET_DIR/Companies/_template to Companies/<CODE>/ for each company (config and overlays only)."
echo "2. Put the report itself in Fabric/DevelopmentWorkspace/ as <Name>.pbip, <Name>.Report/, <Name>.SemanticModel/, and add it to Fabric/workspaces.json."
echo "3. Update $TARGET_DIR/README.md and AGENTS.md with the real business scope and the Fabric/ paths."
echo "4. Update Portfolio/Memory/REPORT_CATALOG.md and Portfolio/Memory/ACTIVE_FOCUS.md when the module becomes active."
echo "5. First publish: python3 Portfolio/scripts/fabric_release.py publish \"<Name>\" --create (dry run), then add --apply."
