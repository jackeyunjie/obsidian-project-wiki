# Agent Dashboard

`agent-dashboard` 是 `obsidian-project-wiki` 的可选 Obsidian 插件 MVP。

它的目标不是替代命令行脚本，而是在 Obsidian 内提供一个轻量操作面板，展示项目知识库当前状态，并提示下一步该做什么。

## 安装

1. 打开你的 vault 根目录。
2. 创建目录：

```text
.obsidian/plugins/agent-dashboard/
```

3. 复制以下文件到该目录：

- `manifest.json`
- `main.js`
- `styles.css`

4. 在 Obsidian 中启用社区插件。
5. 打开命令面板，执行 `Open Agent Dashboard`。

打开后可以点击右上角的 `Refresh` 按钮，重新读取：

- `outputs/wiki-health.json`
- 最近更新文件列表

## 依赖的数据和目录

插件假设你的 vault 使用 `obsidian-project-wiki` 推荐结构：

```text
raw/
wiki/
outputs/wiki-health.json
```

它会读取：

- `outputs/wiki-health.json`
- vault 内所有 Markdown 文件

## 当前显示内容

- 健康分 `health_score`
- `raw/inbox/`、`raw/`、`wiki/` 文件数量
- `wiki-health.json.metrics` 中的各项指标
- 最近更新的 Markdown 文件
- 手动刷新按钮
- 一个固定的 runbook 提示区

## `wiki-health.json` 数据契约

插件当前依赖的最小 JSON 结构如下：

```json
{
  "health_score": 100,
  "metrics": {
    "raw_count": 0,
    "wiki_count": 0,
    "inbox_count": 0
  }
}
```

完整示例见：

- `examples/sample-vault/outputs/wiki-health.json`

推荐由以下命令生成：

```bash
bash scripts/check.sh docs/project-wiki --json docs/project-wiki/outputs/wiki-health.json
```

## 当前边界

- 不直接执行 shell 命令
- 不自动刷新外部采集数据
- 不写回 vault
- 不提供设置页
- 不处理移动端专属交互优化

## 适用定位

这个版本适合作为：

- 项目 wiki 的起始主页
- Agent 工作流 runbook 面板
- 健康检查结果的可视化入口

它还不适合作为完整的 Obsidian 工作台产品。

## 维护说明

如果你扩展了 `scripts/check.sh` 的 JSON 输出，优先保持已有字段兼容，再新增字段。当前插件对缺失字段容忍度较高，但默认只消费最基础的健康信息。
