#!/bin/bash

# Network Scanner - 网络扫描和诊断工具
# 作者: OpenClaw Agent
# 功能: 端口扫描、主机发现、服务检测、网络诊断

set -e

VERSION="1.0.0"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_version() {
    echo "network-scanner v$VERSION"
}

print_help() {
    echo "Network Scanner - 网络扫描和诊断工具"
    echo ""
    echo "用法: network-scanner <command> [options]"
    echo ""
    echo "命令:"
    echo "  port-scan <host> [ports]     扫描端口"
    echo "  host-discover [range]        发现主机"
    echo "  service-detect <host> <port> 检测服务"
    echo "  ping <host> [count]          Ping 测试"
    echo "  dns-lookup <domain>         DNS 查询"
    echo "  traceroute <host>            路由追踪"
    echo ""
    echo "选项:"
    echo "  --help     显示帮助"
    echo "  --version  显示版本"
}

cmd_port_scan() {
    local host="$1"
    local ports="${2:-80,443,22,3389,8080,3306,5432,6379}"
    
    if [[ -z "$host" ]]; then
        echo -e "${RED}错误: 请指定目标主机${NC}"
        echo "用法: network-scanner port-scan <host> [ports]"
        exit 1
    fi
    
    echo -e "${BLUE}扫描 $host 的端口...${NC}"
    echo "端口列表: $ports"
    echo ""
    
    # 转换为数组
    IFS=',' read -ra PORT_ARRAY <<< "$ports"
    
    for port in "${PORT_ARRAY[@]}"; do
        # 处理范围 (如 1-1000)
        if [[ "$port" == *-* ]]; then
            local start="${port%-*}"
            local end="${port#*-}"
            for p in $(seq "$start" "$end"); do
                scan_port "$host" "$p" &
            done
        else
            scan_port "$host" "$port" &
        fi
    done
    
    wait
}

scan_port() {
    local host="$1"
    local port="$2"
    
    if timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        local service
        service=$(get_service_name "$port")
        printf "${GREEN}%-10s${NC} ${GREEN}OPEN${NC}   (%s)\n" "Port $port:" "$service"
    fi
}

get_service_name() {
    local port="$1"
    case "$port" in
        20) echo "FTP Data" ;;
        21) echo "FTP" ;;
        22) echo "SSH" ;;
        23) echo "Telnet" ;;
        25) echo "SMTP" ;;
        53) echo "DNS" ;;
        80) echo "HTTP" ;;
        110) echo "POP3" ;;
        143) echo "IMAP" ;;
        443) echo "HTTPS" ;;
        445) echo "SMB" ;;
        993) echo "IMAPS" ;;
        995) echo "POP3S" ;;
        1433) echo "MSSQL" ;;
        1521) echo "Oracle" ;;
        3306) echo "MySQL" ;;
        3389) echo "RDP" ;;
        5432) echo "PostgreSQL" ;;
        5900) echo "VNC" ;;
        6379) echo "Redis" ;;
        8080) echo "HTTP Proxy" ;;
        8443) echo "HTTPS Alt" ;;
        27017) echo "MongoDB" ;;
        *) echo "Unknown" ;;
    esac
}

cmd_host_discover() {
    local range="${1:-192.168.1.1/24}"
    
    echo -e "${BLUE}发现 $range 内的活跃主机...${NC}"
    echo ""
    
    # 使用 fping 或 ping 进行主机发现
    if command -v fping &> /dev/null; then
        fping -a -g "$range" 2>/dev/null | while read host; do
            printf "${GREEN}%-20s${NC} ${GREEN}ACTIVE${NC}\n" "$host"
        done
    else
        # 备用方法: 并行 ping
        local subnet
        subnet=$(echo "$range" | sed 's/\//.0\//')
        for i in {1..254}; do
            local ip=$(echo "$subnet" | sed "s/\* /$i/")
            (timeout 1 ping -c 1 -W 1 "$ip" >/dev/null 2>&1 && \
                printf "${GREEN}%-20s${NC} ${GREEN}ACTIVE${NC}\n" "$ip") &
        done
        wait
    fi
}

