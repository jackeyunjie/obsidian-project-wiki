#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
INBOX_DIR="${VAULT_DIR}/raw/inbox"
DRY_RUN=false

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "${INBOX_DIR}" ]]; then
  echo "Inbox not found: ${INBOX_DIR}" >&2
  exit 1
fi

classify_target() {
  local name
  name="$(basename "$1" | tr '[:upper:]' '[:lower:]')"
  case "${name}" in
    *meeting*|*sync*|*review*)
      echo "meetings"
      ;;
    *prd*|*requirement*|*spec*)
      echo "requirements"
      ;;
    *incident*|*postmortem*|*alert*)
      echo "incidents"
      ;;
    *chat*|*conversation*|*claude*|*codex*|*kimi*)
      echo "conversations"
      ;;
    *)
      echo "research"
      ;;
  esac
}

count=0
while IFS= read -r file; do
  target_group="$(classify_target "${file}")"
  target="${VAULT_DIR}/raw/${target_group}/$(basename "${file}")"
  echo "${file} -> ${target}"
  if [[ "${DRY_RUN}" == false ]]; then
    mv "${file}" "${target}"
  fi
  count=$((count + 1))
done < <(find "${INBOX_DIR}" -maxdepth 1 -type f ! -name '.gitkeep')

echo "Processed ${count} inbox file(s)."
