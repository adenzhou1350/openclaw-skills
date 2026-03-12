#!/bin/bash
# Log Analyzer - AI-powered log analysis tool
# Version: 1.0.0

set -e

VERSION="1.0.0"
LOG_ANALYZER_VERSION="1.0.0"

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
show_help() {
    cat << EOF
Log Analyzer - AI-powered log analysis tool v$VERSION

Usage: log-analyzer <command> [options]

Commands:
    analyze <file>      Analyze log file and show summary
    monitor <file>      Monitor log file in real-time
    errors <file>       Show only error-level entries
    warnings <file>     Show only warning-level entries
    search <pattern> <file>  Search for pattern in logs
    stats <file>        Show log statistics
    export <file> <format>  Export to json/csv/html
    tail <file> [lines] Show last N lines (default: 20)
    follow <file>       Follow log in real-time (alias for monitor)
    levels <file>       Show log level distribution
    timeline <file>     Show log timeline
    help                Show this help message

Options:
    -h, --help     Show help
    -v, --version  Show version

Examples:
    log-analyzer analyze /var/log/app.log
    log-analyzer errors /var/log/app.log
    log-analyzer search "Exception" /var/log/app.log
    log-analyzer stats /var/log/app.log
    log-analyzer monitor /var/log/app.log

EOF
}

show_version() {
    echo "log-analyzer v$VERSION"
}

# Check if file exists
check_file() {
    if [ -z "$1" ]; then
        echo -e "${RED}Error: No file specified${NC}"
        exit 1
    fi
    if [ ! -f "$1" ]; then
        echo -e "${RED}Error: File not found: $1${NC}"
        exit 1
    fi
}

# Analyze log file
analyze_log() {
    check_file "$1"
    local file="$1"
    
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  Log Analysis Report${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}File:${NC} $file"
    echo -e "${GREEN}Size:${NC} $(du -h "$file" | cut -f1)"
    echo -e "${GREEN}Lines:${NC} $(wc -l < "$file")"
    echo ""
    
    # Date range
    local first_line=$(head -1 "$file")
    local last_line=$(tail -1 "$file")
    echo -e "${GREEN}First line:${NC} ${first_line:0:50}"
    echo -e "${GREEN}Last line:${NC} ${last_line:0:50}"
    echo ""
    
    # Log level distribution
    echo -e "${YELLOW}Log Level Distribution:${NC}"
    local total=$(wc -l < "$file")
    local errors=$(grep -ci "error\|fatal\|exception\|fail" "$file" 2>/dev/null || echo 0)
    local warnings=$(grep -ci "warn\|warning" "$file" 2>/dev/null || echo 0)
    local info=$(grep -ci "info" "$file" 2>/dev/null || echo 0)
    local debug=$(grep -ci "debug" "$file" 2>/dev/null || echo 0)
    
    echo -e "  ${RED}ERROR/FATAL:${NC} $errors ($(( errors * 100 / total ))%)"
    echo -e "  ${YELLOW}WARN:${NC} $warnings ($(( warnings * 100 / total ))%)"
    echo -e "  ${GREEN}INFO:${NC} $info ($(( info * 100 / total ))%)"
    echo -e "  ${BLUE}DEBUG:${NC} $debug ($(( debug * 100 / total ))%)"
    echo ""
    
    # Top errors
    echo -e "${RED}Top Errors:${NC}"
    grep -i "error\|exception\|fatal\|fail" "$file" 2>/dev/null | \
        sed 's/.*\(error\|exception\|fatal\|fail\)/\1/i' | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count msg; do
            echo -e "  ${RED}$count${NC} - $msg"
        done
    echo ""
    
    # Top sources
    echo -e "${YELLOW}Top Log Sources:${NC}"
    grep -oP '\[.*?\]|\(.*?\)|<.*?>' "$file" 2>/dev/null | \
        sort | uniq -c | sort -rn | head -5 | \
        while read count src; do
            echo -e "  ${GREEN}$count${NC} - $src"
        done
    echo ""
    
    # Recommendations
    echo -e "${BLUE}Recommendations:${NC}"
    if [ "$errors" -gt 100 ]; then
        echo -e "  ⚠️  High error rate detected - investigate errors"
    fi
    if [ "$warnings" -gt 200 ]; then
        echo -e "  ⚠️  Many warnings - review for optimization opportunities"
    fi
    if [ "$debug" -eq 0 ]; then
        echo -e "  ℹ️  No DEBUG logs - enable for better troubleshooting"
    fi
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# Show errors only
show_errors() {
    check_file "$1"
    local file="$1"
    
    echo -e "${RED}═══ Error Log Entries ═══${NC}"
    grep -i "error\|fatal\|exception\|fail" "$file" 2>/dev/null | \
        head -50 | \
        while read line; do
            echo -e "${RED}$line${NC}"
        done
    
    local total_errors=$(grep -ci "error\|fatal\|exception\|fail" "$file" 2>/dev/null || echo 0)
    echo ""
    echo -e "${RED}Total error entries: $total_errors${NC}"
}

# Show warnings only
show_warnings() {
    check_file "$1"
    local file="$1"
    
    echo -e "${YELLOW}═══ Warning Log Entries ═══${NC}"
    grep -i "warn\|warning" "$file" 2>/dev/null | \
        head -50 | \
        while read line; do
            echo -e "${YELLOW}$line${NC}"
        done
    
    local total_warnings=$(grep -ci "warn\|warning" "$file" 2>/dev/null || echo 0)
    echo ""
    echo -e "${YELLOW}Total warning entries: $total_warnings${NC}"
}

# Search in logs
search_log() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Error: Pattern and file required${NC}"
        echo "Usage: log-analyzer search <pattern> <file>"
        exit 1
    fi
    check_file "$2"
    
    local pattern="$1"
    local file="$2"
    
    echo -e "${GREEN}Searching for: ${pattern}${NC}"
    echo -e "${GREEN}In file: ${file}${NC}"
    echo ""
    
    local count=$(grep -ci "$pattern" "$file" 2>/dev/null || echo 0)
    echo -e "${YELLOW}Found $count matches:${NC}"
    echo ""
    
    grep -i "$pattern" "$file" 2>/dev/null | head -30 | \
        while read line; do
            if echo "$line" | grep -qi "error\|fatal\|exception"; then
                echo -e "${RED}$line${NC}"
            elif echo "$line" | grep -qi "warn"; then
                echo -e "${YELLOW}$line${NC}"
            else
                echo "$line"
            fi
        done
}

