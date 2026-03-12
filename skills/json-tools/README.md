# JSON Tools Skill

JSON 处理工具集，支持格式化、验证、压缩、比较等功能。

## 功能

- `format <file>` - 格式化 JSON
- `validate <file>` - 验证 JSON 语法
- `minify <file>` - 压缩 JSON
- `prettify <file>` - 美化输出
- `compare <file1> <file2>` - 比较两个 JSON 文件
- `extract <file> <path>` - 提取 JSON 路径
- `query <file> <jq-expr>` - jq 风格查询
- `to-csv <file>` - JSON 转 CSV
- `from-csv <file>` - CSV 转 JSON

## 使用示例

```bash
# 格式化 JSON
json format data.json

# 验证 JSON
json validate data.json

# 压缩 JSON
json minify data.json

# 比较两个 JSON
json compare file1.json file2.json

# 提取路径
json extract data.json "users[0].name"

# 查询
json query data.json ".users[] | select(.age > 20)"
```

## 适合简历展示

- 数据处理能力
- 工具脚本开发
- API 响应处理
