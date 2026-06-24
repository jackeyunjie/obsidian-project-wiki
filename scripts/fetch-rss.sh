#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
FEED_URL=""
NAME="rss"

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --feed)
      FEED_URL="$2"
      shift 2
      ;;
    --name)
      NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${FEED_URL}" ]]; then
  echo "--feed is required" >&2
  exit 1
fi

OUT_DIR="${VAULT_DIR}/raw/research"
mkdir -p "${OUT_DIR}"
OUT_FILE="${OUT_DIR}/$(date +%F)-${NAME}-rss.md"

{
  echo "# RSS snapshot: ${NAME}"
  echo
  echo "- source: ${FEED_URL}"
  echo "- fetched_at: $(date -u +%FT%TZ)"
  echo
  curl -fsSL "${FEED_URL}"
} > "${OUT_FILE}"

echo "Wrote ${OUT_FILE}"
