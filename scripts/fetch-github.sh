#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
REPO=""
TYPE="releases"

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --type)
      TYPE="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${REPO}" ]]; then
  echo "--repo is required" >&2
  exit 1
fi

OUT_DIR="${VAULT_DIR}/raw/research"
mkdir -p "${OUT_DIR}"
OUT_FILE="${OUT_DIR}/$(date +%F)-$(echo "${REPO}" | tr '/' '-')-${TYPE}.md"

API_URL="https://api.github.com/repos/${REPO}/${TYPE}"

{
  echo "# GitHub ${TYPE}: ${REPO}"
  echo
  echo "- source: ${API_URL}"
  echo "- fetched_at: $(date -u +%FT%TZ)"
  echo
  curl -fsSL -H 'Accept: application/vnd.github+json' "${API_URL}"
} > "${OUT_FILE}"

echo "Wrote ${OUT_FILE}"
