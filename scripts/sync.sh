#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
MESSAGE=""
AUTO_PUSH=false

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --message|-m)
      MESSAGE="$2"
      shift 2
      ;;
    --push)
      AUTO_PUSH=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

cd "${VAULT_DIR}"
git rev-parse --is-inside-work-tree >/dev/null

if [[ -z "${MESSAGE}" ]]; then
  MESSAGE="wiki: sync project knowledge base"
fi

git add .
if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "${MESSAGE}"
if [[ "${AUTO_PUSH}" == true ]]; then
  git push
fi