# Show statistics
show_stats() {
    check_file "$1"
    local file="$1"
    
    echo -e "${BLUE}═══ Log Statistics ═══${NC}"
    echo ""
    
    local total=$(wc -l < "$file")
    local size=$(du -h "$file" | cut -f1)
    
    echo -e "${GREEN}Basic Stats:${NC}"
    echo -e "  Total lines: $total"
    echo -e "  File size: $size"
    echo ""
    
    # Time-based stats
    echo -e "${GREEN}Time Distribution:${NC}"
    if grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$file"; then
        local first_date=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$file" | head -1)
        local last_date=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$file" | tail -1)
        echo -e "  First date: $first_date"
        echo -e "  Last date: $last_date"
    fi
    echo ""
    
    # Level stats
    echo -e "${GREEN}Level Stats:${NC}"
    local errors=$(grep -ci "error\|fatal\|exception" "$file" 2>/dev/null || echo 0)
    local warnings=$(grep -ci "warn" "$file" 2>/dev/null || echo 0)
    local info=$(grep -ci "\] INFO" "$file" 2>/dev/null || echo 0)
    local debug=$(grep -ci "debug" "$file" 2>/dev/null || echo 0)
    
    echo -e "  Errors: $errors ($(( errors * 100 / total ))%)"
    echo -e "  Warnings: $warnings ($(( warnings * 100 / total ))%)"
    echo -e "  Info: $info ($(( info * 100 / total ))%)"
    echo -e "  Debug: $debug ($(( debug * 100 / total ))%)"
    echo ""
    
    # Error rate
    if [ "$total" -gt 0 ]; then
        echo -e "${GREEN}Error Rate:${NC}"
        local rate=$(( errors * 100 / total ))
        echo -e "  Overall: $rate%"
        if [ "$rate" -lt 1 ]; then
            echo -e "  Status: ${GREEN}Excellent${NC}"
        elif [ "$rate" -lt 5 ]; then
            echo -e "  Status: ${YELLOW}Good${NC}"
        else
            echo -e "  Status: ${RED}Needs Attention${NC}"
        fi
    fi
}

# Show tail
show_tail() {
    check_file "$1"
    local file="$1"
    local lines="${2:-20}"
    
    echo -e "${BLUE}═══ Last $lines Lines ═══${NC}"
    tail -n "$lines" "$file" | \
        while read line; do
            if echo "$line" | grep -qi "error\|fatal\|exception"; then
                echo -e "${RED}$line${NC}"
            elif echo "$line" | grep -qi "warn"; then
                echo -e "${YELLOW}$line${NC}"
            else
                echo "$line"
            fi
        done
}

