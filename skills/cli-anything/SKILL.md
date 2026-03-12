# CLI-Anything Skill

一键生成任意软件的 Agent-Native CLI 工具。

## 功能

- 📦 **CLI 生成**：从源码自动生成完整的 Click CLI
- 🔄 **迭代优化**：扩展已有 CLI 的功能覆盖
- ✅ **测试验证**：自动生成单元测试和 E2E 测试
- 📝 **文档完善**：自动更新测试文档
- 📤 **PyPI 发布**：一键发布到 PyPI

## 工作原理

基于 [HKUDS/CLI-Anything](https://github.com/HKUDS/CLI-Anything) 方法论，7 阶段流程：
1. **Analyze** — 扫描源码，分析架构
2. **Design** — 设计命令组、状态模型
3. **Implement** — 实现 Click CLI + REPL
4. **Plan Tests** — 生成测试计划
5. **Write Tests** — 实现测试
6. **Document** — 更新文档
7. **Publish** — 发布到 PyPI

## 使用方式

### 1. 生成 CLI

```
/cli-anything:generate <软件源码路径或GitHub URL>
```

示例：
```
/cli-anything:generate ./my-app
/cli-anything:generate https://github.com/user/repo
```

### 2. 迭代优化

```
/cli-anything:refine <CLI目录> [优化需求]
```

示例：
```
/cli-anything:refine ./my-app "添加批量处理功能"
```

### 3. 运行测试

```
/cli-anything:test <CLI目录>
```

### 4. 列出已生成的 CLI

```
/cli-anything:list
```

## 输出产物

生成目录结构：
```
my-app/
├── agent-harness/
│   ├── cli_anything/
│   │   └── myapp/
│   │       ├── core/          # 核心模块
│   │       ├── utils/         # 后端封装
│   │       └── tests/         # 测试
│   ├── myapp.md              # 设计文档
│   └── setup.py              # PyPI 配置
└── TEST.md                   # 测试文档
```

## 安装使用

生成后安装到 PATH：
```bash
cd my-app/agent-harness
pip install -e .
cli-anything-myapp --help
```

## 前提条件

- Python 3.10+
- Claude Code / OpenCode / OpenClaw 等 AI Agent
- 目标软件已安装（部分功能需要）
