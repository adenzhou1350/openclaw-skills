# Verification Loop Skill

任务验证系统，确保每个关键步骤都经过正确性检查。

## 功能

1. **检查点验证** - 在关键步骤设置验证点
2. **结果校验** - 验证命令输出/文件状态
3. **自动修复** - 发现问题时尝试自动修复
4. **报告生成** - 生成验证报告

## 使用方法

```bash
# 验证文件存在
openclaw verify file --path /path/to/file

# 验证服务运行
openclaw verify service --name nginx

# 验证端口开放
openclaw verify port --port 8080

# 验证 API 可用性
openclaw verify api --endpoint https://api.example.com

# 完整检查
openclaw verify full
```

## 工作原理

1. 定义验证规则（文件、服务、端口、API）
2. 执行验证检查
3. 记录结果（通过/失败）
4. 失败时尝试自动修复
5. 生成验证报告

## 验证类型

| 类型 | 说明 | 失败处理 |
|------|------|----------|
| file | 文件存在性 + 内容 | 创建/修复 |
| service | 服务运行状态 | 尝试启动 |
| port | 端口开放 | 报告 |
| api | API 可用性 | 重试 + 告警 |
| command | 命令执行成功 | 记录日志 |

## 配置

- 验证超时: 30秒
- 重试次数: 3
- 自动修复: true

## 相关文档

- memory/agent-architecture-analysis.md - 架构分析
