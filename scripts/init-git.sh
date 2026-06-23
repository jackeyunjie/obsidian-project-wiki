#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# obsidian-project-wiki — Git 初始化工具
# 用法：bash init-git.sh [vault-path] [--submodule | --standalone | --monorepo]
# 默认 vault-path: docs/project-wiki
#
# 三种模式：
#   --monorepo    (默认) 把 wiki 作为项目仓库的一部分提交
#   --submodule   把 wiki 作为 Git 子模块管理
#   --standalone  为 wiki 创建独立的 Git 仓库
# ============================================================================

# ---- 颜色 ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VAULT_DIR="${1:-docs/project-wiki}"
MODE="monorepo"
REMOTE_URL=""

# ---- 参数解析 ----
shift 1 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --submodule)
      MODE="submodule"
      shift
      ;;
    --standalone)
      MODE="standalone"
      shift
      ;;
    --monorepo)
      MODE="monorepo"
      shift
      ;;
    --remote)
      REMOTE_URL="$2"
      shift 2
      ;;
    -h|--help)
      echo "用法：bash init-git.sh [vault-path] [选项]"
      echo ""
      echo "选项："
      echo "  --monorepo     把 wiki 作为项目仓库的一部分（默认）"
      echo "  --submodule    把 wiki 作为 Git 子模块"
      echo "  --standalone   为 wiki 创建独立 Git 仓库"
      echo "  --remote <url> 设置远程仓库地址（仅 standalone 模式）"
      echo "  -h, --help     显示帮助信息"
      echo ""
      echo "示例："
      echo "  bash init-git.sh docs/project-wiki --monorepo"
      echo "  bash init-git.sh docs/project-wiki --standalone --remote https://github.com/user/wiki-repo.git"
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
echo -e "${CYAN}║   Obsidian Project Wiki — Git 初始化        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Vault 路径：${BOLD}${VAULT_DIR}${NC}"
echo -e "  初始化模式：${BOLD}${MODE}${NC}"
echo ""

# ---- 检查 vault 目录 ----
if [[ ! -d "$VAULT_DIR" ]]; then
  echo -e "${RED}✗${NC} Vault 目录不存在：${VAULT_DIR}"
  echo -e "  ${YELLOW}提示：先运行 install.sh 初始化 vault${NC}"
  exit 1
fi

# ---- 检查 Git ----
if ! command -v git &>/dev/null; then
  echo -e "${RED}✗${NC} 未安装 Git，请先安装 Git"
  exit 1
fi

# ---- 模式处理 ----
case "$MODE" in
  monorepo)
    echo -e "${BOLD}[Monorepo 模式]${NC} 把 wiki 作为项目仓库的一部分"
    echo ""

    # 检查是否在 Git 仓库中
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
      echo -e "${YELLOW}→ 当前目录不是 Git 仓库，先初始化...${NC}"
      git init
      echo -e "${GREEN}  ✓${NC} Git 仓库已初始化"
    fi

    # 检查 .gitignore
    if [[ ! -f ".gitignore" ]]; then
      echo -e "${YELLOW}→ 创建 .gitignore...${NC}"
      cat > .gitignore << 'EOF'
# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json

# OS
.DS_Store
Thumbs.db
EOF
      echo -e "${GREEN}  ✓${NC} .gitignore 已创建"
    fi

    # 检查 .gitattributes
    if [[ ! -f "${VAULT_DIR}/.gitattributes" ]]; then
      echo -e "${YELLOW}→ 创建 .gitattributes...${NC}"
      cat > "${VAULT_DIR}/.gitattributes" << 'EOF'
