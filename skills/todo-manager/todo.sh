#!/bin/bash

# Todo Manager - CLI task management tool
# Compatible with OpenClaw Skill system

set -e

# Disable exit on error for specific functions
disable_exit_on_error() {
    set +e
}

# Re-enable exit on error
enable_exit_on_error() {
    set -e
}

DATA_DIR="${HOME}/.openclaw/data"
TODO_FILE="${DATA_DIR}/todos.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize data directory
init() {
    mkdir -p "${DATA_DIR}"
    if [[ ! -f "${TODO_FILE}" ]]; then
        echo '[]' > "${TODO_FILE}"
    fi
}

# Get next ID
get_next_id() {
    local max_id=$(jq '[.[] | .id] | max // 0' "${TODO_FILE}")
    echo $((max_id + 1))
}

# Add a new task
cmd_add() {
    local task_text=""
    local priority="medium"
    local due_date=""
    local category=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--priority)
                priority="$2"
                shift 2
                ;;
            -d|--due)
                due_date="$2"
                shift 2
                ;;
            -c|--category)
                category="$2"
                shift 2
                ;;
            *)
                task_text="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$task_text" ]]; then
        echo -e "${RED}Error: Task description required${NC}"
        echo "Usage: todo add <task> [-p high|medium|low] [-d YYYY-MM-DD] [-c category]"
        exit 1
    fi

    init

    local id=$(get_next_id)
    local created_at=$(date +%Y-%m-%d)

    local new_task=$(cat <<EOF
{
    "id": $id,
    "text": "$task_text",
    "priority": "$priority",
    "due": "$due_date",
    "category": "$category",
    "completed": false,
    "created_at": "$created_at",
    "completed_at": null
}
EOF
)

    local temp_file=$(mktemp)
    jq ". + [$new_task]" "${TODO_FILE}" > "$temp_file" && mv "$temp_file" "${TODO_FILE}"

    echo -e "${GREEN}✓${NC} Added task #$id: $task_text"
    [[ -n "$priority" ]] && echo "  Priority: $priority"
    [[ -n "$due_date" ]] && echo "  Due: $due_date"
    [[ -n "$category" ]] && echo "  Category: $category"
}

# List tasks
cmd_list() {
    disable_exit_on_error
    init

    local filter="all"
    local priority_filter=""
    local json_output=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --pending)
                filter="pending"
                shift
                ;;
            --completed)
                filter="completed"
                shift
                ;;
            --priority)
                priority_filter="$2"
                shift 2
                ;;
            --json)
                json_output=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ "$json_output" == true ]]; then
        case $filter in
            pending)
                jq '[.[] | select(.completed == false)]' "${TODO_FILE}"
                ;;
            completed)
                jq '[.[] | select(.completed == true)]' "${TODO_FILE}"
                ;;
            *)
                jq '.' "${TODO_FILE}"
                ;;
        esac
        return
    fi

    local tasks
    case $filter in
        pending)
            tasks=$(jq -c '.[] | select(.completed == false)' "${TODO_FILE}" 2>/dev/null)
            ;;
        completed)
            tasks=$(jq -c '.[] | select(.completed == true)' "${TODO_FILE}" 2>/dev/null)
            ;;
        *)
            tasks=$(jq -c '.[]' "${TODO_FILE}" 2>/dev/null)
            ;;
    esac

    if [[ -z "$tasks" ]]; then
        echo "No tasks found."
        return
    fi

    echo -e "${BLUE}=== Todo List ===${NC}"
    echo ""

    local count=0
    local high_count=0
    local medium_count=0
    local low_count=0
    local completed_count=0

    while IFS= read -r task; do
        [[ -z "$task" ]] && continue

        local id=$(echo "$task" | jq -r '.id')
        local text=$(echo "$task" | jq -r '.text')
        local priority=$(echo "$task" | jq -r '.priority')
        local due=$(echo "$task" | jq -r '.due')
        local category=$(echo "$task" | jq -r '.category')
        local completed=$(echo "$task" | jq -r '.completed')

        # Apply priority filter
        if [[ -n "$priority_filter" && "$priority" != "$priority_filter" ]]; then
            continue
        fi

        ((count++))

        # Color by priority
        local color="$NC"
        case $priority in
            high) color="$RED"; ((high_count++)) ;;
            medium) color="$YELLOW"; ((medium_count++)) ;;
            low) color="$GREEN"; ((low_count++)) ;;
        esac

        if [[ "$completed" == "true" ]]; then
            color="$NC"
            ((completed_count++))
            echo -e "  [✓] #$id $text"
        else
            echo -e "  [ ] #$id ${color}$text${NC}"
        fi

        [[ -n "$due" && "$due" != "null" ]] && echo "      📅 Due: $due"
        [[ -n "$category" && "$category" != "null" ]] && echo "      🏷️  Category: $category"
        echo "      Priority: $priority"
        echo ""
    done <<< "$tasks"

    echo -e "${BLUE}=== Summary ===${NC}"
    echo "Total: $count | High: $high_count | Medium: $medium_count | Low: $low_count | Completed: $completed_count"
}

