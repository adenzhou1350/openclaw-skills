# ⏰ Cron Manager Skill

定时任务管理器 - 轻松管理 OpenClaw 定时任务

## 功能特性

- ✅ 列出所有定时任务
- ✅ 添加新的定时任务
- ✅ 删除定时任务
- ✅ 查看任务执行日志
- ✅ 支持 cron 表达式
- ✅ 任务状态监控

## 使用方法

### 列出所有定时任务

```bash
# 列出所有任务
openclaw cron list

# 查看任务详情
openclaw cron list --verbose
```

### 添加定时任务

```bash
# 添加每日早报任务
openclaw cron add "daily-report" "0 7 * * *" "scripts/morning_report.sh"

# 添加每小时检查任务
openclaw cron add "hourly-check" "0 * * *" "scripts/hourly_check.sh"
```

### 删除定时任务

```bash
openclaw cron remove "daily-report"
```

### 查看日志

```bash
# 查看最近日志
openclaw cron logs

# 查看特定任务日志
openclaw cron logs daily-report --lines 50
```

## 任务示例

| 任务名 | 表达式 | 说明 |
|--------|--------|------|
| morning-report | 0 7 * * * | 每日早上 7 点早报 |
| hourly-check | 0 * * * * | 每小时系统检查 |
| weekly-backup | 0 2 * * 0 | 每周日凌晨备份 |
| weather-alert | 0 6,18 * * * | 早晚天气提醒 |

## 集成

与 OpenClaw cron 系统无缝集成：

```bash
# 查看 OpenClaw 定时任务
crontab -l | grep openclaw

# 添加到系统 crontab
openclaw cron install
```

## 依赖

- OpenClaw core
- crontab
- logger (日志工具)

---

**适用场景**: 简历展示 - 自动化任务调度、系统运维能力
