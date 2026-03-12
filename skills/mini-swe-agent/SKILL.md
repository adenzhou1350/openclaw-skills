# mini-SWE-agent Skill

在 OpenClaw 中调用 mini-SWE-agent 自动修复 GitHub Issue。

## 功能

自动修复 GitHub 仓库中的 Issue。适合：
- 自动修复 bug
- 实现新功能
- 代码重构

## 安装

已预装在 OpenClaw 环境中：
```bash
pip install mini-swe-agent
```

## 使用方法

### 在 OpenClaw 中使用 Skill

```
请用 mini-swe-agent 修复 demo/swe-agent-test/calculator.py 中的除零错误
```

### 命令行

```bash
# 使用默认配置
mini -t "Fix the bug in function foo"

# 指定模型
mini -m openai/gpt-4o -t "Your task"

# 无确认模式 (yolo)
mini -y -t "Your task"

# 成本限制
mini -l 5.0 -t "Your task"
```

### Python API

```python
from minisweagent import MiniSWEAgent

# 初始化 agent
agent = MiniSWEAgent(
    model="openai/gpt-4o",
    # 或其他兼容模型
)

# 运行任务
result = agent.run("Fix the bug in function foo")
print(result["submission"])
```

## 关键特性

- **极简**: ~100 行 Python 代码
- **高性能**: SWE-bench verified >74%
- **通用**: 支持任意 LLM (通过 litellm)
- **无状态**: 每次执行独立，易于沙盒化

## 测试项目

已准备测试项目: `demo/swe-agent-test/`
- calculator.py: 有 bug 的计算器（除零错误）

## 参考

- 官网: https://mini-swe-agent.com
- GitHub: https://github.com/SWE-agent/mini-swe-agent
