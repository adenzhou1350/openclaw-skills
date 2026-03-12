# Service Report Generator

自动化服务报告生成工具，支持多种格式和模板。

## 功能特性

- 支持 Markdown、HTML、PDF 格式输出
- 内置多种报告模板（项目报告、周报、月报、服务报告）
- 支持自定义变量和占位符
- 支持图表生成（ASCII art）
- 定时自动生成报告

## 使用方法

```bash
# 生成项目报告
./service-report.sh generate --type project --title "Q1 System Upgrade" --output report.md

# 生成周报
./service-report.sh weekly --week 2026-W10 --output weekly.md

# 生成服务报告
./service-report.sh service --service "API Gateway" --status healthy --output service.md

# 使用模板
./service-report.sh template --name monthly --vars "month=March,year=2026"

# 列出可用模板
./service-report.sh list-templates

# 定时任务示例
./service-report.sh cron --schedule "0 9 * * 1" --type weekly
```

## 报告模板

### 项目报告模板
包含：项目概述、里程碑、团队成员、风险评估、后续计划

### 周报模板
包含：本周完成事项、进行中事项、遇到的问题、下周计划

### 月报模板
包含：月度概览、关键指标、成就与亮点、改进建议

### 服务报告模板
包含：服务名称、运行状态、可用性、响应时间、事件记录

## 输出格式

- `--format markdown` (默认)
- `--format html`
- `--format json`

## 变量系统

在模板中使用 `{{variable}}` 语法：

```markdown
# {{title}}
日期: {{date}}
服务: {{service_name}}
```

## 集成示例

### 与监控系统集成

```bash
# 监控告警时自动生成报告
./service-report.sh alert --severity critical --service $SERVICE
```

### 与定时任务集成

```bash
# 每周一生成周报
0 9 * * 1 /path/to/service-report.sh weekly -o ~/reports/weekly-$(date +\%Y-\%W).md
```

## 依赖

- bash 4.0+
- coreutils (date, printf)
- 可选: pandoc (HTML/PDF转换)
- 可选: chart.js (图表)

## License

MIT
