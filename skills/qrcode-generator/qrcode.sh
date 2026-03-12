#!/bin/bash
# QR Code Generator - 二维码生成工具
# 支持: 文本、URL、电话、WiFi、名片等

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/.data"
mkdir -p "$DATA_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}QR Code Generator - 二维码生成工具${NC}"
    echo ""
    echo "用法: qrcode <command> [options]"
    echo ""
    echo "命令:"
    echo "  generate <text>        生成二维码 (文本/URL)"
    echo "  url <url>              生成 URL 二维码"
    echo "  wifi <ssid> [password] 生成 WiFi 二维码"
    echo "  phone <number>         生成电话二维码"
    echo "  email <address>        生成邮箱二维码"
    echo "  vcard <name> <phone> [email] [org]  生成名片二维码"
    echo "  list                   列出历史记录"
    echo "  clean                  清理历史记录"
    echo "  help                   显示帮助"
    echo ""
    echo "示例:"
    echo "  qrcode generate 'Hello World'"
    echo "  qrcode url 'https://github.com'"
    echo "  qrcode wifi MyWiFi password123"
    echo "  qrcode phone '+86-138-0000-1234'"
    echo "  qrcode vcard '张三' '13800001234' 'zhangsan@example.com' '某公司'"
}

# 检查依赖
check_deps() {
    if ! command -v qrencode &> /dev/null; then
        echo -e "${YELLOW}正在安装 qrencode...${NC}"
        if command -v apt-get &> /dev/null; then
            sudo apt-get install -y qrencode
        elif command -v yum &> /dev/null; then
            sudo yum install -y qrencode
        elif command -v brew &> /dev/null; then
            brew install qrencode
        else
            echo -e "${RED}无法安装 qrencode，请手动安装后再试${NC}"
            exit 1
        fi
    fi
}

# 生成二维码
generate_qr() {
    local text="$1"
    local output="${2:-qrcode.png}"
    
    check_deps
    
    echo -e "${GREEN}生成二维码: ${text}${NC}"
    echo "$text" | qrencode -o "$output" -s 10
    
    # 保存到历史记录
    echo "$(date '+%Y-%m-%d %H:%M:%S')|$text|$output" >> "$DATA_DIR/history.txt"
    
    echo -e "${GREEN}✅ 二维码已保存: $output${NC}"
    
    # 显示二维码
    if command -v img2txt &> /dev/null || command -v catimg &> /dev/null; then
        echo -e "${YELLOW}二维码内容:${NC}"
        echo "$text" | qrencode -t UTF8 || true
    fi
}

# 生成 URL 二维码
cmd_url() {
    local url="$1"
    if [ -z "$url" ]; then
        echo -e "${RED}请输入 URL${NC}"
        echo "用法: qrcode url <url>"
        exit 1
    fi
    
    local filename="$(echo "$url" | sed 's|https://||;s|http://||;s|/|_|g' | cut -c1-50).png"
    generate_qr "$url" "$DATA_DIR/$filename"
}

# 生成 WiFi 二维码
cmd_wifi() {
    local ssid="$1"
    local password="$2"
    
    if [ -z "$ssid" ]; then
        echo -e "${RED}请输入 WiFi 名称${NC}"
        echo "用法: qrcode wifi <ssid> [password]"
        exit 1
    fi
    
    local wifi_string="WIFI:T:WPA;S:$ssid;"
    if [ -n "$password" ]; then
        wifi_string+="P:$password;;"
    else
        wifi_string+=";;"
    fi
    
    generate_qr "$wifi_string" "$DATA_DIR/wifi-$ssid.png"
}

# 生成电话二维码
cmd_phone() {
    local number="$1"
    
    if [ -z "$number" ]; then
        echo -e "${RED}请输入电话号码${NC}"
        echo "用法: qrcode phone <number>"
        exit 1
    fi
    
    generate_qr "tel:$number" "$DATA_DIR/phone-$number.png"
}

# 生成邮箱二维码
cmd_email() {
    local address="$1"
    
    if [ -z "$address" ]; then
        echo -e "${RED}请输入邮箱地址${NC}"
        echo "用法: qrcode email <address>"
        exit 1
    fi
    
    generate_qr "mailto:$address" "$DATA_DIR/email-$address.png"
}

# 生成名片二维码
cmd_vcard() {
    local name="$1"
    local phone="$2"
    local email="$3"
    local org="$4"
    
    if [ -z "$name" ] || [ -z "$phone" ]; then
        echo -e "${RED}请输入姓名和电话${NC}"
        echo "用法: qrcode vcard <name> <phone> [email] [org]"
        exit 1
    fi
    
    local vcard="BEGIN:VCARD
VERSION:3.0
FN:$name
TEL:$phone"
    
    [ -n "$email" ] && vcard+="
EMAIL:$email"
    [ -n "$org" ] && vcard+="
ORG:$org"
    
    vcard+="
END:VCARD"
    
    generate_qr "$vcard" "$DATA_DIR/vcard-$name.png"
}

# 列出历史
cmd_list() {
    if [ ! -f "$DATA_DIR/history.txt" ]; then
        echo "暂无历史记录"
        return
    fi
    
    echo -e "${BLUE}二维码生成历史:${NC}"
    echo "----------------------------------------"
    tail -20 "$DATA_DIR/history.txt" | while IFS='|' read -r date text file; do
        echo -e "${GREEN}$date${NC} - $text"
    done
}

# 清理历史
cmd_clean() {
    if [ -d "$DATA_DIR" ]; then
        rm -rf "$DATA_DIR"/*
        echo -e "${GREEN}已清理所有历史记录${NC}"
    fi
}

# 主命令处理
case "${1:-help}" in
    generate)
        generate_qr "$2" "${3:-qrcode.png}"
        ;;
    url)
        cmd_url "$2"
        ;;
    wifi)
        cmd_wifi "$2" "$3"
        ;;
    phone)
        cmd_phone "$2"
        ;;
    email)
        cmd_email "$2"
        ;;
    vcard)
        cmd_vcard "$2" "$3" "$4" "$5"
        ;;
    list)
        cmd_list
        ;;
    clean)
        cmd_clean
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
