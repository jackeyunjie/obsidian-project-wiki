#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME=""
TARGET_DIR=""
GLOBAL_MODE=false
WITH_DASHBOARD=false
COPY_EXAMPLES=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"
PLUGINS_DIR="${SCRIPT_DIR}/plugins"
EXAMPLES_DIR="${SCRIPT_DIR}/examples"

usage() {
  cat <<'EOF'
Usage:
  bash install.sh --project-name <name> [--target <path>] [--with-dashboard] [--copy-examples]
  bash install.sh --global

Options:
  --project-name <name>   Name of the project (used in generated docs).
  --target <path>         Where to create the project wiki. Default: ./docs/project-wiki
  --with-dashboard        Also install the optional agent-dashboard plugin into the vault.
  --copy-examples         Copy examples/sample-vault/ into the target for reference.
  --global                Install this tool globally to ~/.qoder/skills/obsidian-project-wiki.
  -h, --help              Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --global)
      GLOBAL_MODE=true
      shift
      ;;
    --with-dashboard)
      WITH_DASHBOARD=true
      shift
      ;;
    --copy-examples)
      COPY_EXAMPLES=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "${GLOBAL_MODE}" == true ]]; then
  GLOBAL_DIR="${HOME}/.qoder/skills/obsidian-project-wiki"
  mkdir -p "${GLOBAL_DIR}"
  cp -R "${SCRIPT_DIR}/." "${GLOBAL_DIR}/"
  echo "Installed to ${GLOBAL_DIR}"
  exit 0
fi

if [[ -z "${PROJECT_NAME}" ]]; then
  PROJECT_NAME="$(basename "$(pwd)")"
fi

if [[ -z "${TARGET_DIR}" ]]; then
  TARGET_DIR="$(pwd)/docs/project-wiki"
fi

# Make TARGET_DIR absolute so later messages are unambiguous.
TARGET_DIR="$(cd "$(dirname "${TARGET_DIR}")" && pwd)/$(basename "${TARGET_DIR}")"

mkdir -p \
  "${TARGET_DIR}/raw/inbox" \
  "${TARGET_DIR}/raw/meetings" \
  "${TARGET_DIR}/raw/requirements" \
  "${TARGET_DIR}/raw/research" \
  "${TARGET_DIR}/raw/incidents" \
  "${TARGET_DIR}/raw/conversations" \
  "${TARGET_DIR}/raw/archived" \
  "${TARGET_DIR}/wiki/decisions" \
  "${TARGET_DIR}/wiki/runbooks" \
  "${TARGET_DIR}/wiki/architecture" \
  "${TARGET_DIR}/wiki/conventions" \
  "${TARGET_DIR}/wiki/patterns" \
  "${TARGET_DIR}/wiki/onboarding" \
  "${TARGET_DIR}/outputs"

find "${TARGET_DIR}/raw" "${TARGET_DIR}/wiki" -type d -exec touch "{}/.gitkeep" \;

sed "s/{project-name}/${PROJECT_NAME}/g" "${TEMPLATES_DIR}/AGENTS.md" > "${TARGET_DIR}/AGENTS.md"
sed "s/{project-name}/${PROJECT_NAME}/g" "${TEMPLATES_DIR}/README.md" > "${TARGET_DIR}/README.md"

if [[ ! -f "${TARGET_DIR}/.gitattributes" ]]; then
  printf '%s\n' '*.md merge=union' > "${TARGET_DIR}/.gitattributes"
fi

if [[ ! -f "${TARGET_DIR}/Makefile" ]]; then
  cat <<'EOF' > "${TARGET_DIR}/Makefile"
VAULT_DIR := .

.PHONY: check update ingest sync

check:
	bash scripts/check.sh $(VAULT_DIR) --json $(VAULT_DIR)/outputs/wiki-health.json

update:
	bash scripts/update.sh $(VAULT_DIR)

ingest:
	bash scripts/ingest.sh $(VAULT_DIR)

sync:
	bash scripts/sync.sh $(VAULT_DIR)
EOF
fi

if [[ "${WITH_DASHBOARD}" == true ]]; then
  DASHBOARD_TARGET="${TARGET_DIR}/.obsidian/plugins/agent-dashboard"
  mkdir -p "${DASHBOARD_TARGET}"
  cp "${PLUGINS_DIR}/agent-dashboard/main.js" \
     "${PLUGINS_DIR}/agent-dashboard/styles.css" \
     "${PLUGINS_DIR}/agent-dashboard/manifest.json" \
     "${DASHBOARD_TARGET}/"
fi

if [[ "${COPY_EXAMPLES}" == true ]]; then
  EXAMPLE_TARGET="${TARGET_DIR}/examples/sample-vault"
  mkdir -p "${EXAMPLE_TARGET}"
  cp -R "${EXAMPLES_DIR}/sample-vault/." "${EXAMPLE_TARGET}/"
fi

cat <<EOF

Initialized project wiki at ${TARGET_DIR}

Next steps:
  cd ${TARGET_DIR}
  bash scripts/ingest.sh ${TARGET_DIR}
  bash scripts/update.sh ${TARGET_DIR}
  bash scripts/check.sh ${TARGET_DIR} --json ${TARGET_DIR}/outputs/wiki-health.json
EOF

if [[ "${WITH_DASHBOARD}" == true ]]; then
  cat <<EOF

Dashboard plugin installed at:
  ${TARGET_DIR}/.obsidian/plugins/agent-dashboard/

Open Obsidian, enable community plugins, then run "Open Agent Dashboard".
EOF
else
  cat <<EOF

Optional: install the Dashboard plugin with:
  bash scripts/install.sh --target ${TARGET_DIR} --with-dashboard

Or copy it manually:
  cp -R plugins/agent-dashboard ${TARGET_DIR}/.obsidian/plugins/agent-dashboard
EOF
fi

if [[ "${COPY_EXAMPLES}" == true ]]; then
  cat <<EOF

Example vault copied to:
  ${TARGET_DIR}/examples/sample-vault/
EOF
else
  cat <<EOF

See example inputs at:
  ${SCRIPT_DIR}/examples/sample-vault/
EOF
fi