# Monitor log file
monitor_log() {
    check_file "$1"
    local file="$1"
    
    echo -e "${GREEN}Monitoring: $file${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    echo ""
    
    tail -f "$file" | \
        while read line; do
            if echo "$line" | grep -qi "error\|fatal\|exception"; then
                echo -e "${RED}[ERROR] $line${NC}"
            elif echo "$line" | grep -qi "warn"; then
                echo -e "${YELLOW}[WARN] $line${NC}"
            elif echo "$line" | grep -qi "debug"; then
                echo -e "${BLUE}[DEBUG] $line${NC}"
            else
                echo -e "${GREEN}[INFO] $line${NC}"
            fi
        done
}

# Show log levels distribution
show_levels() {
    check_file "$1"
    local file="$1"
    
    echo -e "${BLUE}═══ Log Level Distribution ═══${NC}"
    echo ""
    
    local total=$(wc -l < "$file")
    
    echo -e "${RED}ERROR:   $(grep -ci "error\|fatal" "$file" 2>/dev/null || echo 0)${NC} ($(( $(grep -ci "error\|fatal" "$file" 2>/dev/null || echo 0) * 100 / total ))%)"
    echo -e "${YELLOW}WARN:    $(grep -ci "warn" "$file" 2>/dev/null || echo 0)${NC} ($(( $(grep -ci "warn" "$file" 2>/dev/null || echo 0) * 100 / total ))%)"
    echo -e "${GREEN}INFO:    $(grep -ci "\] INFO\|\[INFO" "$file" 2>/dev/null || echo 0)${NC} ($(( $(grep -ci "\] INFO\|\[INFO" "$file" 2>/dev/null || echo 0) * 100 / total ))%)"
    echo -e "${BLUE}DEBUG:   $(grep -ci "debug" "$file" 2>/dev/null || echo 0)${NC} ($(( $(grep -ci "debug" "$file" 2>/dev/null || echo 0) * 100 / total ))%)"
    echo ""
}

# Export logs
export_logs() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}Error: File and format required${NC}"
        echo "Usage: log-analyzer export <file> <json|csv|html>"
        exit 1
    fi
    check_file "$1"
    
    local file="$1"
    local format="$2"
    local output="${file%.*}.$format"
    
    case "$format" in
        json)
            echo "[]" > "$output"
            while IFS= read -r line; do
                level="info"
                if echo "$line" | grep -qi "error\|fatal"; then level="error"
                elif echo "$line" | grep -qi "warn"; then level="warning"
                elif echo "$line" | grep -qi "debug"; then level="debug"
                fi
                jq -n --arg l "$level" --arg m "$line" '{level: $l, message: $m}' >> "$output"
            done < "$file"
            ;;
        csv)
            echo "level,message" > "$output"
            while IFS= read -r line; do
                level="info"
                if echo "$line" | grep -qi "error\|fatal"; then level="error"
                elif echo "$line" | grep -qi "warn"; then level="warning"
                elif echo "$line" | grep -qi "debug"; then level="debug"
                fi
                echo "$level,\"$line\"" >> "$output"
            done < "$file"
            ;;
        html)
            cat > "$output" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Log Report</title>
    <style>
        body { font-family: monospace; padding: 20px; }
        .error { color: red; }
        .warning { color: orange; }
        .info { color: green; }
        .debug { color: blue; }
    </style>
</head>
<body>
    <h1>Log Report</h1>
    <pre>
HTMLEOF
            while IFS= read -r line; do
                if echo "$line" | grep -qi "error\|fatal"; then
                    echo "<span class='error'>$line</span>" >> "$output"
                elif echo "$line" | grep -qi "warn"; then
                    echo "<span class='warning'>$line</span>" >> "$output"
                elif echo "$line" | grep -qi "debug"; then
                    echo "<span class='debug'>$line</span>" >> "$output"
                else
                    echo "<span class='info'>$line</span>" >> "$output"
                fi
            done < "$file"
            cat >> "$output" << 'HTMLEOF'
    </pre>
</body>
</html>
HTMLEOF
            ;;
    esac
    
    echo -e "${GREEN}Exported to: $output${NC}"
}

# Main command handler
case "${1:-help}" in
    -h|--help)
        show_help
        ;;
    -v|--version)
        show_version
        ;;
    analyze)
        analyze_log "$2"
        ;;
    errors)
        show_errors "$2"
        ;;
    warnings)
        show_warnings "$2"
        ;;
    search)
        search_log "$2" "$3"
        ;;
    stats)
        show_stats "$2"
        ;;
    tail)
        show_tail "$2" "$3"
        ;;
    monitor|follow)
        monitor_log "$2"
        ;;
    levels)
        show_levels "$2"
        ;;
    export)
        export_logs "$2" "$3"
        ;;
    *)
        show_help
        ;;
esac
