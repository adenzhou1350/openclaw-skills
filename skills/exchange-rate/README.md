# Exchange Rate Query Skill

查询实时汇率，支持多种货币之间的转换。

## 功能

- 实时汇率查询
- 货币转换计算
- 支持主要货币：USD, EUR, GBP, JPY, CNY, AUD, CAD, CHF 等
- 支持快速查看人民币汇率

## 使用方法

### 基本查询

```bash
# 查询美元兑人民币汇率
exrate USD/CNY

# 查询欧元兑日元汇率
exrate EUR/JPY

# 查询英镑汇率（默认兑美元）
exrate GBP

# 人民币兑外币
exrate CNY/USD
```

### 批量查询

```bash
# 查询多种货币兑人民币
exrate convert 100 USD CNY,JPY,EUR
```

### 帮助

```bash
exrate help
```

## 依赖

- curl (API 请求)
- jq (JSON 解析，可选)

## API

使用免费汇率 API (exchangerate-api.com 或类似)

## 示例输出

```
💱 汇率查询

USD → CNY
当前汇率: 7.24
更新时间: 2026-03-04 10:00 UTC

100 USD = 724.00 CNY
```

## 适用场景

- 跨境购物计算
- 旅行预算规划
- 国际贸易参考
- 投资理财参考
