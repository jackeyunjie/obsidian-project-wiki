# Obsidian Project Wiki 标准 Prompt

## 1. 整理一份 raw 资料

```text
请读取 docs/project-wiki/raw/{path}。
基于其中内容：
1. 在 wiki/ 下创建一页来源总结页
2. 提炼关键概念、决策、待办
3. 如果需要，新建相关概念页或决策页
4. 为新旧页面增加交叉链接 [[...]]
5. 最后告诉我新增和更新了哪些文件
```

## 2. 处理 inbox

```text
请读取 docs/project-wiki/raw/inbox/ 下的所有资料。
对于每个文件：
1. 判断它应归类到哪个 raw 子目录
2. 如需保留，移动或重命名到合适目录
3. 为高价值资料创建 wiki 来源页
4. 输出处理结果清单
```

## 3. 基于 wiki 回答问题

```text
回答前先搜索 docs/project-wiki/wiki/。
如果有现成页面，基于 wiki 页面回答并引用页面名；
如果没有，再回看 raw/，并标注“待整理入 wiki”。
```

## 4. 月度知识库体检

```text
请对 docs/project-wiki/ 执行体检：
1. 汇总 raw/wiki 文件数量
2. 列出 raw/inbox/ 积压文件
3. 找出没有双链的孤立页面
4. 找出无来源链接的 wiki 页面
5. 找出死链、重复标题、缺失 frontmatter 的页面
6. 输出改进建议
```
