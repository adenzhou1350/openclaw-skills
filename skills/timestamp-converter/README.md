# Timestamp Converter Skill

时间戳转换工具，支持 Unix 时间戳与日期时间的相互转换。

## 功能

- `now` - 获取当前时间戳
- `convert <timestamp>` - 时间戳转日期时间
- `to-ts <date>` - 日期时间转时间戳
- `format <timestamp> <format>` - 格式化输出
- `add <timestamp> <days|hours|minutes>` - 时间加减计算
- `diff <ts1> <ts2>` - 计算时间差

## 使用示例

```bash
# 获取当前时间戳
ts now

# 时间戳转日期
ts convert 1704067200
ts convert 1704067200 --utc

# 日期转时间戳
ts to-ts "2024-01-01 00:00:00"
ts to-ts "2024-01-01"

# 格式化输出
ts format 1704067200 "%Y年%m月%d日 %H:%M:%S"

# 时间加减
ts add 1704067200 7days
ts add 1704067200 2hours

# 计算时间差
ts diff 1704067200 1704153600
```

## 适合简历展示

- 时间处理能力
- CLI 工具开发
- 日期时间格式解析
