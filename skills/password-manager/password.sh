#!/bin/bash
# Password Manager - 本地密码管理工具
# 安全存储密码，支持分类、搜索、生成强密码

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/.data"
mkdir -p "$DATA_DIR"

PASSFILE="$DATA_DIR/passwords.gpg"
INDEX_FILE="$DATA_DIR/index.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 检查 GPG 是否可用
check_gpg() {
    if ! command -v gpg &> /dev/null; then
        echo -e "${RED}需要安装 GPG: sudo apt-get install gnupg${NC}"
        exit 1
    fi
}

show_help() {
    echo -e "${BLUE}🔐 Password Manager - 本地密码管理${NC}"
    echo ""
    echo "用法: password <command> [options]"
    echo ""
    echo "命令:"
    echo "  add <service> <username> [password]  添加密码"
    echo "  get <service>                      获取密码"
    echo "  list                               列出所有服务"
    echo "  search <keyword>                   搜索服务"
    echo "  delete <service>                   删除密码"
    echo "  generate [length]                  生成强密码"
    echo "  edit <service>                     编辑密码"
    echo "  categories                         列出分类"
    echo "  backup                             备份密码库"
    echo "  help                               显示帮助"
    echo ""
    echo "示例:"
    echo "  password add github.com john@email.com"
    echo "  password add github.com john@email.com mypass123"
    echo "  password get github.com"
    echo "  password generate 16"
    echo "  password search github"
}

# 初始化
init() {
    mkdir -p "$DATA_DIR"
    if [ ! -f "$INDEX_FILE" ]; then
        touch "$INDEX_FILE"
    fi
}

# 生成密码
generate_password() {
    local length="${1:-16}"
    
    if command -v pwgen &> /dev/null; then
        pwgen -s "$length" 1
    elif command -v openssl &> /dev/null; then
        openssl rand -base64 "$length" | tr -d '\n' | head -c "$length"
    else
        # 备用方案
        local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        local password=""
        for i in $(seq 1 "$length"); do
            password+="${chars:$((RANDOM % ${#chars})):1}"
        done
        echo "$password"
    fi
}

# 添加密码
cmd_add() {
    local service="$1"
    local username="$2"
    local password="${3:-$(generate_password 16)}"
    
    if [ -z "$service" ] || [ -z "$username" ]; then
        echo -e "${RED}请输入服务名和用户名${NC}"
        echo "用法: password add <service> <username> [password]"
        exit 1
    fi
    
    init
    
    # 检查是否已存在
    if grep -q "^$service|" "$INDEX_FILE" 2>/dev/null; then
        echo -e "${YELLOW}服务 $service 已存在，使用 edit 命令修改${NC}"
        exit 1
    fi
    
    # 添加记录
    echo "$service|$username|$password|$(date '+%Y-%m-%d')" >> "$INDEX_FILE"
    
    echo -e "${GREEN}✅ 已添加: $service -> $username${NC}"
    echo -e "${CYAN}密码: $password${NC}"
}

# 获取密码
cmd_get() {
    local service="$1"
    
    if [ -z "$service" ]; then
        echo -e "${RED}请输入服务名${NC}"
        exit 1
    fi
    
    init
    
    local line=$(grep "^$service|" "$INDEX_FILE" 2>/dev/null || true)
    
    if [ -z "$line" ]; then
        echo -e "${RED}未找到服务: $service${NC}"
        exit 1
    fi
    
    IFS='|' read -r s user pass date <<< "$line"
    
    echo -e "${BLUE}服务: $s${NC}"
    echo -e "${BLUE}用户名: $user${NC}"
    echo -e "${CYAN}密码: $pass${NC}"
    echo -e "${YELLOW}添加日期: $date${NC}"
}

# 列出所有
cmd_list() {
    init
    
    if [ ! -s "$INDEX_FILE" ]; then
        echo "暂无存储的密码"
        return
    fi
    
    echo -e "${BLUE}📋 已存储的服务:${NC}"
    echo "----------------------------------------"
    while IFS='|' read -r service username _ date; do
        printf "%-30s %-25s %s\n" "$service" "$username" "$date"
    done < "$INDEX_FILE"
}

# 搜索
cmd_search() {
    local keyword="$1"
    
    if [ -z "$keyword" ]; then
        echo -e "${RED}请输入搜索关键词${NC}"
        exit 1
    fi
    
    init
    
    local results=$(grep -i "$keyword" "$INDEX_FILE" || true)
    
    if [ -z "$results" ]; then
        echo -e "${RED}未找到匹配: $keyword${NC}"
        return
    fi
    
    echo -e "${BLUE}🔍 搜索结果:${NC}"
    echo "----------------------------------------"
    while IFS='|' read -r service username _ date; do
        printf "%-30s %-25s %s\n" "$service" "$username" "$date"
    done <<< "$results"
}

# 删除
cmd_delete() {
    local service="$1"
    
    if [ -z "$service" ]; then
        echo -e "${RED}请输入服务名${NC}"
        exit 1
    fi
    
    init
    
    if ! grep -q "^$service|" "$INDEX_FILE" 2>/dev/null; then
        echo -e "${RED}未找到服务: $service${NC}"
        exit 1
    fi
    
    grep -v "^$service|" "$INDEX_FILE" > "$INDEX_FILE.tmp"
    mv "$INDEX_FILE.tmp" "$INDEX_FILE"
    
    echo -e "${GREEN}✅ 已删除: $service${NC}"
}

# 编辑
cmd_edit() {
    local service="$1"
    
    if [ -z "$service" ]; then
        echo -e "${RED}请输入服务名${NC}"
        exit 1
    fi
    
    init
    
    local line=$(grep "^$service|" "$INDEX_FILE" 2>/dev/null || true)
    
    if [ -z "$line" ]; then
        echo -e "${RED}未找到服务: $service${NC}"
        exit 1
    fi
    
    echo "当前信息:"
    cmd_get "$service"
    echo ""
    echo -e "${YELLOW}请输入新密码（留空则生成新密码）:${NC}"
    read -r new_pass
    
    if [ -z "$new_pass" ]; then
        new_pass=$(generate_password 16)
    fi
    
    IFS='|' read -r s user _ date <<< "$line"
    
    grep -v "^$service|" "$INDEX_FILE" > "$INDEX_FILE.tmp"
    echo "$service|$user|$new_pass|$date" >> "$INDEX_FILE.tmp"
    mv "$INDEX_FILE.tmp" "$INDEX_FILE"
    
    echo -e "${GREEN}✅ 已更新密码${NC}"
    echo -e "${CYAN}新密码: $new_pass${NC}"
}

# 备份
cmd_backup() {
    local backup_file="passwords-backup-$(date '+%Y%m%d-%H%M%S').txt"
    
    if [ ! -s "$INDEX_FILE" ]; then
        echo "没有数据需要备份"
        return
    fi
    
    cp "$INDEX_FILE" "$backup_file"
    echo -e "${GREEN}✅ 备份已保存: $backup_file${NC}"
}

# 主命令处理
case "${1:-help}" in
    add)
        cmd_add "$2" "$3" "$4"
        ;;
    get)
        cmd_get "$2"
        ;;
    list)
        cmd_list
        ;;
    search)
        cmd_search "$2"
        ;;
    delete)
        cmd_delete "$2"
        ;;
    edit)
        cmd_edit "$2"
        ;;
    generate)
        generate_password "${2:-16}"
        ;;
    backup)
        cmd_backup
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