cmd_service_detect() {
    local host="$1"
    local port="$2"
    
    if [[ -z "$host" || -z "$port" ]]; then
        echo -e "${RED}错误: 请指定主机和端口${NC}"
        echo "用法: network-scanner service-detect <host> <port>"
        exit 1
    fi
    
    echo -e "${BLUE}检测 $host:$port 的服务信息...${NC}"
    
    # 尝试获取 banner
    local banner
    banner=$(echo "" | timeout 2 nc "$host" "$port" 2>/dev/null | head -n 1)
    
    if [[ -n "$banner" ]]; then
        echo -e "${GREEN}服务 Banner:${NC}"
        echo "$banner"
    else
        local service
        service=$(get_service_name "$port")
        echo -e "${YELLOW}服务:${NC} $service"
        echo -e "${YELLOW}Banner:${NC} (无法获取)"
    fi
}

cmd_ping() {
    local host="$1"
    local count="${2:-4}"
    
    if [[ -z "$host" ]]; then
        echo -e "${RED}错误: 请指定目标主机${NC}"
        echo "用法: network-scanner ping <host> [count]"
        exit 1
    fi
    
    echo -e "${BLUE}Ping $host ($count 次)...${NC}"
    echo ""
    ping -c "$count" "$host"
}

cmd_dns_lookup() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        echo -e "${RED}错误: 请指定域名${NC}"
        echo "用法: network-scanner dns-lookup <domain>"
        exit 1
    fi
    
    echo -e "${BLUE}DNS 查询: $domain${NC}"
    echo ""
    
    # A 记录
    local ip
    ip=$(dig +short A "$domain" 2>/dev/null | tail -n1)
    if [[ -n "$ip" ]]; then
        echo -e "${GREEN}A Record:${NC} $ip"
    fi
    
    # AAAA 记录
    local ip6
    ip6=$(dig +short AAAA "$domain" 2>/dev/null | tail -n1)
    if [[ -n "$ip6" ]]; then
        echo -e "${GREEN}AAAA Record:${NC} $ip6"
    fi
    
    # CNAME 记录
    local cname
    cname=$(dig +short CNAME "$domain" 2>/dev/null | tail -n1)
    if [[ -n "$cname" ]]; then
        echo -e "${GREEN}CNAME:${NC} $cname"
    fi
    
    # MX 记录
    local mx
    mx=$(dig +short MX "$domain" 2>/dev/null)
    if [[ -n "$mx" ]]; then
        echo -e "${GREEN}MX Record:${NC}"
        echo "$mx"
    fi
    
    # NS 记录
    local ns
    ns=$(dig +short NS "$domain" 2>/dev/null)
    if [[ -n "$ns" ]]; then
        echo -e "${GREEN}NS Record:${NC}"
        echo "$ns"
    fi
}

cmd_traceroute() {
    local host="$1"
    
    if [[ -z "$host" ]]; then
        echo -e "${RED}错误: 请指定目标主机${NC}"
        echo "用法: network-scanner traceroute <host>"
        exit 1
    fi
    
    echo -e "${BLUE}路由追踪: $host${NC}"
    echo ""
    
    if command -v traceroute &> /dev/null; then
        traceroute -m 15 "$host"
    elif command -v tracepath &> /dev/null; then
        tracepath "$host"
    else
        echo -e "${YELLOW}警告: 未安装 traceroute${NC}"
        echo "使用 ping -I 进行简单追踪..."
        ping -c 10 -W 1 "$host" | grep "from"
    fi
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
        port-scan)
            shift
            cmd_port_scan "$@"
            ;;
        host-discover)
            shift
            cmd_host_discover "$@"
            ;;
        service-detect)
            shift
            cmd_service_detect "$@"
            ;;
        ping)
            shift
            cmd_ping "$@"
            ;;
        dns-lookup)
            shift
            cmd_dns_lookup "$@"
            ;;
        traceroute)
            shift
            cmd_traceroute "$@"
            ;;
        "")
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}未知命令: $command${NC}"
            echo "使用 network-scanner --help 查看帮助"
            exit 1
            ;;
    esac
}

main "$@"
