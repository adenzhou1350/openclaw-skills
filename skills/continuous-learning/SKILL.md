# Continuous Learning Skill

从会话历史中自动提取知识、模式和解决方案，持续丰富 Agent 能力。

## 功能

1. **会话分析** - 读取最近会话，提取有价值的信息
2. **模式提取** - 识别可复用的工作流、解决方案、错误修复
3. **知识入库** - 自动更新 MEMORY.md 和 Skills
4. **学习报告** - 生成学习总结

## 使用方法

```bash
# 分析最近会话，提取新知识
openclaw continuous-learning analyze

# 提取特定主题的模式
openclaw continuous-learning extract --topic "git"

# 生成学习报告
openclaw continuous-learning report
```

## 工作原理

1. 读取 sessions_history（最近 N 条会话）
2. 识别关键模式：
   - 成功的解决方案
   - 常用的工作流
   - 常见错误及修复
   - 用户偏好
3. 提取为结构化知识
4. 更新 MEMORY.md 相关章节
5. 建议新的 Skills（如果发现新的模式）

## 配置

- 分析会话数: 50
- 最小模式出现次数: 2
- 输出目录: memory/learning/

## 相关文档

- memory/agent-architecture-analysis.md - 架构分析
- MEMORY.md - 长期记忆
