# 🐳 Docker Manager Skill

Docker 容器管理工具，支持容器生命周期管理、镜像操作、日志查看等。

## 功能

- 容器列表与状态监控
- 容器启动/停止/重启/删除
- 镜像列表与清理
- 容器日志查看（实时/历史）
- 资源使用监控（CPU/内存）
- 容器 exec 进入
- 镜像拉取与构建
- 网络管理
- 数据卷管理

## 使用方法

```bash
# 列出所有容器
docker-manager list

# 启动容器
docker-manager start <container_id>

# 停止容器
docker-manager stop <container_id>

# 查看容器日志
docker-manager logs <container_id>

# 实时日志
docker-manager logs <container_id> --follow

# 资源监控
docker-manager stats

# 进入容器
docker-manager exec <container_id> /bin/bash

# 镜像列表
docker-manager images

# 清理未使用镜像
docker-manager prune images

# 容器资源使用
docker-manager top <container_id>

# 查看容器详情
docker-manager inspect <container_id>
```

## 快速命令

```bash
# 一键清理未使用资源
docker-manager clean

# 查看所有容器（含停止的）
docker-manager ps -a

# 查看运行中容器
docker-manager ps

# 拉取镜像
docker-manager pull nginx:latest

# 构建镜像
docker-manager build -t myapp:latest .
```

## 依赖

- Docker CLI
- jq (可选，用于 JSON 格式化)

## 简历展示

- 容器化技术经验
- DevOps 能力
- 自动化运维经验
- 云原生技术基础
