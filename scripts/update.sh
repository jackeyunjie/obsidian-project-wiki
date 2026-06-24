#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"

if [[ ! -d "${VAULT_DIR}" ]]; then
  echo "Vault not found: ${VAULT_DIR}" >&2
  exit 1
fi

NEW_FILES="$(find "${VAULT_DIR}/raw" -type f -name '*.md' ! -path '*/archived/*' | sort)"
if [[ -z "${NEW_FILES}" ]]; then
  echo "No raw files found."
  exit 0
fi

echo "# Project wiki update task"
echo
echo "Process the following raw files:"
echo
while IFS= read -r file; do
  rel="${file#${VAULT_DIR}/}"
  echo "- ${rel}"
done <<< "${NEW_FILES}"
echo
cat <<'EOF'
Instructions:
1. Read each raw file.
2. Create or update source summary pages under wiki/.
3. Extract reusable concepts, decisions, runbooks, or patterns.
4. Add [[...]] links to related pages.
5. Report created and updated files.
EOF
