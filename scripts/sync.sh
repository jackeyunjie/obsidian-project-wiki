#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# obsidian-project-wiki — Git 同步脚本
# 用法：bash sync.sh [vault-path] [--message "commit message"]
# 默认 vault-path: docs/project-wiki
# ============================================================================

# ---- 颜色 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VAULT_DIR="${1:-docs/project-wiki}"
COMMIT_MSG=""
AUTO_PUSH=false
DRY_RUN=false

# ---- 参数解析 ----
shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --message|-m)
      COMMIT_MSG="$2"
      shift 2
      ;;
    --push)
      AUTO_PUSH=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      echo "用法：bash sync.sh [vault-path] [选项]"
      echo ""
      echo "选项："
      echo "  --message, -m <msg>  自定义提交信息（默认：自动生成）"
      echo "  --push               自动推送到远程"
      echo "  --dry-run            只显示将要执行的操作，不实际执行"
      echo "  -h, --help           显示帮助信息"
      exit 0
      ;;
    *)
      echo -e "${RED}未知参数: $1${NC}"
      exit 1
      ;;
  esac
done

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Obsidian Project Wiki — Git 同步          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Vault 路径：${BOLD}${VAULT_DIR}${NC}"
echo ""

# ---- 检查 vault 目录 ----
if [[ ! -d "$VAULT_DIR" ]]; then
  echo -e "${RED}✗${NC} Vault 目录不存在：${VAULT_DIR}"
  exit 1
fi

cd "$VAULT_DIR"

# ---- 检查 Git 仓库 ----
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo -e "${RED}✗${NC} Vault 目录不是 Git 仓库"
  echo -e "  ${YELLOW}建议：git init && git add . && git commit -m \"init\"${NC}"
  exit 1
fi

# ---- 检查变更 ----
if git diff --quiet --cached && git diff --quiet; then
  echo -e "${GREEN}✓${NC} 没有待提交的变更"
  exit 0
fi

# ---- 统计变更 ----
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

echo -e "  已暂存：${BOLD}${STAGED}${NC} 个文件"
echo -e "  未暂存：${BOLD}${UNSTAGED}${NC} 个文件"
echo -e "  未跟踪：${BOLD}${UNTRACKED}${NC} 个文件"
echo ""

# ---- 生成提交信息 ----
if [[ -z "$COMMIT_MSG" ]]; then
  # 自动分析变更内容生成提交信息
  CHANGED_FILES=$(git diff --cached --name-only --diff-filter=AM 2>/dev/null || true)
  if [[ -z "$CHANGED_FILES" ]]; then
    CHANGED_FILES=$(git diff --name-only 2>/dev/null || true)
  fi

  # 判断变更类型
  NEW_RAW=$(echo "$CHANGED_FILES" | grep -c "^raw/" 2>/dev/null || true)
  NEW_WIKI=$(echo "$CHANGED_FILES" | grep -c "^wiki/" 2>/dev/null || true)
  NEW_AGENTS=$(echo "$CHANGED_FILES" | grep -c "AGENTS.md" 2>/dev/null || true)

  if [[ "$NEW_WIKI" -gt 0 && "$NEW_RAW" -gt 0 ]]; then
    COMMIT_MSG="wiki: update knowledge base + add raw materials"
  elif [[ "$NEW_WIKI" -gt 0 ]]; then
    COMMIT_MSG="wiki: update knowledge pages"
  elif [[ "$NEW_RAW" -gt 0 ]]; then
    COMMIT_MSG="raw: add new materials"
  elif [[ "$NEW_AGENTS" -gt 0 ]]; then
    COMMIT_MSG="chore: update AGENTS.md"
  else
    COMMIT_MSG="chore: sync project wiki"
  fi
fi

echo -e "  提交信息：${BOLD}${COMMIT_MSG}${NC}"

if [[ "$DRY_RUN" == true ]]; then
  echo -e "${YELLOW}[dry-run] 将要执行：${NC}"
  echo -e "  git add ."
  echo -e "  git commit -m \"${COMMIT_MSG}\""
  if [[ "$AUTO_PUSH" == true ]]; then
    echo -e "  git push"
  fi
  exit 0
fi

# ---- 执行提交 ----
echo ""
echo -e "${YELLOW}→ 执行同步...${NC}"

git add .

if git commit -m "$COMMIT_MSG" &>/dev/null; then
  echo -e "${GREEN}  ✓${NC} 提交成功：${COMMIT_MSG}"
else
  echo -e "${YELLOW}  →${NC} 没有新变更需要提交"
  exit 0
fi

# ---- 推送 ----
if [[ "$AUTO_PUSH" == true ]]; then
  if git remote get-url origin &>/dev/null 2>&1; then
    echo -e "${YELLOW}→ 推送到远程...${NC}"
    if git push; then
      echo -e "${GREEN}  ✓${NC} 推送成功"
    else
      echo -e "${RED}  ✗${NC} 推送失败，请检查远程仓库配置"
    fi
  else
    echo -e "${YELLOW}  →${NC} 未配置远程仓库，跳过推送"
    echo -e "  ${YELLOW}提示：git remote add origin <url>${NC}"
  fi
fi

echo ""
echo -e "${GREEN}${BOLD}同步完成！${NC}"
echo ""
