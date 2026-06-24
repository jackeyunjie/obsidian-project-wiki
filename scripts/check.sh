#!/usr/bin/env bash
set -euo pipefail

VAULT_DIR="${1:-docs/project-wiki}"
REPORT_FILE=""
JSON_FILE=""
FIX_MODE=false

shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)
      REPORT_FILE="$2"
      shift 2
      ;;
    --json)
      JSON_FILE="$2"
      shift 2
      ;;
    --fix)
      FIX_MODE=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "${VAULT_DIR}" ]]; then
  echo "Vault not found: ${VAULT_DIR}" >&2
  exit 1
fi

mkdir -p "${VAULT_DIR}/outputs"
if [[ -z "${REPORT_FILE}" ]]; then
  REPORT_FILE="${VAULT_DIR}/outputs/wiki-health-report.md"
fi

raw_count="$(find "${VAULT_DIR}/raw" -type f -name '*.md' | wc -l | tr -d ' ')"
wiki_count="$(find "${VAULT_DIR}/wiki" -type f -name '*.md' | wc -l | tr -d ' ')"
inbox_count="$(find "${VAULT_DIR}/raw/inbox" -type f 2>/dev/null | wc -l | tr -d ' ')"
stale_count="$(find "${VAULT_DIR}/wiki" -type f -name '*.md' -mtime +90 2>/dev/null | wc -l | tr -d ' ')"

orphan_count=0
missing_frontmatter_count=0
source_page_count=0
broken_link_count=0
duplicate_title_count=0

declare -a wiki_files
while IFS= read -r file; do
  wiki_files+=("${file}")
done < <(find "${VAULT_DIR}/wiki" -type f -name '*.md' | sort)

declare -a titles
for file in "${wiki_files[@]:-}"; do
  if ! grep -q '\[\[' "${file}" 2>/dev/null; then
    orphan_count=$((orphan_count + 1))
  fi
  if ! head -n 1 "${file}" | grep -q '^---'; then
    missing_frontmatter_count=$((missing_frontmatter_count + 1))
  fi
  if grep -q '来源' "${file}" || grep -q 'source:' "${file}"; then
    source_page_count=$((source_page_count + 1))
  fi
  title="$(grep -m1 '^# ' "${file}" | sed 's/^# //')"
  if [[ -n "${title}" ]]; then
    titles+=("${title}")
  fi
done

if [[ "${#titles[@]}" -gt 0 ]]; then
  duplicate_title_count="$(printf '%s\n' "${titles[@]}" | sort | uniq -d | wc -l | tr -d ' ')"
fi

for file in "${wiki_files[@]:-}"; do
  while IFS= read -r link; do
    target_name="${link#[[}"
    target_name="${target_name%]]}"
    if ! find "${VAULT_DIR}/wiki" -type f -name "${target_name}.md" | grep -q .; then
      broken_link_count=$((broken_link_count + 1))
    fi
  done < <(grep -o '\[\[[^]]\+\]\]' "${file}" || true)
done

if [[ "${wiki_count}" -gt 0 ]]; then
  source_coverage_pct=$((source_page_count * 100 / wiki_count))
  frontmatter_coverage_pct=$(((wiki_count - missing_frontmatter_count) * 100 / wiki_count))
else
  source_coverage_pct=0
  frontmatter_coverage_pct=0
fi

health_score=100
health_score=$((health_score - inbox_count * 5))
health_score=$((health_score - orphan_count * 4))
health_score=$((health_score - broken_link_count * 3))
health_score=$((health_score - missing_frontmatter_count * 2))
health_score=$((health_score - duplicate_title_count * 5))
if [[ "${health_score}" -lt 0 ]]; then
  health_score=0
fi

if [[ "${FIX_MODE}" == true ]]; then
  mkdir -p "${VAULT_DIR}/outputs"
fi

cat > "${REPORT_FILE}" <<EOF
# Knowledge Base Health Report

- vault: ${VAULT_DIR}
- generated_at: $(date -u +%FT%TZ)
- health_score: ${health_score}

## Counts

- raw_count: ${raw_count}
- wiki_count: ${wiki_count}
- inbox_count: ${inbox_count}
- stale_wiki_count: ${stale_count}
- orphan_count: ${orphan_count}
- broken_link_count: ${broken_link_count}
- missing_frontmatter_count: ${missing_frontmatter_count}
- duplicate_title_count: ${duplicate_title_count}
- source_page_count: ${source_page_count}
- source_coverage_pct: ${source_coverage_pct}
- frontmatter_coverage_pct: ${frontmatter_coverage_pct}
EOF

if [[ -n "${JSON_FILE}" ]]; then
  mkdir -p "$(dirname "${JSON_FILE}")"
  cat > "${JSON_FILE}" <<EOF
{
  "vault_path": "$(printf '%s' "${VAULT_DIR}" | sed 's/"/\\"/g')",
  "generated_at": "$(date -u +%FT%TZ)",
  "health_score": ${health_score},
  "metrics": {
    "raw_count": ${raw_count},
    "wiki_count": ${wiki_count},
    "inbox_count": ${inbox_count},
    "stale_wiki_count": ${stale_count},
    "orphan_count": ${orphan_count},
    "broken_link_count": ${broken_link_count},
    "missing_frontmatter_count": ${missing_frontmatter_count},
    "duplicate_title_count": ${duplicate_title_count},
    "source_page_count": ${source_page_count},
    "source_coverage_pct": ${source_coverage_pct},
    "frontmatter_coverage_pct": ${frontmatter_coverage_pct}
  }
}
EOF
fi

echo "Health score: ${health_score}"
echo "Report: ${REPORT_FILE}"
if [[ -n "${JSON_FILE}" ]]; then
  echo "JSON: ${JSON_FILE}"
fi
