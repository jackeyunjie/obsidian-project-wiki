# {project-name} 项目知识库 Agent 约定

## 目录约定

- `raw/` 存放原始项目资料，允许未整理。
- `raw/inbox/` 是未分类入口，不长期堆积。
- `wiki/` 存放整理后的知识，必须可追溯来源。
- `outputs/` 存放机器生成报告，不写核心知识。
- 同一结论在 `wiki/` 中只保留一份权威版本。

## Ingest 原则

1. 新资料先进入 `raw/inbox/` 或明确的 raw 分类。
2. 每份高价值资料都要有来源总结页。
3. 能复用的结论进入 `wiki/` 对应分类，不停留在摘要层。
4. 页面之间必须建立 `[[...]]` 交叉链接。
5. 整理完成后汇报新增、更新、归档了哪些文件。

## Query Rule

1. 回答前先查 `wiki/`。
2. 如果 `wiki/` 已有内容，优先引用 `wiki/`。
3. 如果需要依赖 `raw/` 推断，标注“待整理入 wiki”。
4. 新形成的稳定结论要回写到 `wiki/`。

## 命名规范

- raw 文件：`YYYY-MM-DD-topic.md`
- 来源页：`wiki/source-{slug}.md`
- ADR：`wiki/decisions/adr-{number}-{slug}.md`
- runbook：`wiki/runbooks/{slug}.md`

## 健康规则

- `raw/inbox/` 不应长期积压。
- `wiki/` 页面尽量包含 frontmatter。
- 每个 wiki 页面至少要有一个 `[[...]]` 链接。
- 每个来源页都应指向具体 raw 文件。

## 归档规则

- 超过 180 天且已整理完成的 raw 文件可移到 `raw/archived/`。
- 删除 raw 前必须确认 `wiki/` 有来源链接。
