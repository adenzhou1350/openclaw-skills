#!/bin/bash
# Cron Manager for OpenClaw
# 定时任务管理器

set -e

CRON_DIR="${OPENCLAW_HOME:-$HOME/.openclaw}/cron"
TASKS_FILE="$CRON_DIR/tasks.conf"
LOG_DIR="$CRON_DIR/logs"

# 初始化目录
init_dirs() {
    mkdir -p "$CRON_DIR" "$LOG_DIR"
}

# 列出所有任务
cmd_list() {
    init_dirs
    
    if [[ ! -f "$TASKS_FILE" ]]; then
        echo "暂无定时任务"
        return
    fi
    
    echo "📋 定时任务列表:"
    echo "================"
    while IFS='|' read -r name schedule script enabled; do
        [[ -z "$name" || "$name" == \#* ]] && continue
        status="✅" [[ "$enabled" == "0" ]] && status="❌"
        echo "$status $name | $schedule | $script"
    done < "$TASKS_FILE"
}

# 添加任务
cmd_add() {
    local name="$1"
    local schedule="$2"
    local script="$3"
    
    if [[ -z "$name" || -z "$schedule" || -z "$script" ]]; then
        echo "用法: cron add <名称> <cron表达式> <脚本路径>"
        return 1
    fi
    
    init_dirs
    echo "$name|$schedule|$script|1" >> "$TASKS_FILE"
    echo "✅ 已添加任务: $name"
}

# 删除任务
cmd_remove() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        echo "用法: cron remove <名称>"
        return 1
    fi
    
    init_dirs
    sed -i "/^$name|/d" "$TASKS_FILE" 2>/dev/null || true
    echo "✅ 已删除任务: $name"
}

# 查看日志
cmd_logs() {
    local task_name="$1"
    local lines="${2:-20}"
    
    if [[ -n "$task_name" ]]; then
        log_file="$LOG_DIR/${task_name}.log"
        if [[ -f "$log_file" ]]; then
            tail -n "$lines" "$log_file"
        else
            echo "暂无日志: $task_name"
        fi
    else
        echo "📜 最近日志:"
        ls -t "$LOG_DIR"/*.log 2>/dev/null | head -5 | while read f; do
            echo "--- $(basename "$f") ---"
            tail -5 "$f"
        done
    fi
}

# 主命令
case "${1:-list}" in
    list) cmd_list "$@" ;;
    add) cmd_add "${2:-}" "${3:-}" "${4:-}" ;;
    remove|rm) cmd_remove "${2:-}" ;;
    logs) cmd_logs "${2:-}" "${3:-}" ;;
    *) echo "用法: cron <list|add|remove|logs>" ;;
esac
