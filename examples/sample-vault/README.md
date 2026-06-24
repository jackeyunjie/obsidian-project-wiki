# Sample Vault

这是一个最小示例 vault，用于演示：

- `raw/ -> wiki/ -> outputs/` 工作流
- `check.sh --json` 生成的健康报告结构
- Dashboard 读取 `outputs/wiki-health.json` 的方式

## 包含内容

- `raw/meetings/2026-06-22-kickoff.md`
- `raw/research/2026-06-22-database-comparison.md`
- `wiki/source-kickoff-meeting.md`
- `wiki/decisions/adr-001-choose-postgresql.md`
- `wiki/architecture/system-overview.md`
- `outputs/wiki-health.json`

## 如何体验 Dashboard

1. 用 Obsidian 打开 `examples/sample-vault/`
2. 把 `plugins/agent-dashboard/` 复制到该 vault 的 `.obsidian/plugins/agent-dashboard/`
3. 启用社区插件并打开 `Agent Dashboard`
4. Dashboard 会直接读取 `outputs/wiki-health.json`

## 说明

这个示例里的健康报告是静态样例，用于帮助理解 Dashboard 需要什么输入。
