# 📄 Resume Generator Skill

自动生成技术简历，支持多种模板和格式导出。

## 功能特性

- 🎯 支持多种简历模板（技术岗、产品岗、运维岗）
- 📊 自动提取 GitHub 项目技能标签
- 📄 支持 Markdown、PDF、HTML 格式导出
- 🔧 集成 LinkedIn、GitHub 数据
- ⏰ 支持定时更新简历

## 使用方法

```bash
# 生成默认技术简历
resume generate

# 指定模板
resume generate --template devops

# 导出 PDF
resume generate --format pdf

# 包含项目经验
resume generate --projects github

# 指定输出文件
resume generate -o my-resume.md
```

## 配置项

在 `~/.openclaw/config/resume.yaml` 中配置：

```yaml
name: "你的名字"
title: "Senior DevOps Engineer"
email: "you@example.com"
github: "your-github-username"
linkedin: "your-linkedin"

templates:
  default: "tech"
  alt: "modern"

export:
  formats: ["markdown", "pdf", "html"]
  theme: "minimal"
```

## 模板类型

| 模板 | 适用岗位 | 特点 |
|------|----------|------|
| tech | 软件工程师 | 强调技术技能和项目 |
| devops | DevOps/SRE | 强调自动化和运维 |
| product | 产品经理 | 强调业务和成果 |
| minimal | 通用 | 简洁风格 |

## 示例输出

```markdown
# 张三 | Senior DevOps Engineer

📧 zhangsan@example.com | 🔗 github.com/zhangsan | 🔗 linkedin.com/in/zhangsan

## 技术技能

- **云平台**: AWS, GCP, Azure
- **容器化**: Docker, Kubernetes
- **自动化**: Terraform, Ansible
- **监控**: Prometheus, Grafana

## 项目经验

### CI/CD 流水线优化
- 将部署时间从 30 分钟缩短到 5 分钟
- 使用 GitHub Actions + ArgoCD

### 监控系统重构
- 搭建 Prometheus + Grafana 监控体系
- 告警响应时间提升 70%
```

## Cron 定时更新

```bash
# 每周一早上 9 点自动更新简历
0 9 * * 1 resume generate --format pdf --output ~/resume.pdf
```

## 依赖

- pandoc (PDF 导出)
- markdownlint (格式检查)
