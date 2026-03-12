# API Documentation Generator

自动生成 API 文档，支持 OpenAPI/Swagger 规范。

## 功能

- 从代码注释生成 API 文档
- 支持 RESTful API 规范
- 生成 Markdown/HTML 格式文档
- 支持多种语言: Node.js, Python, Go

## 使用方法

```bash
# 查看帮助
apidoc help

# 生成文档
apidoc generate <project-dir>

# 支持格式
apidoc generate ./my-api --format markdown
apidoc generate ./my-api --format html
```

## 示例项目

```bash
# 初始化示例项目
apidoc init example

# 生成文档
cd example
apidoc generate .
```

## 输出示例

```
📚 API Documentation Generator
├── routes/
│   ├── users.js
│   └── posts.js
├── models/
│   └── schema.js
└── output/
    └── api-docs.md
```
