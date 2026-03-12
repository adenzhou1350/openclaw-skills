# Deep Researcher Skill

## 简介

专门用于深度研究的 Agent 技能。

## 研究流程

1. **理解问题** - 明确研究目标和范围
2. **搜索信息** - 使用 web_search, web_fetch 收集资料
3. **分析整理** - 阅读论文、文档、技术报告
4. **深度思考** - 分析技术细节和实现方案
5. **输出总结** - 整理研究发现，写入 memory/

## 工具

- web_search - 搜索网络
- web_fetch - 获取网页内容
- read - 读取本地文件
- write - 写入研究笔记

## 研究主题

- Agent 持续迭代 (SWE-agent, mini-SWE-agent)
- 具身智能 (机器人, Sim2Real)
- AI Agent 框架 (Dify, OpenHands, Continue)

## 输出格式

```markdown
# [研究主题]

## 核心发现

## 技术细节

## 相关项目

## 下一步建议
```

## 使用方法

```
请用 Deep Researcher 研究 [主题]，并把研究发现写入 memory/career-research/[主题].md
```
