#!/bin/bash

# System Monitor - 实时系统监控工具
# 作者: OpenClaw Agent
# 功能: CPU、内存、磁盘、网络、进程监控

set -e

VERSION="1.0.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_version() {
    echo "system-monitor v$VERSION"
}

print_help() {
    echo "System Monitor - 实时系统监控工具"
    echo ""
    echo "用法: system-monitor <command> [options]"
    echo ""
    echo "命令:"
    echo "  overview          系统概览"
    echo "  cpu               CPU 信息"
    echo "  memory            内存信息"
    echo "  disk              磁盘信息"
    echo "  network           网络信息"
    echo "  process [sort]    进程信息 (cpu/memory/pid)"
    echo "  top [count]       Top 进程"
    echo "  watch [interval] 实时监控"
    echo ""
    echo "选项:"
    echo "  --help     显示帮助"
    echo "  --version  显示版本"
}

get_uptime() {
    if [[ -f /proc/uptime ]]; then
        local uptime_seconds
        uptime_seconds=$(cat /proc/uptime | awk '{print int($1)}')
        local days=$((uptime_seconds / 86400))
        local hours=$(( (uptime_seconds % 86400) / 3600 ))
        local mins=$(( (uptime_seconds % 3600) / 60 ))
        
        if [[ $days -gt 0 ]]; then
            echo "$days days, $hours hours"
        elif [[ $hours -gt 0 ]]; then
            echo "$hours hours, $mins mins"
        else
            echo "$mins mins"
        fi
    else
        # macOS fallback
        uptime | sed 's/.*up /up /' | sed 's/,.*//'
    fi
}

get_load_avg() {
    if [[ -f /proc/loadavg ]]; then
        cat /proc/loadavg | awk '{print $1, $2, $3}'
    else
        # macOS fallback
        sysctl -n vm.loadavg 2>/dev/null | tr -d '{}'
    fi
}

get_cpu_usage() {
    if [[ -f /proc/stat ]]; then
        local cpu_line
        cpu_line=$(head -n 1 /proc/stat)
        local user nice system idle iowait irq softirq steal guest guest_nice
        read cpu user nice system idle iowait irq softirq steal guest guest_nice <<< "$cpu_line"
        
        local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        local usage=$((100 * (total - idle) / total))
        echo "$usage"
    else
        # macOS fallback
        top -l 1 -n 0 | grep "CPU usage" | awk '{print int($3)}'
    fi
}

get_cpu_cores() {
    if [[ -f /proc/cpuinfo ]]; then
        grep -c "^processor" /proc/cpuinfo
    else
        # macOS fallback
        sysctl -n hw.ncpu
    fi
}

get_memory_info() {
    if [[ -f /proc/meminfo ]]; then
        local total used free available
        total=$(grep MemTotal /proc/meminfo | awk '{print int($2/1024)}')
        free=$(grep MemFree /proc/meminfo | awk '{print int($2/1024)}')
        available=$(grep MemAvailable /proc/meminfo | awk '{print int($2/1024)}')
        used=$((total - available))
        
        echo "$total $used $available"
    else
        # macOS fallback
        local total used
        total=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024)}')
        used=$(vm_stat | grep "Pages active" | awk '{print int($3)*4/1024}')
        echo "$total $used 0"
    fi
}

get_disk_info() {
    df -h / | tail -n 1 | awk '{print $2, $3, $4, $5}'
}

get_network_info() {
    local iface
    iface=$(ip route get 8.8.8.8 2>/dev/null | grep -oP 'dev \K[^ ]+' || echo "eth0")
    
    if [[ -f /proc/net/dev ]]; then
        local rx tx
        rx=$(grep "$iface" /proc/net/dev | awk '{print $2}')
        tx=$(grep "$iface" /proc/net/dev | awk '{print $10}')
        
        # 转换为 MB
        rx=$((rx / 1024 / 1024))
        tx=$((tx / 1024 / 1024))
        
        echo "$rx $tx"
    else
        # macOS fallback
        echo "0 0"
    fi
}

cmd_overview() {
    local hostname
    hostname=$(hostname)
    local uptime
    uptime=$(get_uptime)
    local load_avg
    load_avg=$(get_load_avg)
    local cpu_usage
    cpu_usage=$(get_cpu_cores)
    local cpu_percent
    cpu_percent=$(get_cpu_usage)
    local cores
    cores=$(get_cpu_cores)
    
    local mem_info
    mem_info=$(get_memory_info)
    local mem_total used available
    read mem_total used available <<< "$mem_info"
    local mem_percent=$((used * 100 / mem_total))
    
    local disk_info
    disk_info=$(get_disk_info)
    local disk_total disk_used disk_free disk_percent
    read disk_total disk_used disk_free disk_percent <<< "$disk_info"
    
    local net_info
    net_info=$(get_network_info)
    local net_rx net_tx
    read net_rx net_tx <<< "$net_info"
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}              ${GREEN}System Overview${NC}                       ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC} Hostname:     ${YELLOW}%-37s${NC} ${CYAN}║${NC}\n" "$hostname"
    printf "${CYAN}║${NC} Uptime:       ${YELLOW}%-37s${NC} ${CYAN}║${NC}\n" "$uptime"
    printf "${CYAN}║${NC} Load Avg:     ${YELLOW}%-37s${NC} ${CYAN}║${NC}\n" "$load_avg"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════╣${NC}"
    printf "${CYAN}║${NC} CPU:          ${YELLOW}%3s%%${NC} used (${GREEN}%s${NC} cores)                    ${CYAN}║${NC}\n" "$cpu_percent" "$cores"
    printf "${CYAN}║${NC} Memory:       ${YELLOW}%sGB${NC} / %sGB (${GREEN}%s%%${NC})                      ${CYAN}║${NC}\n" "$used" "$mem_total" "$mem_percent"
    printf "${CYAN}║${NC} Disk:         ${YELLOW}%s${NC} / %s (${GREEN}%s%%${NC})                         ${CYAN}║${NC}\n" "$disk_used" "$disk_total" "$disk_percent"
    printf "${CYAN}║${NC} Network:      ${GREEN}↓${NC} %sMB  ${GREEN}↑${NC} %sMB                           ${CYAN}║${NC}\n" "$net_rx" "$net_tx"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════╝${NC}"
}

