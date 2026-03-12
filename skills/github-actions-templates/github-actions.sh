#!/bin/bash
# GitHub Actions Templates Generator
# 自动生成 CI/CD 工作流模板

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 帮助信息
show_help() {
    cat << EOF
GitHub Actions 模板生成器

用法: $(basename "$0") [命令] [选项]

命令:
    list                列出所有可用模板
    generate <name>     生成指定模板
    install <name>      安装模板到当前项目
    help                显示帮助信息

可用模板:
    node-ci           Node.js 持续集成
    python-ci         Python 持续集成
    docker-publish    Docker 镜像发布
    scheduled-task    定时任务
    daily-report      每日报告
    code-quality      代码质量检查
    api-monitor       API 监控
    backup-automation 备份自动化

示例:
    $(basename "$0") list
    $(basename "$0") generate node-ci
    $(basename "$0") install docker-publish

EOF
}

# 列出所有模板
list_templates() {
    echo -e "${BLUE}=== 可用 GitHub Actions 模板 ===${NC}\n"
    
    if [ ! -d "$TEMPLATES_DIR" ]; then
        echo -e "${RED}模板目录不存在${NC}"
        return 1
    fi
    
    for template in "$TEMPLATES_DIR"/*.yml; do
        if [ -f "$template" ]; then
            name=$(basename "$template" .yml)
            echo -e "  ${GREEN}✓${NC} $name"
        fi
    done
    
    echo ""
    echo "使用 $(basename "$0") generate <name> 生成模板"
}

# 生成模板
generate_template() {
    local name="$1"
    local template_file="$TEMPLATES_DIR/${name}.yml"
    
    if [ -z "$name" ]; then
        echo -e "${RED}错误: 请指定模板名称${NC}"
        echo "使用 $(basename "$0") list 查看可用模板"
        exit 1
    fi
    
    if [ ! -f "$template_file" ]; then
        echo -e "${RED}错误: 模板 '$name' 不存在${NC}"
        echo "使用 $(basename "$0") list 查看可用模板"
        exit 1
    fi
    
    # 创建 .github/workflows 目录
    mkdir -p .github/workflows
    
    # 复制模板
    cp "$template_file" ".github/workflows/${name}.yml"
    
    echo -e "${GREEN}✓${NC} 已生成模板: .github/workflows/${name}.yml"
    echo ""
    echo "下一步:"
    echo "  1. 编辑模板配置"
    echo "  2. 添加必要的 secrets"
    echo "  3. 提交到 GitHub"
}

# 主命令处理
case "${1:-help}" in
    list)
        list_templates
        ;;
    generate)
        generate_template "$2"
        ;;
    install)
        generate_template "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}未知命令: $1${NC}"
        show_help
        exit 1
        ;;
esac
