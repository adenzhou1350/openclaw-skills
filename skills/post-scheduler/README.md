# Post Scheduler Skill

社交媒体定时发布工具，支持多平台内容定时推送。

## 功能特性

- 支持多平台：Twitter、LinkedIn、小红书、微博等
- 内容模板：支持变量替换（日期、时间、内容等）
- 定时任务：支持 Cron 表达式设置发布时间
- 队列管理：支持内容队列批量发布
- 发布统计：记录发布历史和效果数据

## 使用方法

```bash
# 列出所有待发布内容
post-scheduler list

# 添加新内容
post-scheduler add --platform twitter --content "Hello World" --schedule "0 9 * * *"

# 删除内容
post-scheduler delete <id>

# 查看发布历史
post-scheduler history

# 手动触发发布
post-scheduler publish <id>
```

## 配置

在 `~/.openclaw/config/post-scheduler.json` 中配置：

```json
{
  "platforms": {
    "twitter": {
      "enabled": true,
      "api_key": "your-api-key"
    },
    "xiaohongshu": {
      "enabled": true,
      "cookie": "your-cookie"
    }
  },
  "default_schedule": "0 9 * * *"
}
```

## 适合场景

- 定时发送天气早报
- 定时发送新闻简报
- 定时发送营销内容
- 定时发送个人动态
