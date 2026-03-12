#!/bin/bash
# Verification Loop Script
# 任务验证系统，确保关键步骤正确执行

# 不使用 set -e 以避免验证失败时脚本退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFICATION_DIR="/root/.openclaw/workspace/memory/verification"
LOG_FILE="$VERIFICATION_DIR/verification.log"
REPORT_FILE="$VERIFICATION_DIR/report_$(date +%Y%m%d).json"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 统计
PASSED=0
FAILED=0
WARNINGS=0

log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

# 初始化
init() {
    mkdir -p "$VERIFICATION_DIR"
    touch "$LOG_FILE"
    log "Verification Loop 系统初始化完成"
}

# 验证文件
verify_file() {
    local path="$1"
    local expected_content="$2"
    
    log "验证文件: $path"
    
    if [ -f "$path" ]; then
        log "${GREEN}✓ 文件存在: $path${NC}"
        ((PASSED++))
        
        # 验证内容（如果指定）
        if [ -n "$expected_content" ]; then
            if grep -q "$expected_content" "$path"; then
                log "${GREEN}✓ 内容验证通过${NC}"
            else
                error "内容验证失败: 期望包含 '$expected_content'"
                ((FAILED++))
            fi
        fi
        return 0
    else
        error "文件不存在: $path"
        ((FAILED++))
        
        # 尝试创建
        if [ "$AUTO_FIX" = "true" ]; then
            warn "尝试创建文件..."
            touch "$path"
            log "${GREEN}✓ 文件已创建: $path${NC}"
        fi
        return 1
    fi
}

# 验证服务
verify_service() {
    local service="$1"
    
    log "验证服务: $service"
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        log "${GREEN}✓ 服务运行中: $service${NC}"
        ((PASSED++))
        return 0
    else
        error "服务未运行: $service"
        ((FAILED++))
        
        # 尝试启动
        if [ "$AUTO_FIX" = "true" ]; then
            warn "尝试启动服务..."
            if systemctl start "$service" 2>/dev/null; then
                log "${GREEN}✓ 服务已启动: $service${NC}"
            else
                error "无法启动服务: $service"
            fi
        fi
        return 1
    fi
}

# 验证端口
verify_port() {
    local port="$1"
    
    log "验证端口: $port"
    
    if ss -tuln 2>/dev/null | grep -q ":$port " || netstat -tuln 2>/dev/null | grep -q ":$port "; then
        log "${GREEN}✓ 端口开放: $port${NC}"
        ((PASSED++))
        return 0
    else
        warn "端口未开放: $port"
        ((WARNINGS++))
        return 1
    fi
}

# 验证 API
verify_api() {
    local endpoint="$1"
    local timeout="${2:-10}"
    
    log "验证 API: $endpoint"
    
    if curl -s --max-time "$timeout" -o /dev/null -w "%{http_code}" "$endpoint" | grep -q "^[23]"; then
        log "${GREEN}✓ API 可用: $endpoint${NC}"
        ((PASSED++))
        return 0
    else
        error "API 不可用: $endpoint"
        ((FAILED++))
        return 1
    fi
}

# 验证目录
verify_dir() {
    local path="$1"
    
    log "验证目录: $path"
    
    if [ -d "$path" ]; then
        log "${GREEN}✓ 目录存在: $path${NC}"
        ((PASSED++))
        return 0
    else
        error "目录不存在: $path"
        ((FAILED++))
        
        if [ "$AUTO_FIX" = "true" ]; then
            warn "尝试创建目录..."
            mkdir -p "$path"
            log "${GREEN}✓ 目录已创建: $path${NC}"
        fi
        return 1
    fi
}

# 完整验证
full_check() {
    init
    log "${BLUE}=== 开始完整验证 ===${NC}"
    
    # 验证关键目录
    verify_dir "/root/.openclaw/workspace"
    verify_dir "/root/.openclaw/workspace/skills"
    verify_dir "/root/.openclaw/workspace/memory"
    
    # 验证关键文件
    verify_file "/root/.openclaw/workspace/GOALS.md"
    verify_file "/root/.openclaw/workspace/SOUL.md"
    verify_file "/root/.openclaw/workspace/MEMORY.md"
    
    # 验证 skills
    local skills_count=$(ls -1 /root/.openclaw/workspace/skills/ 2>/dev/null | wc -l)
    log "Skills 数量: $skills_count"
    if [ "$skills_count" -ge 40 ]; then
        log "${GREEN}✓ Skills 数量充足: $skills_count${NC}"
        ((PASSED++))
    else
        warn "Skills 数量偏少: $skills_count"
        ((WARNINGS++))
    fi
    
    # 生成报告
    generate_report
    
    log "${BLUE}=== 验证完成 ===${NC}"
    log "通过: $PASSED | 失败: $FAILED | 警告: $WARNINGS"
}

# 生成报告
generate_report() {
    cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "summary": {
    "passed": $PASSED,
    "failed": $FAILED,
    "warnings": $WARNINGS
  },
  "status": "$([ $FAILED -eq 0 ] && echo "PASS" || echo "FAIL")"
}
EOF
    log "报告已生成: $REPORT_FILE"
}

# 主命令
AUTO_FIX="${AUTO_FIX:-true}"

case "${1:-}" in
    file)
        verify_file "$2" "$3"
        ;;
    service)
        verify_service "$2"
        ;;
    port)
        verify_port "$2"
        ;;
    api)
        verify_api "$2" "$3"
        ;;
    dir)
        verify_dir "$2"
        ;;
    full)
        full_check
        ;;
    init)
        init
        ;;
    *)
        echo "Usage: $0 {file|service|port|api|dir|full|init} [args...]"
        echo ""
        echo "Commands:"
        echo "  file <path> [content]  - 验证文件存在（可选验证内容）"
        echo "  service <name>        - 验证服务运行状态"
        echo "  port <port>           - 验证端口开放"
        echo "  api <endpoint> [sec]  - 验证 API 可用性"
        echo "  dir <path>            - 验证目录存在"
        echo "  full                  - 完整验证检查"
        echo "  init                  - 初始化"
        echo ""
        echo "Environment:"
        echo "  AUTO_FIX=true         - 自动尝试修复问题"
        exit 1
        ;;
esac
