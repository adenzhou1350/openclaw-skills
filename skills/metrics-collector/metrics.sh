#!/bin/bash

# Metrics Collector - 应用性能指标收集工具
# 支持系统指标采集、查询、聚合、报告生成

set -e

# 配置
DATA_DIR="${HOME}/.metrics/data"
CONFIG_DIR="${HOME}/.metrics/config"
mkdir -p "$DATA_DIR" "$CONFIG_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 工具函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取时间戳
get_timestamp() { date +"%Y-%m-%dT%H:%M:%SZ"; }
get_date() { date +"%Y-%m-%d"; }
get_hour() { date +"%Y-%m-%dT%H:00:00Z"; }

# 获取 CPU 使用率
get_cpu_usage() {
    local idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | sed 's/%id,//')
    if [[ -n "$idle" ]]; then
        echo "100 - $idle" | bc -l 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# 获取内存使用情况
get_memory_usage() {
    local total=$(free -m | awk '/^Mem:/{print $2}')
    local used=$(free -m | awk '/^Mem:/{print $3}')
    local percent=$(echo "scale=2; $used * 100 / $total" | bc 2>/dev/null || echo "0")
    echo "$used $total $percent"
}

# 获取磁盘使用情况
get_disk_usage() {
    df -h / | awk 'NR==2 {print $2" "$3" "$4" "$5}'
}

# 获取网络流量
get_network_io() {
    cat /proc/net/dev | awk 'NR==3 {print $2" "$10}'
}

# 采集系统指标
collect_system() {
    local timestamp=$(get_timestamp)
    local cpu=$(get_cpu_usage)
    local mem_data=$(get_memory_usage)
    local disk_data=$(get_disk_usage)
    local net_data=$(get_network_io)
    
    local mem_used=$(echo $mem_data | awk '{print $1}')
    local mem_total=$(echo $mem_data | awk '{print $2}')
    local mem_percent=$(echo $mem_data | awk '{print $3}')
    local disk_total=$(echo $disk_data | awk '{print $1}')
    local disk_used=$(echo $disk_data | awk '{print $2}')
    local disk_avail=$(echo $disk_data | awk '{print $3}')
    local disk_percent=$(echo $disk_data | awk '{print $4}' | sed 's/%//')
    local rx_bytes=$(echo $net_data | awk '{print $1}')
    local tx_bytes=$(echo $net_data | awk '{print $2}')
    
    # 保存指标数据
    local metric_file="$DATA_DIR/system-$(get_date).jsonl"
    
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"cpu.usage\",\"value\":$cpu}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"memory.used\",\"value\":$mem_used}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"memory.total\",\"value\":$mem_total}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"memory.percent\",\"value\":$mem_percent}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"disk.total\",\"value\":\"$disk_total\"}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"disk.used\",\"value\":\"$disk_used\"}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"disk.avail\",\"value\":\"$disk_avail\"}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"disk.percent\",\"value\":$disk_percent}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"network.rx\",\"value\":$rx_bytes}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"network.tx\",\"value\":$tx_bytes}" >> "$metric_file"
    
    log_success "系统指标采集完成"
    echo ""
    echo "📊 当前系统状态:"
    echo "  CPU 使用率: $(printf "%.1f" $cpu)%"
    echo "  内存使用: ${mem_used}MB / ${mem_total}MB ($(printf "%.1f" $mem_percent)%)"
    echo "  磁盘使用: ${disk_used} / ${disk_total} (${disk_percent}%)"
    echo "  网络接收: $(numfmt --to=iec $rx_bytes 2>/dev/null || echo "$rx_bytes")"
    echo "  网络发送: $(numfmt --to=iec $tx_bytes 2>/dev/null || echo "$tx_bytes")"
}