cmd_cpu() {
    local cores
    cores=$(get_cpu_cores)
    local usage
    usage=$(get_cpu_usage)
    
    echo -e "${CYAN}CPU Information${NC}"
    echo "================="
    echo -e "使用率: ${GREEN}${usage}%${NC}"
    echo -e "核心数: ${GREEN}${cores}${NC}"
    
    if [[ -f /proc/cpuinfo ]]; then
        echo ""
        echo -e "${YELLOW}CPU 型号:${NC}"
        grep "model name" /proc/cpuinfo | head -n 1 | cut -d: -f2
    fi
}

cmd_memory() {
    local mem_info
    mem_info=$(get_memory_info)
    local total used available
    read total used available <<< "$mem_info"
    local percent=$((used * 100 / total))
    
    echo -e "${CYAN}Memory Information${NC}"
    echo "===================="
    echo -e "总量:   ${GREEN}${total} MB${NC}"
    echo -e "已用:   ${YELLOW}${used} MB${NC}"
    echo -e "可用:   ${GREEN}${available} MB${NC}"
    echo -e "使用率: ${YELLOW}${percent}%${NC}"
    
    # 内存条
    echo ""
    echo -e "${CYAN}使用情况:${NC}"
    local bar_width=40
    local filled=$((bar_width * percent / 100))
    local empty=$((bar_width - filled))
    
    printf "["
    for i in $(seq 1 $filled); do printf "${GREEN}█${NC}"; done
    for i in $(seq 1 $empty); do printf "${RED}░${NC}"; done
    printf "] %s%%\n" "$percent"
}

cmd_disk() {
    echo -e "${CYAN}Disk Information${NC}"
    echo "=================="
    echo ""
    df -h | head -n 1
    df -h | tail -n +2 | grep -v "tmpfs\|devtmpfs\|loop" || df -h | tail -n +2
}

cmd_network() {
    echo -e "${CYAN}Network Information${NC}"
    echo "====================="
    echo ""
    
    # 显示所有网络接口
    if command -v ip &> /dev/null; then
        ip -brief addr show | grep -v "lo\|DOWN"
    fi
    
    echo ""
    echo -e "${YELLOW}网络统计:${NC}"
    if [[ -f /proc/net/dev ]]; then
        grep -v "lo\|Inter" /proc/net/dev | grep -v "face" | while read line; do
            iface=$(echo "$line" | cut -d: -f1)
            rx=$(echo "$line" | awk '{print int($2/1024)}')
            tx=$(echo "$line" | awk '{print int($10/1024)}')
            printf "  %-10s  ↓ %8s KB  ↑ %8s KB\n" "$iface" "$rx" "$tx"
        done
    fi
}

cmd_process() {
    local sort_by="${1:-cpu}"
    local limit="${2:-10}"
    
    echo -e "${CYAN}Process Information (sorted by $sort_by, top $limit)${NC}"
    echo "===================================================="
    echo ""
    
    case "$sort_by" in
        cpu)
            ps aux --sort=-%cpu | head -n $((limit + 1))
            ;;
        memory)
            ps aux --sort=-%mem | head -n $((limit + 1))
            ;;
        pid)
            ps -eo pid,user,pcpu,pmem,comm | head -n $((limit + 1))
            ;;
        *)
            echo "排序方式: cpu, memory, pid"
            exit 1
            ;;
    esac
}

cmd_top() {
    local count="${1:-10}"
    
    echo -e "${CYAN}Top $count Processes (by CPU & Memory)${NC}"
    echo "============================================="
    echo ""
    
    ps aux --sort=-%cpu | head -n $((count + 1)) | nl
}

cmd_watch() {
    local interval="${1:-2}"
    
    echo -e "${GREEN}实时监控模式 (间隔: ${interval}s, 按 Ctrl+C 退出)${NC}"
    echo ""
    
    while true; do
        clear
        cmd_overview
        sleep "$interval"
    done
}

# 主程序
main() {
    local command="${1:-}"
    
    case "$command" in
        --version|-v)
            print_version
            exit 0
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        overview)
            cmd_overview
            ;;
        cpu)
            cmd_cpu
            ;;
        memory)
            cmd_memory
            ;;
        disk)
            cmd_disk
            ;;
        network)
            cmd_network
            ;;
        process)
            shift
            cmd_process "$@"
            ;;
        top)
            shift
            cmd_top "$@"
            ;;
        watch)
            shift
            cmd_watch "$@"
            ;;
        "")
            cmd_overview
            exit 0
            ;;
        *)
            echo -e "${RED}未知命令: $command${NC}"
            echo "使用 system-monitor --help 查看帮助"
            exit 1
            ;;
    esac
}

main "$@"
