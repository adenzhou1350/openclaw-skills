# Data Pipeline Skill

自动化数据处理流水线工具，支持 ETL、数据转换、定时同步。

## 功能特性

- **ETL 流程**: 提取(Extract) → 转换(Transform) → 加载(Load)
- **多数据源**: 支持 JSON、CSV、API、数据库
- **数据验证**: 内置数据校验规则
- **定时同步**: Cron 定时执行
- **错误处理**: 自动重试、告警通知
- **日志追踪**: 完整执行日志

## 使用方法

```bash
# 初始化数据管道
pipeline init my-pipeline

# 添加数据源
pipeline add-source --type api --url https://api.example.com/data --name source1
pipeline add-source --type csv --path ./data/input.csv --name source2

# 添加转换规则
pipeline add-transform --name normalize --type normalize --field timestamp,value
pipeline add-transform --name filter --type filter --condition "value > 0"

# 添加目标存储
pipeline add-target --type json --path ./data/output.json
pipeline add-target --type api --url https://api.example.com/sink

# 运行管道
pipeline run

# 查看状态
pipeline status
pipeline logs

# 定时执行
pipeline schedule --cron "0 * * * *"
```

## 配置示例

```yaml
# pipeline.yaml
name: daily-sync
sources:
  - type: api
    url: ${API_URL}
    headers:
      Authorization: "Bearer ${API_TOKEN}"
    schedule: "0 8 * * *"
    
transforms:
  - type: normalize
    fields:
      - timestamp
      - value
  - type: filter
    condition: "status == 'active'"
  - type: map
    mappings:
      old_field: new_field
      
targets:
  - type: json
    path: ./output/data.json
    pretty: true
    
options:
  retry: 3
  timeout: 300
  on_error: notify
  notify_webhook: ${WEBHOOK_URL}
```

## 数据转换类型

| 类型 | 说明 |
|------|------|
| normalize | 标准化字段格式 |
| filter | 按条件过滤数据 |
| map | 字段映射/重命名 |
| aggregate | 数据聚合统计 |
| merge | 多数据源合并 |
| split | 数据拆分 |
| validate | 数据校验 |

## 定时任务集成

```bash
# 添加到 crontab
crontab -e
# 0 */6 * * * /path/to/pipeline run --config pipeline.yaml
```

## 适用场景

- 数据同步与迁移
- API 数据拉取与处理
- 日志分析流水线
- 报表数据准备
- IoT 数据预处理

---

**适合简历展示**: 数据工程、ETL、自动化运维、API 集成能力
