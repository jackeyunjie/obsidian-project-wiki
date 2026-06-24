#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME=""
TARGET_DIR=""
GLOBAL_MODE=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"

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
    -h|--help)
      echo "Usage: bash install.sh --project-name <name> [--target <path>]"
      echo "       bash install.sh --global"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
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

echo "Initialized project wiki at ${TARGET_DIR}"
