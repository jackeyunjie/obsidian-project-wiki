#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# obsidian-project-wiki — 自动更新触发器
# 用法：bash update.sh [vault-path]
# 默认 vault-path: docs/project-wiki
#
# 功能：
#   1. 扫描 raw/ 中未整理的新文件
#   2. 生成 Agent 可用的整理指令
#   3. 可选：直接调用 Agent CLI 执行整理（如果配置了）
# ============================================================================

# ---- 颜色 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VAULT_DIR="${1:-docs/project-wiki}"
AUTO_MODE=false

# ---- 参数解析 ----
shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto)
      AUTO_MODE=true
      shift
      ;;
    -h|--help)
      echo "用法：bash update.sh [vault-path] [选项]"
      echo ""
      echo "选项："
      echo "  --auto    尝试自动调用 Agent CLI 执行整理（需配置）"
      echo "  -h, --help  显示帮助信息"
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
echo -e "${CYAN}║   Obsidian Project Wiki — 自动更新          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Vault 路径：${BOLD}${VAULT_DIR}${NC}"
echo ""

# ---- 检查 vault 目录 ----
if [[ ! -d "$VAULT_DIR" ]]; then
  echo -e "${RED}✗${NC} Vault 目录不存在：${VAULT_DIR}"
  exit 1
fi

# ---- 扫描 raw/ 中的新文件 ----
echo -e "${BOLD}[1/3] 扫描 raw/ 中的新文件...${NC}"

RAW_FILES=$(find "${VAULT_DIR}/raw" -name '*.md' -type f ! -path '*/archived/*' 2>/dev/null | sort)
WIKI_SOURCES=$(find "${VAULT_DIR}/wiki" -name 'source-*.md' -type f 2>/dev/null | xargs grep -l "来源文件" 2>/dev/null || true)

NEW_FILES=()
if [[ -n "$RAW_FILES" ]]; then
  while IFS= read -r file; do
    BASENAME=$(basename "$file")
    # 检查是否已有对应的 source- 页
    SLUG=$(echo "$BASENAME" | sed 's/\.md$//' | sed 's/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    if ! echo "$WIKI_SOURCES" | grep -q "source-.*${SLUG}" 2>/dev/null; then
      NEW_FILES+=("$file")
    fi
  done <<< "$RAW_FILES"
fi

if [[ ${#NEW_FILES[@]} -eq 0 ]]; then
  echo -e "${GREEN}  ✓${NC} 没有新的 raw 文件需要整理"
  echo -e "  ${YELLOW}提示：放入新文件到 raw/ 后再运行此脚本${NC}"
  exit 0
fi

echo -e "  发现 ${BOLD}${#NEW_FILES[@]}${NC} 个新文件："
for f in "${NEW_FILES[@]}"; do
  echo -e "    - ${CYAN}$(basename "$f")${NC}"
done

# ---- 生成整理指令 ----
echo ""
echo -e "${BOLD}[2/3] 生成整理指令...${NC}"

PROMPT_FILE="/tmp/opw-update-prompt-$(date +%s).md"

cat > "$PROMPT_FILE" << EOF
# 项目知识库自动整理任务

## 待整理的 raw 文件

EOF

for f in "${NEW_FILES[@]}"; do
  REL_PATH=$(realpath --relative-to="$(pwd)" "$f" 2>/dev/null || echo "$f")
  echo "- ${REL_PATH}" >> "$PROMPT_FILE"
done

cat >> "$PROMPT_FILE" << 'EOF'

## 整理要求

请依次处理上述每个文件：

1. **读取文件内容**，理解其核心信息
2. **创建来源总结页**：在 wiki/ 下创建 
   
   命名格式：wiki/source-{slug}.md
   
   内容结构：
   - 来源文件链接：[[raw/xxx.md]]
   - 这份资料讲了什么（2-3 句话）
   - 为什么保留（价值判断）
   - 关键结论（ bullet points ）
   - 关键决策（如有）

3. **提炼概念/决策**：如果资料包含重要概念、技术决策、操作步骤，
   在 wiki/ 对应分类下创建独立页面：
   - 决策 → wiki/decisions/adr-xxx.md
   - 架构 → wiki/architecture/xxx.md
   - 手册 → wiki/runbooks/xxx.md
   - 规范 → wiki/conventions/xxx.md
   - 模式 → wiki/patterns/xxx.md

4. **添加双链**：为新页面和已有页面添加 [[...]] 双向链接

5. **汇报改动**：列出新增和更新的文件清单

## 注意事项

- 如果资料已过时或价值低，标注为 "待归档" 而非创建 wiki 页
- 如果资料内容与已有 wiki 页重复，更新现有页面而非新建
- 保持 wiki 页面结构一致：一句话定义 → 为什么重要 → 具体内容 → 关联页面 → 来源
EOF

echo -e "  ${GREEN}✓${NC} 整理指令已生成：${PROMPT_FILE}"

# ---- 输出或自动执行 ----
echo ""
echo -e "${BOLD}[3/3] 整理指令${NC}"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
cat "$PROMPT_FILE"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo ""

if [[ "$AUTO_MODE" == true ]]; then
  echo -e "${YELLOW}→ 尝试自动调用 Agent...${NC}"

  # 检测可用的 Agent CLI
  AGENT_CMD=""
  if command -v claude &>/dev/null; then
    AGENT_CMD="claude"
  elif command -v codex &>/dev/null; then
    AGENT_CMD="codex"
  elif command -v qoder &>/dev/null; then
    AGENT_CMD="qoder"
  elif command -v kimi &>/dev/null; then
    AGENT_CMD="kimi"
  fi

  if [[ -n "$AGENT_CMD" ]]; then
    echo -e "  检测到 Agent CLI：${BOLD}${AGENT_CMD}${NC}"
    echo -e "  ${YELLOW}提示：请手动将上述 prompt 粘贴到 Agent 中执行${NC}"
    echo -e "  ${YELLOW}      当前版本暂不支持直接调用 Agent CLI${NC}"
  else
    echo -e "  ${YELLOW}未检测到 Agent CLI，请手动执行${NC}"
  fi
else
  echo -e "${BOLD}使用方法：${NC}"
  echo -e "  1. 复制上述 prompt 内容"
  echo -e "  2. 粘贴到你的 Agent（Claude / Codex / Qoder / Kimi）"
  echo -e "  3. Agent 会自动读取 raw 文件并整理到 wiki/"
  echo ""
  echo -e "  或运行：${CYAN}bash update.sh --auto${NC} 尝试自动检测 Agent"
fi

echo ""
