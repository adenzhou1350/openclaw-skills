#!/bin/bash
# Post Scheduler - 社交媒体定时发布工具
# 支持多平台内容定时推送

set -e

CONFIG_DIR="${HOME}/.openclaw/config"
DATA_DIR="${HOME}/.openclaw/data/post-scheduler"
CONFIG_FILE="${CONFIG_DIR}/post-scheduler.json"
QUEUE_FILE="${DATA_DIR}/queue.json"
HISTORY_FILE="${DATA_DIR}/history.json"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 初始化目录
init() {
    mkdir -p "$CONFIG_DIR" "$DATA_DIR"
    if [ ! -f "$QUEUE_FILE" ]; then
        echo "[]" > "$QUEUE_FILE"
    fi
    if [ ! -f "$HISTORY_FILE" ]; then
        echo "[]" > "$HISTORY_FILE"
    fi
    if [ ! -f "$CONFIG_FILE" ]; then
        cat > "$CONFIG_FILE" << 'EOF'
{
  "platforms": {
    "twitter": { "enabled": false },
    "xiaohongshu": { "enabled": false },
    "linkedin": { "enabled": false }
  },
  "default_schedule": "0 9 * * *"
}
EOF
    fi
    echo -e "${GREEN}✓ Post Scheduler 初始化完成${NC}"
    echo "配置文件: $CONFIG_FILE"
}

# 列出待发布内容
cmd_list() {
    init
    echo -e "${YELLOW}📋 待发布内容队列:${NC}"
    if [ -s "$QUEUE_FILE" ] && [ "$(cat "$QUEUE_FILE")" != "[]" ]; then
        cat "$QUEUE_FILE" | python3 -m json.tool 2>/dev/null || cat "$QUEUE_FILE"
    else
        echo "  (空)"
    fi
}

# 添加新内容
cmd_add() {
    init
    local platform=""
    local content=""
    local schedule=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --platform)
                platform="$2"
                shift 2
                ;;
            --content)
                content="$2"
                shift 2
                ;;
            --schedule)
                schedule="$2"
                shift 2
                ;;
            *)
                echo "未知参数: $1"
                exit 1
                ;;
        esac
    done

    if [ -z "$platform" ] || [ -z "$content" ]; then
        echo "用法: post-scheduler add --platform <平台> --content <内容> --schedule <Cron>"
        echo "示例: post-scheduler add --platform twitter --content 'Hello' --schedule '0 9 * * *'"
        exit 1
    fi

    if [ -z "$schedule" ]; then
        schedule=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('default_schedule', '0 9 * * *'))" 2>/dev/null || echo "0 9 * * *")
    fi

    local id=$(date +%s)
    local new_item="{\"id\": $id, \"platform\": \"$platform\", \"content\": \"$content\", \"schedule\": \"$schedule\", \"status\": \"pending\", \"created_at\": \"$(date -Iseconds)\"}"

    python3 -c "
import json
with open('$QUEUE_FILE', 'r') as f:
    data = json.load(f)
data.append(json.loads('''$new_item'''))
with open('$QUEUE_FILE', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"

    echo -e "${GREEN}✓ 已添加发布任务 #${id}${NC}"
    echo "  平台: $platform"
    echo "  内容: $content"
    echo "  发布时间: $schedule"
}

# 删除内容
cmd_delete() {
    init
    local id=$1
    if [ -z "$id" ]; then
        echo "用法: post-scheduler delete <id>"
        exit 1
    fi

    python3 -c "
import json
with open('$QUEUE_FILE', 'r') as f:
    data = json.load(f)
data = [item for item in data if item.get('id') != $id]
with open('$QUEUE_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    echo -e "${GREEN}✓ 已删除任务 #${id}${NC}"
}

# 查看历史
cmd_history() {
    init
    echo -e "${YELLOW}📜 发布历史:${NC}"
    if [ -s "$HISTORY_FILE" ] && [ "$(cat "$HISTORY_FILE")" != "[]" ]; then
        cat "$HISTORY_FILE" | python3 -m json.tool 2>/dev/null || cat "$HISTORY_FILE"
    else
        echo "  (空)"
    fi
}

# 手动触发发布
cmd_publish() {
    init
    local id=$1
    if [ -z "$id" ]; then
        echo "用法: post-scheduler publish <id>"
        exit 1
    fi

    echo -e "${GREEN}✓ 模拟发布任务 #${id}${NC}"
    echo "  (实际发布需要配置平台 API)"

    # 移动到历史
    python3 -c "
import json
from datetime import datetime
with open('$QUEUE_FILE', 'r') as f:
    queue = json.load(f)
with open('$HISTORY_FILE', 'r') as f:
    history = json.load(f)

item = None
queue = [i for i in queue if (item := i) or i.get('id') != $id]
if item:
    item['status'] = 'published'
    item['published_at'] = datetime.now().isoformat()
    history.append(item)

with open('$QUEUE_FILE', 'w') as f:
    json.dump(queue, f, indent=2)
with open('$HISTORY_FILE', 'w') as f:
    json.dump(history, f, indent=2)
"
}

# 主命令
case "${1:-}" in
    init)
        init
        ;;
    list)
        cmd_list
        ;;
    add)
        shift
        cmd_add "$@"
        ;;
    delete)
        cmd_delete "$2"
        ;;
    history)
        cmd_history
        ;;
    publish)
        cmd_publish "$2"
        ;;
    *)
        echo "Post Scheduler - 社交媒体定时发布工具"
        echo ""
        echo "用法:"
        echo "  post-scheduler init              初始化配置"
        echo "  post-scheduler list               列出待发布内容"
        echo "  post-scheduler add                添加新内容"
        echo "  post-scheduler delete <id>        删除内容"
        echo "  post-scheduler history            查看发布历史"
        echo "  post-scheduler publish <id>       手动发布"
        echo ""
        echo "示例:"
        echo "  post-scheduler add --platform twitter --content 'Hello World' --schedule '0 9 * * *'"
        ;;
esac