# 采集应用指标
collect_app() {
    local timestamp=$(get_timestamp)
    local response_time=${1:-120}
    local error_rate=${2:-0.5}
    local qps=${3:-100}
    
    local metric_file="$DATA_DIR/app-$(get_date).jsonl"
    
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"app.response.time\",\"value\":$response_time}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"app.error.rate\",\"value\":$error_rate}" >> "$metric_file"
    echo "{\"timestamp\":\"$timestamp\",\"metric\":\"app.qps\",\"value\":$qps}" >> "$metric_file"
    
    log_success "应用指标采集完成"
    echo ""
    echo "📊 当前应用状态:"
    echo "  响应时间: ${response_time}ms"
    echo "  错误率: ${error_rate}%"
    echo "  QPS: $qps"
}

# 查询指标
query_metrics() {
    local metric=${1:-"cpu.usage"}
    local from=${2:-"-1h"}
    local to=${3:-"now"}
    
    local date_file="$DATA_DIR/system-$(get_date).jsonl"
    
    if [[ ! -f "$date_file" ]]; then
        log_warn "没有找到指标数据，请先运行 collect"
        return 1
    fi
    
    echo ""
    echo "📈 查询结果: $metric"
    echo "-------------------------------------------"
    
    # 提取指定指标
    local results=$(grep "\"metric\":\"$metric\"" "$date_file" 2>/dev/null | tail -10)
    
    if [[ -z "$results" ]]; then
        log_warn "没有找到指标: $metric"
        return 1
    fi
    
    # 显示最近的数据点
    echo "$results" | while read line; do
        local ts=$(echo "$line" | jq -r '.timestamp' 2>/dev/null)
        local val=$(echo "$line" | jq -r '.value' 2>/dev/null)
        if [[ -n "$ts" && -n "$val" ]]; then
            echo "  $ts  →  $val"
        fi
    done
    
    # 计算统计
    local count=$(echo "$results" | wc -l)
    local sum=$(echo "$results" | jq -r '.value' 2>/dev/null | paste -sd+ | bc 2>/dev/null || echo "0")
    local avg=$(echo "scale=2; $sum / $count" | bc 2>/dev/null || echo "0")
    
    echo "-------------------------------------------"
    echo "  数据点数: $count"
    echo "  平均值: $avg"
}

# 聚合指标
aggregate_metrics() {
    local metric=${1:-"cpu.usage"}
    local func=${2:-"avg"}
    
    local date_file="$DATA_DIR/system-$(get_date).jsonl"
    
    if [[ ! -f "$date_file" ]]; then
        log_error "没有找到指标数据"
        return 1
    fi
    
    local values=$(grep "\"metric\":\"$metric\"" "$date_file" 2>/dev/null | jq -r '.value')
    
    if [[ -z "$values" ]]; then
        log_error "没有找到指标: $metric"
        return 1
    fi
    
    case $func in
        avg|mean)
            echo "$values" | paste -sd+ | bc -l | xargs -I {} echo "scale=2; {} / $(echo "$values" | wc -l)" | bc
            ;;
        sum)
            echo "$values" | paste -sd+ | bc
            ;;
        min)
            echo "$values" | sort -n | head -1
            ;;
        max)
            echo "$values" | sort -n | tail -1
            ;;
        *)
            log_error "未知聚合函数: $func"
            return 1
            ;;
    esac
}

