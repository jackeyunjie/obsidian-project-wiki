# obsidian-project-wiki

> 为任意项目搭建 Obsidian + AI 的“会进化”的项目知识库。

## 一句话说明

通过 `raw/`（原始资料）+ `wiki/`（整理知识）+ `AGENTS.md`（Agent 约定）三层结构，让项目决策、操作手册、架构知识随使用自然沉淀，可被团队复用。

## 适用场景

- 软件项目需要集中管理会议纪要、需求、决策、手册
- 团队希望把 AI 对话、调研资料沉淀为可复用知识
- 个人想用 Obsidian 管理多个项目知识

## 快速安装

### 项目级使用（推荐团队）

把本 Skill 复制到项目仓库：

```bash
mkdir -p .qoder/skills/obsidian-project-wiki
cp -r /path/to/obsidian-project-wiki/* .qoder/skills/obsidian-project-wiki/
```

然后初始化项目 wiki：

```bash
mkdir -p docs/project-wiki/raw/{meetings,requirements,research,incidents,conversations}
mkdir -p docs/project-wiki/wiki/{decisions,runbooks,architecture,conventions,patterns,onboarding}
cp .qoder/skills/obsidian-project-wiki/templates/AGENTS.md docs/project-wiki/AGENTS.md
cp .qoder/skills/obsidian-project-wiki/templates/README.md docs/project-wiki/README.md
```

### 全局使用

```bash
mkdir -p ~/.qoder/skills/obsidian-project-wiki
cp -r /path/to/obsidian-project-wiki/* ~/.qoder/skills/obsidian-project-wiki/
```

### 从 GitHub 安装

```bash
# 如果 skillhub 仓库把本 Skill 放在 obsidian-project-wiki/ 子目录
mkdir -p ~/.qoder/skills/obsidian-project-wiki
cd ~/.qoder/skills/obsidian-project-wiki
git clone https://github.com/jackeyunjie/skillhub.git .
```

## 文件结构

```text
obsidian-project-wiki/
├── SKILL.md              # Skill 主文件
├── README.md             # 本文件
├── templates/
│   ├── AGENTS.md         # 项目级 Agent 约定模板
│   ├── README.md         # 项目 wiki README 模板
│   └── prompts.md        # 标准 Prompt 模板
```

## 核心工作流

```text
raw/（原始资料）
  → Agent 整理
  → wiki/（可复用知识页）
  → 基于 wiki 回答问题
  → 好回答再回写 wiki
```

## 更多信息

详见 `SKILL.md`。

## License

MIT
