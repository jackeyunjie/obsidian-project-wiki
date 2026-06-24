# {project-name} 项目知识库

这是 `{project-name}` 的 Obsidian 项目知识库，采用 `raw/ + wiki/ + outputs/` 结构。

## 目录说明

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
└── outputs/
```

## 使用方式

1. 用 Obsidian 打开 `docs/project-wiki/`。
2. 新资料先放进 `raw/inbox/` 或对应 raw 子目录。
3. 运行 `bash scripts/ingest.sh docs/project-wiki` 处理待分类资料。
4. 运行 `bash scripts/update.sh docs/project-wiki` 生成整理任务。
5. 整理完成后运行 `bash scripts/check.sh docs/project-wiki --json docs/project-wiki/outputs/wiki-health.json`。

## 建议节奏

- 每天清理 `raw/inbox/`
- 每周执行一次健康检查
- 每月归档陈旧 raw，并补齐来源页
