#!/bin/bash
# URL Shortener - 短链接生成工具
# 支持多种短链接服务

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/.data"
mkdir -p "$DATA_DIR"

HISTORY_FILE="$DATA_DIR/history.txt"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}🔗 URL Shortener - 短链接生成工具${NC}"
    echo ""
    echo "用法: urlshort <command> [options]"
    echo ""
    echo "命令:"
    echo "  short <url>              生成短链接"
    echo "  expand <short-url>      展开短链接"
    echo "  qr <url>                生成短链接二维码"
    echo "  history                 查看历史记录"
    echo "  clean                   清理历史"
    echo "  services                列出支持的服务"
    echo "  help                    显示帮助"
    echo ""
    echo "示例:"
    echo "  urlshort short 'https://very-long-url.com/...'"
    echo "  urlshort expand 'https://tinyurl.com/abc123'"
    echo "  urlshort qr 'https://github.com'"
}

# 检查 curl
check_curl() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}需要 curl${NC}"
        exit 1
    fi
}

# 使用 tinyurl
short_tinyurl() {
    local url="$1"
    local result=$(curl -s "https://tinyurl.com/api-create.php?url=$(echo "$url" | jq -Rs .)")
    
    if [[ "$result" == http* ]]; then
        echo "$result"
        return 0
    else
        echo "$result"
        return 1
    fi
}

# 使用 is.gd
short_isgd() {
    local url="$1"
    local result=$(curl -s "https://is.gd/create.php?format=simple&url=$(echo "$url" | jq -Rs .)")
    
    if [[ "$result" == http* ]]; then
        echo "$result"
        return 0
    else
        echo "$result"
        return 1
    fi
}

# 展开 URL
expand_url() {
    local url="$1"
    curl -sI "$url" | grep -i "^location:" | sed 's/location: //i' | tr -d '\r'
}

# 生成短链接（自动选择可用服务）
cmd_short() {
    local url="$1"
    
    if [ -z "$url" ]; then
        echo -e "${RED}请输入 URL${NC}"
        echo "用法: urlshort short <url>"
        exit 1
    fi
    
    check_curl
    
    # 验证 URL 格式
    if [[ ! "$url" =~ ^https?:// ]]; then
        url="https://$url"
    fi
    
    echo -e "${YELLOW}正在生成短链接...${NC}"
    
    # 尝试 tinyurl
    local result=$(short_tinyurl "$url" 2>/dev/null || true)
    
    if [[ "$result" == http* ]]; then
        echo -e "${GREEN}✅ 短链接: $result${NC}"
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$url|$result" >> "$HISTORY_FILE"
        return
    fi
    
    # 尝试 is.gd
    result=$(short_isgd "$url" 2>/dev/null || true)
    
    if [[ "$result" == http* ]]; then
        echo -e "${GREEN}✅ 短链接: $result${NC}"
        echo "$(date '+%Y-%m-%d %H:%M:%S')|$url|$result" >> "$HISTORY_FILE"
        return
    fi
    
    echo -e "${RED}生成失败，请稍后重试${NC}"
}

# 展开短链接
cmd_expand() {
    local url="$1"
    
    if [ -z "$url" ]; then
        echo -e "${RED}请输入短链接${NC}"
        exit 1
    fi
    
    check_curl
    
    echo -e "${YELLOW}正在展开...${NC}"
    local result=$(expand_url "$url")
    
    if [ -n "$result" ]; then
        echo -e "${GREEN}✅ 原始链接: $result${NC}"
    else
        echo -e "${RED}无法展开或无效链接${NC}"
    fi
}

# 生成二维码
cmd_qr() {
    local url="$1"
    
    if [ -z "$url" ]; then
        echo -e "${RED}请输入 URL${NC}"
        exit 1
    fi
    
    # 先生成短链接
    cmd_short "$url"
    
    # 生成二维码
    if command -v qrencode &> /dev/null; then
        local short_url=$(short_tinyurl "$url" 2>/dev/null || echo "$url")
        echo -e "${YELLOW}生成二维码...${NC}"
        echo "$short_url" | qrencode -o "$DATA_DIR/qr-$(date +%s).png" -s 10
        echo -e "${GREEN}✅ 二维码已保存${NC}"
    else
        echo -e "${YELLOW}提示: 安装 qrencode 可生成二维码${NC}"
    fi
}

# 历史记录
cmd_history() {
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "暂无历史记录"
        return
    fi
    
    echo -e "${BLUE}📜 短链接历史:${NC}"
    echo "----------------------------------------"
    tail -20 "$HISTORY_FILE" | while IFS='|' read -r date original short; do
        echo -e "${GREEN}$date${NC}"
        echo "  原链接: $original"
        echo -e "  短链接: ${BLUE}$short${NC}"
        echo ""
    done
}

# 清理历史
cmd_clean() {
    if [ -f "$HISTORY_FILE" ]; then
        rm "$HISTORY_FILE"
    fi
    echo -e "${GREEN}已清理历史记录${NC}"
}

# 列出服务
cmd_services() {
    echo -e "${BLUE}支持的短链接服务:${NC}"
    echo "1. TinyURL (tinyurl.com) - 最稳定"
    echo "2. is.gd - 无广告"
    echo ""
    echo "自动选择可用服务"
}

# 主命令处理
case "${1:-help}" in
    short)
        cmd_short "$2"
        ;;
    expand)
        cmd_expand "$2"
        ;;
    qr)
        cmd_qr "$2"
        ;;
    history)
        cmd_history
        ;;
    clean)
        cmd_clean
        ;;
    services)
        cmd_services
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