# 生成报告
generate_report() {
    local format=${1:-"markdown"}
    local output=${2:-"metrics-report.md"}
    local theme=${3:-"light"}
    
    local date_file="$DATA_DIR/system-$(get_date).jsonl"
    
    if [[ ! -f "$date_file" ]]; then
        log_error "没有找到指标数据，请先运行 collect"
        return 1
    fi
    
    if [[ "$format" == "markdown" ]]; then
        {
            echo "# 📊 系统指标报告"
            echo ""
            echo "生成时间: $(get_timestamp)"
            echo ""
            echo "## CPU 使用率"
            
            local cpu_values=$(grep '"metric":"cpu.usage"' "$date_file" | jq -r '.value' 2>/dev/null)
            if [[ -n "$cpu_values" ]]; then
                local cpu_avg=$(echo "$cpu_values" | paste -sd+ | bc -l | xargs -I {} echo "scale=1; {} / $(echo "$cpu_values" | wc -l)" | bc)
                local cpu_max=$(echo "$cpu_values" | sort -n | tail -1)
                echo "- 平均: $(printf "%.1f" $cpu_avg)%"
                echo "- 峰值: $(printf "%.1f" $cpu_max)%"
            fi
            
            echo ""
            echo "## 内存使用"
            
            local mem_values=$(grep '"metric":"memory.percent"' "$date_file" | jq -r '.value' 2>/dev/null)
            if [[ -n "$mem_values" ]]; then
                local mem_avg=$(echo "$mem_values" | paste -sd+ | bc -l | xargs -I {} echo "scale=1; {} / $(echo "$mem_values" | wc -l)" | bc)
                echo "- 平均使用率: $(printf "%.1f" $mem_avg)%"
            fi
            
            echo ""
            echo "## 磁盘使用"
            
            local disk_percent=$(grep '"metric":"disk.percent"' "$date_file" | tail -1 | jq -r '.value' 2>/dev/null)
            if [[ -n "$disk_percent" ]]; then
                echo "- 当前使用率: ${disk_percent}%"
            fi
            
            echo ""
            echo "---"
            echo "*由 Metrics Collector 自动生成*"
        } > "$output"
        
        log_success "报告已生成: $output"
    else
        log_error "不支持的格式: $format"
    fi
}

# 显示状态
show_status() {
    echo ""
    echo "📊 Metrics Collector 状态"
    echo "================================"
    echo "数据目录: $DATA_DIR"
    echo "配置目录: $CONFIG_DIR"
    echo ""
    
    local today=$(get_date)
    local metric_file="$DATA_DIR/system-$today.jsonl"
    
    if [[ -f "$metric_file" ]]; then
        local data_points=$(wc -l < "$metric_file")
        local metrics_count=$(grep -o '"metric":"[^"]*"' "$metric_file" | sort -u | wc -l)
        
        echo "今日数据:"
        echo "  数据点数: $data_points"
        echo "  指标类型: $metrics_count"
        echo ""
        echo "支持的指标:"
        grep -o '"metric":"[^"]*"' "$metric_file" | sort -u | sed 's/"metric":"/  - /g' | sed 's/"//g'
    else
        echo "今日暂无数据，运行 'metrics collect' 开始采集"
    fi
}

# 显示帮助
show_help() {
    echo "Metrics Collector - 应用性能指标收集工具"
    echo ""
    echo "用法:"
    echo "  metrics <command> [options]"
    echo ""
    echo "命令:"
    echo "  collect [system|app]     采集指标数据"
    echo "  query <metric> [from]    查询指标数据"
    echo "  aggregate <metric> [func] 聚合指标 (avg/sum/min/max)"
    echo "  report [format] [output] 生成监控报告"
    echo "  status                   显示收集器状态"
    echo "  help                     显示帮助"
    echo ""
    echo "示例:"
    echo "  metrics collect system              采集系统指标"
    echo "  metrics query cpu.usage             查询 CPU 使用率"
    echo "  metrics aggregate cpu.usage avg     计算平均 CPU 使用率"
    echo "  metrics report markdown report.md   生成 Markdown 报告"
    echo ""
}

# 主命令处理
case "${1:-help}" in
    collect)
        case "${2:-system}" in
            system) collect_system ;;
            app) collect_app "${3:-120}" "${4:-0.5}" "${5:-100}" ;;
            *) log_error "未知来源: $2"; exit 1 ;;
        esac
        ;;
    query)
        query_metrics "${2:-cpu.usage}" "${3:--1h}" "${4:-now}"
        ;;
    aggregate)
        aggregate_metrics "${2:-cpu.usage}" "${3:-avg}"
        ;;
    report)
        generate_report "${2:-markdown}" "${3:-metrics-report.md}" "${4:-light}"
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        log_error "未知命令: $1"
        show_help
        exit 1
        ;;
esac
