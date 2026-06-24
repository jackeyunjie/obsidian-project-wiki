---
name: obsidian-project-wiki
version: 2.0.0
description: |
  为任意项目搭建 Obsidian + AI 的“会进化”的项目知识库。
  通过 raw（原始资料）+ wiki（整理知识）+ AGENTS.md（Agent 约定）三层结构，
  配合 ingest、health check、external fetch 和可选 Dashboard，
  让项目知识沉淀为可追溯、可操作、可复用的资产。
author: jackeyunjie
repo: https://github.com/jackeyunjie/obsidian-project-wiki
---

# Obsidian Project Wiki

## 这个 Skill 解决什么问题

- 项目资料分散，找结论靠记忆。
- AI 对话很有价值，但没有沉淀路径。
- 知识库只有 Markdown 目录，没有稳定工作流。
- 团队需要一个轻量、Git 友好、可持续演进的项目 wiki。

## 核心结构

```text
docs/project-wiki/
├── AGENTS.md
├── raw/
│   ├── inbox/
│   ├── meetings/
│   ├── requirements/
│   ├── research/
│   ├── incidents/
│   ├── conversations/
│   └── archived/
├── wiki/
│   ├── decisions/
│   ├── runbooks/
│   ├── architecture/
│   ├── conventions/
│   ├── patterns/
│   └── onboarding/
└── outputs/
    └── wiki-health.json
```

## 快速开始

### 初始化

```bash
bash scripts/install.sh --project-name my-project
```

### 摄入 inbox

```bash
bash scripts/ingest.sh docs/project-wiki
```

### 生成整理任务

```bash
bash scripts/update.sh docs/project-wiki
```

### 知识库体检

```bash
bash scripts/check.sh docs/project-wiki --json docs/project-wiki/outputs/wiki-health.json
```

### 可选外部采集

```bash
bash scripts/fetch-rss.sh docs/project-wiki --feed "https://openai.com/news/rss.xml" --name openai
bash scripts/fetch-github.sh docs/project-wiki --repo openai/openai-python --type releases
```

## Dashboard 说明

`plugins/agent-dashboard/` 是可选 Obsidian 插件模板，适合作为 Agent 工作台 MVP。它不替代脚本，只消费脚本产物：

- `outputs/wiki-health.json`
- `raw/` 与 `wiki/` 文件统计
- 最近更新文件

## 标准工作流

1. 新资料进入 `raw/inbox/` 或其他 raw 子目录。
2. 运行 `ingest.sh` 补齐分类或移动到对应目录。
3. 运行 `update.sh` 生成 Agent 整理指令。
4. Agent 把高价值内容沉淀到 `wiki/`。
5. 运行 `check.sh` 生成健康报告。
6. 运行 `sync.sh` 同步到 Git。

## 体检重点

- 目录结构完整性
- `raw` 未整理数量
- 来源页覆盖率
- 孤立页面
- 死链
- 元数据覆盖率
- 重复标题

## 注意事项

- 外部采集脚本依赖网络，默认保持可选。
- `check.sh --fix` 只做低风险修复。
- Dashboard 只是 UI 层，不存储业务状态。
