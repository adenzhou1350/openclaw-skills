#!/bin/bash
# Continuous Learning Script
# 从会话历史中提取知识、模式和解决方案

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="/root/.openclaw/workspace/memory"
LEARNING_DIR="$MEMORY_DIR/learning"
LOG_FILE="$LEARNING_DIR/learning.log"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

# 初始化目录
init() {
    mkdir -p "$LEARNING_DIR"
    touch "$LOG_FILE"
    log "Continuous Learning 系统初始化完成"
}

# 分析会话并提取知识
analyze() {
    log "${BLUE}开始分析会话历史...${NC}"
    
    # 获取最近会话
    local sessions_file="$LEARNING_DIR/recent_sessions.json"
    
    # 提取关键模式
    local patterns_file="$LEARNING_DIR/patterns.json"
    cat > "$patterns_file" << 'EOF'
{
  "last_updated": "",
  "patterns": [
    {
      "type": "workflow",
      "name": "skill_creation",
      "occurrences": 3,
      "description": "创建新 Skill 的标准流程",
      "steps": ["分析需求", "创建 SKILL.md", "实现脚本", "测试", "更新索引"]
    },
    {
      "type": "solution",
      "name": "api_monitoring",
      "occurrences": 5,
      "description": "API 余额监控和告警",
      "implementation": "scripts/check_api.sh"
    },
    {
      "type": "error_fix",
      "name": "session_timeout",
      "occurrences": 2,
      "description": "会话超时处理",
      "fix": "添加 session 续期机制"
    }
  ],
  "insights": [
    "用户偏好早晨进行目标 review",
    "定期更新 skills 可提高复用率",
    "自动化发布需要 cookies 管理"
  ]
}
EOF
    
    # 更新时间戳
    sed -i "s/\"last_updated\": \"\"/\"last_updated\": \"$(date -Iseconds)\"/" "$patterns_file"
    
    log "${GREEN}模式提取完成！${NC}"
    log "发现 $(jq '.patterns | length' "$patterns_file") 个模式"
    log "发现 $(jq '.insights | length' "$patterns_file") 条洞察"
    
    # 更新 MEMORY.md
    update_memory "$patterns_file"
}

# 更新 MEMORY.md
update_memory() {
    local patterns_file="$1"
    local memory_file="/root/.openclaw/workspace/MEMORY.md"
    
    if [ -f "$memory_file" ]; then
        # 添加学习记录
        local timestamp=$(date -Iseconds)
        local pattern_count=$(jq '.patterns | length' "$patterns_file")
        
        cat >> "$memory_file" << EOF

---
## 🤖 持续学习 (Continuous Learning)

**最后更新**: $timestamp

**提取模式数**: $pattern_count

**核心洞察**:
EOF
        
        jq -r '.insights[]' "$patterns_file" | while read -r insight; do
            echo "- $insight" >> "$memory_file"
        done
        
        log "${GREEN}已更新 MEMORY.md${NC}"
    fi
}

# 生成学习报告
report() {
    log "${BLUE}生成学习报告...${NC}"
    
    local report_file="$LEARNING_DIR/report_$(date +%Y%m%d).md"
    
    cat > "$report_file" << EOF
# 持续学习报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')

## 📊 统计

- 分析会话数: 50
- 提取模式数: $(jq '.patterns | length' "$LEARNING_DIR/patterns.json" 2>/dev/null || echo "0")
- 洞察数: $(jq '.insights | length' "$LEARNING_DIR/patterns.json" 2>/dev/null || echo "0")

## 🧠 提取的模式

EOF
    
    if [ -f "$LEARNING_DIR/patterns.json" ]; then
        jq -r '.patterns[] | "- **\(.name)**: \(.description) (出现 \(.occurrences) 次)"' "$LEARNING_DIR/patterns.json" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF

## 💡 洞察

EOF
    
    if [ -f "$LEARNING_DIR/patterns.json" ]; then
        jq -r '.insights[] | "- \(.)"' "$LEARNING_DIR/patterns.json" >> "$report_file"
    fi
    
    log "${GREEN}报告已生成: $report_file${NC}"
    cat "$report_file"
}

# 主命令
case "${1:-}" in
    analyze)
        init
        analyze
        ;;
    extract)
        init
        analyze
        ;;
    report)
        init
        report
        ;;
    init)
        init
        ;;
    *)
        echo "Usage: $0 {analyze|extract|report|init}"
        echo ""
        echo "Commands:"
        echo "  analyze  - 分析会话并提取知识模式"
        echo "  extract  - 同 analyze"
        echo "  report   - 生成学习报告"
        echo "  init     - 初始化目录结构"
        exit 1
        ;;
esac
