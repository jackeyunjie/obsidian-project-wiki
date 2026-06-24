# obsidian-project-wiki

> 为任意项目搭建 Obsidian + AI 的可进化项目知识库，并提供可选的 Agent Dashboard。

## 一句话说明

通过 `raw/`、`wiki/`、`AGENTS.md` 三层结构，加上体检、摄入、采集和 Dashboard，把项目知识沉淀成可追溯、可操作、可复用的资产。

## 这次升级带来了什么

- `check.sh` 支持 `--json` 机器可读健康报告。
- 新增 `ingest.sh`，处理 `raw/inbox/` 摄入流程。
- 新增 `fetch-rss.sh` 与 `fetch-github.sh`，把外部信息落到 `raw/research/`。
- 新增可选 `plugins/agent-dashboard/`，作为 Obsidian 内的操作面板 MVP。
- 模板和提示词同步升级，围绕 inbox、健康检查、来源追溯展开。

## 快速安装

```bash
git clone https://github.com/jackeyunjie/obsidian-project-wiki.git
cd obsidian-project-wiki
bash scripts/install.sh --project-name your-project-name
```

## 升级后的结构

```text
obsidian-project-wiki/
├── SKILL.md
├── README.md
├── _meta.json
├── scripts/
│   ├── install.sh
│   ├── init-git.sh
│   ├── update.sh
│   ├── ingest.sh
│   ├── fetch-rss.sh
│   ├── fetch-github.sh
│   ├── check.sh
│   └── sync.sh
├── templates/
│   ├── AGENTS.md
│   ├── README.md
│   ├── prompts.md
│   └── obsidian-config.json
├── plugins/
│   └── agent-dashboard/
└── examples/
    └── sample-vault/
```

## 推荐工作流

```text
raw/inbox -> 分类进入 raw/* -> Agent 整理 -> wiki/* -> health check -> Git sync
```

示例：

```bash
bash scripts/install.sh --project-name my-project
bash scripts/ingest.sh docs/project-wiki
bash scripts/update.sh docs/project-wiki
bash scripts/check.sh docs/project-wiki --json outputs/wiki-health.json
bash scripts/sync.sh docs/project-wiki --push
```

## Dashboard

`plugins/agent-dashboard/` 是可选的 Obsidian 插件 MVP，不替代脚本本身。它读取 vault 内的 `outputs/wiki-health.json`，展示：

- 健康分和关键问题
- 待整理 inbox / raw 数量
- 最近更新文件
- 常用操作按钮

## 核心原则

- Obsidian 只是入口，知识依旧落在 Markdown。
- Agent 负责整理，不直接替代来源追溯。
- 外部采集是可选层，不阻塞基础使用。
- Dashboard 是交互层，不承载核心逻辑。

## License

MIT
