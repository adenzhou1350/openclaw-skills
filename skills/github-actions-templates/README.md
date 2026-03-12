# GitHub Actions 模板库

自动化 CI/CD 工作流模板集合，加速项目部署。

## 功能

- 🚀 快速开始 - 复制模板到 `.github/workflows/`
- 📦 多场景覆盖 - Node.js, Python, Docker, 定时任务等
- ⚙️ 可定制 - 灵活配置参数
- 📝 完整示例 - 包含测试、部署、通知

## 使用方法

```bash
# 列出所有可用模板
clawhub install github-actions-templates
github-actions list

# 生成模板
github-actions generate node-ci
github-actions generate python-deploy
github-actions generate docker-publish
```

## 可用模板

### 1. Node.js CI (`node-ci.yml`)
- Node.js 项目持续集成
- 支持多版本测试 (16, 18, 20)
- 自动代码检查
- 测试覆盖率报告

### 2. Python CI (`python-ci.yml`)
- Python 项目持续集成
- 支持多版本测试 (3.9, 3.10, 3.11)
- Poetry/pip 依赖管理
- 代码格式化检查

### 3. Docker 发布 (`docker-publish.yml`)
- 自动构建 Docker 镜像
- 多平台支持 (linux/amd64, linux/arm64)
- 自动推送到 Docker Hub/GHCR
- 版本标签管理

### 4. 定时任务 (`scheduled-task.yml`)
- Cron 定时执行
- 支持 Python/Node.js/Shell
- 自动通知结果
- 日志归档

### 5. 每日报告 (`daily-report.yml`)
- 定时生成项目报告
- 支持多种报告格式
- 邮件/钉钉/企业微信通知

### 6. 代码质量 (`code-quality.yml`)
- SonarCloud 集成
- 安全扫描
- 依赖审计
- 代码覆盖率检查

### 7. API 监控 (`api-monitor.yml`)
- 定时调用 API
- 响应时间监控
- 告警通知

### 8. 备份自动化 (`backup-automation.yml`)
- 定时备份数据
- 推送到 S3/GCS
- 保留策略管理

## 模板示例

### Node.js CI 模板

```yaml
name: Node.js CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16.x, 18.x, 20.x]
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'
      - run: npm ci
      - run: npm test
      - run: npm run build
```

### Docker 发布模板

```yaml
name: Docker Publish

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          push: true
          tags: user/repo:latest
```

## 集成通知

所有模板支持多种通知方式：

- 📧 邮件 (Email)
- 💬 钉钉 (DingTalk)
- 💼 企业微信 (WeCom)
- 📱 Slack
- 🐙 Discord

## 贡献模板

欢迎提交新模板！请参考 `CONTRIBUTING.md`。

## 许可证

MIT License
