#!/bin/bash
# Exchange Rate Query Tool
# 查询实时汇率，支持多种货币转换

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API 配置
API_URL="https://api.exchangerate-api.com/v4/latest"

# 常用货币列表
SUPPORTED_CURRENCIES="USD EUR GBP JPY CNY AUD CAD CHF HKD SGD KRW INR MXN BRL"

# 显示帮助
show_help() {
    cat << EOF
💱 汇率查询工具

用法: exrate [命令] [参数]

命令:
    <货币对>      查询指定货币汇率，如: USD/CNY, EUR/JPY
    <货币>       查询该货币兑美元的汇率，如: GBP, JPY
    convert      货币转换，如: convert 100 USD CNY
    
    help         显示帮助信息
    list         显示支持的货币列表

示例:
    exrate USD/CNY      查询美元兑人民币汇率
    exrate EUR/JPY      查询欧元兑日元汇率  
    exrate GBP          查询英镑兑美元汇率
    exrate convert 100 USD CNY  将100美元转换为人民币

EOF
}

# 显示支持的货币列表
show_list() {
    echo "支持的货币:"
    echo "$SUPPORTED_CURRENCIES" | tr ' ' '\n' | column
}

# 获取汇率
fetch_rate() {
    local from=$1
    local to=$2
    
    # 获取基础货币汇率数据
    response=$(curl -s --max-time 10 "${API_URL}/${from}" 2>/dev/null) || {
        echo -e "${RED}获取汇率失败，请检查网络连接${NC}"
        exit 1
    }
    
    # 提取目标货币汇率
    rate=$(echo "$response" | jq -r ".rates.${to}" 2>/dev/null) || {
        echo -e "${RED}解析汇率数据失败${NC}"
        exit 1
    }
    
    if [ "$rate" = "null" ] || [ -z "$rate" ]; then
        echo -e "${RED}不支持的货币: $to${NC}"
        exit 1
    fi
    
    echo "$rate"
}

# 格式化数字
format_number() {
    printf "%.4f" "$1"
}

# 主查询功能
query_rate() {
    local input=$1
    
    # 解析输入
    if [[ "$input" == *"/"* ]]; then
        from=$(echo "$input" | cut -d'/' -f1 | tr '[:lower:]' '[:upper:]')
        to=$(echo "$input" | cut -d'/' -f2 | tr '[:lower:]' '[:upper:]')
    else
        from=$(echo "$input" | tr '[:lower:]' '[:upper:]')
        to="USD"
    fi
    
    # 验证货币代码
    if [[ ! "$SUPPORTED_CURRENCIES" =~ $from ]]; then
        echo -e "${RED}不支持的货币: $from${NC}"
        echo "支持的货币: $SUPPORTED_CURRENCIES"
        exit 1
    fi
    
    if [[ ! "$SUPPORTED_CURRENCIES" =~ $to ]]; then
        echo -e "${RED}不支持的货币: $to${NC}"
        echo "支持的货币: $SUPPORTED_CURRENCIES"
        exit 1
    fi
    
    # 获取汇率
    rate=$(fetch_rate "$from" "$to")
    
    # 显示结果
    echo ""
    echo -e "${BLUE}💱 汇率查询${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}${from}${NC} → ${GREEN}${to}${NC}"
    echo "当前汇率: ${YELLOW}$(format_number $rate)${NC}"
    echo ""
    
    # 常见金额转换
    echo "快速换算:"
    for amount in 1 10 100 1000; do
        converted=$(echo "$rate * $amount" | bc 2>/dev/null || echo "$rate * $amount")
        printf "  %5d %s = %.2f %s\n" "$amount" "$from" "$converted" "$to"
    done
}

# 货币转换功能
convert_currency() {
    local amount=$1
    local from=$2
    shift 2
    local targets=("$@")
    
    from=$(echo "$from" | tr '[:lower:]' '[:upper:]')
    
    echo ""
    echo -e "${BLUE}💱 货币转换${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "金额: ${GREEN}${amount} ${from}${NC}"
    echo ""
    
    for to in "${targets[@]}"; do
        to=$(echo "$to" | tr '[:lower:]' '[:upper:]' | tr -d ',')
        if [[ -z "$to" ]]; then
            continue
        fi
        
        if [[ ! "$SUPPORTED_CURRENCIES" =~ $to ]]; then
            echo -e "${RED}不支持的货币: $to${NC}"
            continue
        fi
        
        rate=$(fetch_rate "$from" "$to")
        result=$(echo "$rate * $amount" | bc -l 2>/dev/null || echo "$rate * $amount")
        printf "  %s → %s: %.2f (汇率: %.4f)\n" "$from" "$to" "$result" "$rate"
    done
}

# 主程序
main() {
    # 检查依赖
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}需要安装 curl${NC}"
        exit 1
    fi
    
    # 无参数时显示帮助
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    case "$1" in
        help|--help|-h)
            show_help
            ;;
        list|--list|-l)
            show_list
            ;;
        convert|--convert)
            if [ $# -lt 4 ]; then
                echo -e "${RED}用法: exrate convert <金额> <货币> <目标货币1> [目标货币2] ...${NC}"
                exit 1
            fi
            amount=$2
            from=$3
            targets=("${@:4}")
            convert_currency "$amount" "$from" "${targets[@]}"
            ;;
        *)
            query_rate "$1"
            ;;
    esac
}

main "$@"