*.md merge=union
EOF
      echo -e "${GREEN}  ✓${NC} .gitattributes 已创建（union 合并策略）"
    fi

    # 添加并提交
    echo -e "${YELLOW}→ 添加到 Git...${NC}"
    git add "${VAULT_DIR}"

    if git diff --cached --quiet; then
      echo -e "${YELLOW}  →${NC} 没有新变更需要提交"
    else
      git commit -m "feat: init project wiki" || true
      echo -e "${GREEN}  ✓${NC} 已提交到 Git"
    fi

    echo ""
    echo -e "${GREEN}${BOLD}✓ Monorepo 模式初始化完成${NC}"
    echo -e "  wiki 已作为项目仓库的一部分提交"
    echo -e "  团队成员 clone 项目后即可获得完整 wiki"
    ;;

  submodule)
    echo -e "${BOLD}[Submodule 模式]${NC} 把 wiki 作为 Git 子模块"
    echo ""

    # 检查是否在 Git 仓库中
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
      echo -e "${RED}✗${NC} 当前目录不是 Git 仓库，无法创建子模块"
      echo -e "  ${YELLOW}提示：先运行 git init，或使用 --standalone 模式${NC}"
      exit 1
    fi

    # 提取子模块名称
    SUBMODULE_NAME=$(basename "$VAULT_DIR")
    echo -e "  子模块名称：${BOLD}${SUBMODULE_NAME}${NC}"

    # 如果已有 .git，先移除
    if [[ -d "${VAULT_DIR}/.git" ]]; then
      echo -e "${YELLOW}→ 移除现有的 .git 目录...${NC}"
      rm -rf "${VAULT_DIR}/.git"
    fi

    # 创建独立的 wiki 仓库
    echo -e "${YELLOW}→ 创建独立的 wiki 仓库...${NC}"
    cd "$VAULT_DIR"
    git init
    git add .
    git commit -m "feat: init project wiki" || true
    cd - > /dev/null

    # 添加为子模块
    echo -e "${YELLOW}→ 添加为 Git 子模块...${NC}"
    git submodule add "./${VAULT_DIR}" "${SUBMODULE_NAME}" 2>/dev/null || {
      echo -e "${YELLOW}  →${NC} 子模块已存在或路径冲突，尝试更新..."
    }

    echo -e "${GREEN}  ✓${NC} 子模块已配置"
    echo ""
    echo -e "${GREEN}${BOLD}✓ Submodule 模式初始化完成${NC}"
    echo -e "  wiki 作为独立仓库管理，可单独推送"
    echo -e "  团队成员需要运行：git submodule update --init"
    ;;

  standalone)
    echo -e "${BOLD}[Standalone 模式]${NC} 为 wiki 创建独立 Git 仓库"
    echo ""

    cd "$VAULT_DIR"

    # 初始化仓库
    if [[ -d ".git" ]]; then
      echo -e "${YELLOW}→ 已存在 Git 仓库${NC}"
    else
      echo -e "${YELLOW}→ 初始化 Git 仓库...${NC}"
      git init
      echo -e "${GREEN}  ✓${NC} Git 仓库已初始化"
    fi

    # 配置 .gitignore
    if [[ ! -f ".gitignore" ]]; then
      cat > .gitignore << 'EOF'
# Obsidian
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/plugins/*/data.json

# OS
.DS_Store
Thumbs.db
EOF
      echo -e "${GREEN}  ✓${NC} .gitignore 已创建"
    fi

    # 配置 .gitattributes
    if [[ ! -f ".gitattributes" ]]; then
      cat > .gitattributes << 'EOF'
*.md merge=union
EOF
      echo -e "${GREEN}  ✓${NC} .gitattributes 已创建"
    fi

    # 首次提交
    git add .
    if git commit -m "feat: init project wiki" &>/dev/null; then
      echo -e "${GREEN}  ✓${NC} 首次提交完成"
    else
      echo -e "${YELLOW}  →${NC} 没有新变更需要提交"
    fi

    # 设置远程
    if [[ -n "$REMOTE_URL" ]]; then
      echo -e "${YELLOW}→ 设置远程仓库...${NC}"
      git remote add origin "$REMOTE_URL" 2>/dev/null || git remote set-url origin "$REMOTE_URL"
      echo -e "${GREEN}  ✓${NC} 远程仓库：${REMOTE_URL}"
      echo -e "  ${YELLOW}提示：运行 git push -u origin main 推送到远程${NC}"
    fi

    cd - > /dev/null

    echo ""
    echo -e "${GREEN}${BOLD}✓ Standalone 模式初始化完成${NC}"
    echo -e "  wiki 作为独立仓库管理"
    echo -e "  路径：${VAULT_DIR}"
    if [[ -n "$REMOTE_URL" ]]; then
      echo -e "  远程：${REMOTE_URL}"
    fi
    ;;
esac

echo ""