# Complete a task
cmd_done() {
    init

    local task_id=$1

    if [[ -z "$task_id" ]]; then
        echo -e "${RED}Error: Task ID required${NC}"
        echo "Usage: todo done <task_id>"
        exit 1
    fi

    local completed_at=$(date +%Y-%m-%d)

    local temp_file=$(mktemp)
    if jq --argjson id "$task_id" --arg date "$completed_at" \
        'map(if .id == $id then .completed = true | .completed_at = $date else . end)' \
        "${TODO_FILE}" > "$temp_file"; then
        mv "$temp_file" "${TODO_FILE}"
        echo -e "${GREEN}✓${NC} Task #$task_id marked as completed"
    else
        rm "$temp_file"
        echo -e "${RED}Error: Task #$task_id not found${NC}"
        exit 1
    fi
}

# Delete a task
cmd_delete() {
    init

    local task_id=$1

    if [[ -z "$task_id" ]]; then
        echo -e "${RED}Error: Task ID required${NC}"
        echo "Usage: todo delete <task_id>"
        exit 1
    fi

    local temp_file=$(mktemp)
    if jq --argjson id "$task_id" 'map(select(.id != $id))' \
        "${TODO_FILE}" > "$temp_file"; then
        mv "$temp_file" "${TODO_FILE}"
        echo -e "${GREEN}✓${NC} Task #$task_id deleted"
    else
        rm "$temp_file"
        echo -e "${RED}Error: Task #$task_id not found${NC}"
        exit 1
    fi
}

# Show statistics
cmd_stats() {
    init

    local total=$(jq '. | length' "${TODO_FILE}")
    local completed=$(jq '[.[] | select(.completed == true)] | length' "${TODO_FILE}")
    local pending=$((total - completed))

    local high=$(jq '[.[] | select(.priority == "high" and .completed == false)] | length' "${TODO_FILE}")
    local medium=$(jq '[.[] | select(.priority == "medium" and .completed == false)] | length' "${TODO_FILE}")
    local low=$(jq '[.[] | select(.priority == "low" and .completed == false)] | length' "${TODO_FILE}")

    echo -e "${BLUE}=== Todo Statistics ===${NC}"
    echo "Total tasks: $total"
    echo "Completed: $completed"
    echo "Pending: $pending"
    echo ""
    echo "Pending by priority:"
    echo "  🔴 High:   $high"
    echo "  🟡 Medium: $medium"
    echo "  🟢 Low:    $low"

    # Due soon
    local today=$(date +%Y-%m-%d)
    local due_soon=$(jq --arg today "$today" '[.[] | select(.due != null and .due >= $today and .completed == false)] | length' "${TODO_FILE}")
    local overdue=$(jq --arg today "$today" '[.[] | select(.due != null and .due < $today and .completed == false)] | length' "${TODO_FILE}")

    echo ""
    echo "Due date status:"
    echo "  Due soon: $due_soon"
    echo "  Overdue:  $overdue"
}

# Main
main() {
    init

    if [[ $# -eq 0 ]]; then
        cmd_list
        exit 0
    fi

    local command=$1
    shift

    case $command in
        add|a)
            cmd_add "$@"
            ;;
        list|ls|l)
            cmd_list "$@"
            ;;
        done|complete|c)
            cmd_done "$@"
            ;;
        delete|rm|d)
            cmd_delete "$@"
            ;;
        stats|report)
            cmd_stats "$@"
            ;;
        help|--help|-h)
            echo "Todo Manager - Task management CLI tool"
            echo ""
            echo "Usage:"
            echo "  todo add <task> [-p priority] [-d due] [-c category]"
            echo "  todo list [--pending|--completed] [--priority level] [--json]"
            echo "  todo done <task_id>"
            echo "  todo delete <task_id>"
            echo "  todo stats"
            echo ""
            echo "Examples:"
            echo "  todo add 'Finish report' -p high -d 2026-03-10"
            echo "  todo list --pending --priority high"
            echo "  todo done 1"
            echo "  todo stats"
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            echo "Use 'todo help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
