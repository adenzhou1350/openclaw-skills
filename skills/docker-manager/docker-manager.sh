#!/bin/bash
# Docker Manager - 容器管理工具

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查 Docker 是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is not installed${NC}"
        exit 1
    fi
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        exit 1
    fi
}

# 显示帮助
show_help() {
    cat << EOF
🐳 Docker Manager - 容器管理工具

用法: docker-manager <命令> [参数]

命令:
    list, ls          列出所有容器
    ps                列出运行中的容器
    start             启动容器
    stop              停止容器
    restart           重启容器
    rm                删除容器
    logs              查看容器日志
    stats             资源使用监控
    exec              进入容器
    images, img       镜像列表
    pull              拉取镜像
    prune             清理未使用资源
    top               容器进程信息
    inspect           容器详情
    clean             一键清理
    help              显示帮助

示例:
    docker-manager list
    docker-manager logs mycontainer
    docker-manager logs mycontainer -f
    docker-manager stats
    docker-manager exec mycontainer /bin/bash
    docker-manager clean
EOF
}

# 列出容器
list_containers() {
    check_docker
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
}

# 列出运行中容器
list_running() {
    check_docker
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Image}}"
}

# 启动容器
start_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager start <container_id/name>${NC}"
        exit 1
    fi
    docker start "$1"
    echo -e "${GREEN}Container $1 started${NC}"
}

# 停止容器
stop_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager stop <container_id/name>${NC}"
        exit 1
    fi
    docker stop "$1"
    echo -e "${GREEN}Container $1 stopped${NC}"
}

# 重启容器
restart_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager restart <container_id/name>${NC}"
        exit 1
    fi
    docker restart "$1"
    echo -e "${GREEN}Container $1 restarted${NC}"
}

# 删除容器
remove_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager rm <container_id/name>${NC}"
        exit 1
    fi
    docker rm -f "$1"
    echo -e "${GREEN}Container $1 removed${NC}"
}

# 查看日志
show_logs() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager logs <container_id/name> [options]${NC}"
        exit 1
    fi
    shift
    docker logs --tail 100 -f "$@"
}

# 资源监控
show_stats() {
    check_docker
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# 进入容器
exec_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager exec <container_id/name> <command>${NC}"
        exit 1
    fi
    CONTAINER="$1"
    shift
    docker exec -it "$CONTAINER" "${@:-/bin/bash}"
}

# 镜像列表
list_images() {
    check_docker
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
}

# 拉取镜像
pull_image() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager pull <image>${NC}"
        exit 1
    fi
    docker pull "$1"
    echo -e "${GREEN}Image $1 pulled${NC}"
}

# 清理资源
prune_resources() {
    check_docker
    echo -e "${YELLOW}清理未使用的容器...${NC}"
    docker container prune -f
    echo -e "${YELLOW}清理未使用的镜像...${NC}"
    docker image prune -a -f
    echo -e "${YELLOW}清理未使用的网络...${NC}"
    docker network prune -f
    echo -e "${YELLOW}清理未使用的数据卷...${NC}"
    docker volume prune -f
    echo -e "${GREEN}清理完成${NC}"
}

# 容器进程
show_top() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager top <container_id/name>${NC}"
        exit 1
    fi
    docker top "$1"
}

# 容器详情
inspect_container() {
    check_docker
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: docker-manager inspect <container_id/name>${NC}"
        exit 1
    fi
    docker inspect "$1" | head -50
}

# 主命令处理
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    list|ls)
        list_containers
        ;;
    ps)
        list_running
        ;;
    start)
        start_container "$@"
        ;;
    stop)
        stop_container "$@"
        ;;
    restart)
        restart_container "$@"
        ;;
    rm|remove)
        remove_container "$@"
        ;;
    logs)
        show_logs "$@"
        ;;
    stats)
        show_stats
        ;;
    exec)
        exec_container "$@"
        ;;
    images|img)
        list_images
        ;;
    pull)
        pull_image "$@"
        ;;
    prune|clean)
        prune_resources
        ;;
    top)
        show_top "$@"
        ;;
    inspect)
        inspect_container "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        show_help
        ;;
esac
