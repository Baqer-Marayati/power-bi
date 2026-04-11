#!/bin/zsh

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <ModuleName> <ReportTitle>"
  echo "Example: $0 HR 'HR Reporting'"
  exit 1
fi

MODULE_NAME="$1"
REPORT_TITLE="$2"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/Shared/Templates/report-module-starter"
TARGET_DIR="$ROOT_DIR/Reports/$MODULE_NAME"
DATE_LABEL="$(date +'%B %d, %Y')"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "Template directory not found: $TEMPLATE_DIR" >&2
  exit 1
fi

if [[ -e "$TARGET_DIR" ]]; then
  echo "Target module already exists: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/Reports"
cp -R "$TEMPLATE_DIR" "$TARGET_DIR"

find "$TARGET_DIR" -type f -name '*.md' -print0 | xargs -0 perl -0pi -e \
  "s#<MODULE_NAME>#$MODULE_NAME#g; s#<REPORT_TITLE>#$REPORT_TITLE#g; s#<DATE>#$DATE_LABEL#g"

echo "Created report module: $TARGET_DIR"
echo "Next steps:"
echo "1. Copy $TARGET_DIR/Companies/_template to Companies/<CODE>/ for each company."
echo "2. Add the PBIP under the real company report folder name in Companies/<CODE>/ (keep the .pbip, .Report, and .SemanticModel stem aligned)."
echo "3. Update $TARGET_DIR/README.md and AGENTS.md with the real business scope and canonical PBIP paths."
echo "4. Update Portfolio/Memory/REPORT_CATALOG.md and Portfolio/Memory/ACTIVE_FOCUS.md when the module becomes active."
