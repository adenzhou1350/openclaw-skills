# Metrics Collector Skill

应用性能指标收集工具 - 采集、聚合、展示系统与应用指标。

## 功能特性

- **多源采集**: 支持系统指标、应用指标、自定义指标
- **时间序列存储**: 内置轻量级时序数据库
- **实时聚合**: 支持 Sum/Avg/Min/Max/Percentile 聚合
- **可视化报告**: 生成 Markdown/HTML 监控报告
- **告警规则**: 支持阈值告警

## 命令

```bash
metrics <command> [options]
```

### 核心命令

| 命令 | 说明 |
|------|------|
| `collect` | 采集系统指标 (CPU/内存/磁盘/网络) |
| `app` | 采集应用指标 (响应时间/错误率/QPS) |
| `query` | 查询指标数据 |
| `aggregate` | 聚合指标数据 |
| `report` | 生成监控报告 |
| `alert` | 配置告警规则 |
| `status` | 显示收集器状态 |

### 选项

| 选项 | 说明 |
|------|------|
| `--source, -s` | 指标来源 (system/app/custom) |
| `--metric, -m` | 指标名称 |
| `--from, -f` | 开始时间 |
| `--to, -t` | 结束时间 |
| `--interval, -i` | 采集间隔 (默认 60s) |
| `--format, -o` | 输出格式 (json/markdown/html) |
| `--help, -h` | 显示帮助 |

## 使用示例

### 采集系统指标

```bash
# 采集一次系统指标
metrics collect --source system

# 持续采集 (每 30 秒)
metrics collect --source system --interval 30
```

### 查询指标

```bash
# 查询 CPU 使用率
metrics query --metric cpu.usage

# 查询最近 1 小时的数据
metrics query --metric memory.usage --from -1h

# 查询特定时间范围
metrics query --metric disk.io --from 2026-03-04T10:00 --to 2026-03-04T11:00
```

### 聚合分析

```bash
# 计算平均值
metrics aggregate --metric response.time --func avg

# 计算 P99 延迟
metrics aggregate --metric latency --func percentile --p99

# 按小时聚合
metrics aggregate --metric requests --func sum --group hour
```

### 生成报告

```bash
# 生成 Markdown 报告
metrics report --format markdown --output metrics-report.md

# 生成 HTML 报告
metrics report --format html --output metrics-report.html --theme dark
```

### 配置告警

```bash
# 添加 CPU 告警规则
metrics alert add --metric cpu.usage --threshold 90 --condition gt --notify email

# 列出所有告警规则
metrics alert list

# 删除告警规则
metrics alert delete --rule cpu-high
```

## 输出示例

### 指标查询

```json
{
  "metric": "cpu.usage",
  "data": [
    {"timestamp": "2026-03-04T10:00:00Z", "value": 45.2},
    {"timestamp": "2026-03-04T10:01:00Z", "value": 48.7},
    {"timestamp": "2026-03-04T10:02:00Z", "value": 52.1}
  ],
  "count": 3,
  "min": 45.2,
  "max": 52.1,
  "avg": 48.67
}
```

### 监控报告

```markdown
# 📊 系统指标报告

生成时间: 2026-03-04 11:00:00

## CPU 使用率
- 当前: 45.2%
- 平均: 48.7%
- 峰值: 78.3%

## 内存使用
- 已用: 8.2 GB
- 可用: 3.8 GB
- 使用率: 68.3%

## 磁盘 I/O
- 读取: 125 MB/s
- 写入: 85 MB/s
```

## 适合场景

- **简历展示**: 监控系统开发、DevOps 能力、数据可视化
- **项目实践**: 学习时序数据库、指标采集、可视化
- **运维工具**: 快速搭建轻量级监控方案

## 技术栈

- Shell 脚本
- JSON 数据存储
- Markdown/HTML 报告生成

## 依赖

- 系统工具: `vmstat`, `iostat`, `df`, `free`, `uptime`
- 可选: `bc` (数学计算), `curl` (远程指标)

---

**评分**: ⭐⭐⭐⭐⭐  
**复杂度**: 中等  
**简历价值**: 监控系统、DevOps、数据处理
