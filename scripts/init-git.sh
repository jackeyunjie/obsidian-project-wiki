#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
MODE="monorepo"
REMOTE_URL=""

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --standalone|--monorepo|--submodule)
      MODE="${1#--}"
      shift
      ;;
    --remote)
      REMOTE_URL="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

case "${MODE}" in
  monorepo)
    git add "${VAULT_DIR}"
    ;;
  standalone)
    (
      cd "${VAULT_DIR}"
      git init
      git add .
      git commit -m "feat: init project wiki" || true
      if [[ -n "${REMOTE_URL}" ]]; then
        git remote add origin "${REMOTE_URL}" 2>/dev/null || git remote set-url origin "${REMOTE_URL}"
      fi
    )
    ;;
  submodule)
    echo "Submodule mode requires a dedicated remote repository." >&2
    exit 1
    ;;
esac

echo "Initialized Git mode: ${MODE}"
