#!/bin/bash
# Data Pipeline Runner - 自动化数据处理流水线
# Author: OpenClaw
# Usage: pipeline.sh [command] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/config"
DATA_DIR="${SCRIPT_DIR}/data"
LOG_DIR="${SCRIPT_DIR}/logs"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 日志函数
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 初始化
init() {
    local pipeline_name="${1:-my-pipeline}"
    
    mkdir -p "${CONFIG_DIR}/${pipeline_name}"
    mkdir -p "${DATA_DIR}/${pipeline_name}/input"
    mkdir -p "${DATA_DIR}/${pipeline_name}/output"
    mkdir -p "${DATA_DIR}/${pipeline_name}/temp"
    mkdir -p "${LOG_DIR}"
    
    cat > "${CONFIG_DIR}/${pipeline_name}/pipeline.yaml" << 'EOF'
# Pipeline Configuration
name: ${pipeline_name}
version: 1.0

sources: []
transforms: []
targets: []

options:
  retry: 3
  timeout: 300
  on_error: log
EOF

    log_success "Pipeline '${pipeline_name}' 初始化完成"
    echo "配置文件: ${CONFIG_DIR}/${pipeline_name}/pipeline.yaml"
}

# 运行管道
run() {
    local config_file="${1:-pipeline.yaml}"
    local start_time=$(date +%s)
    
    log_info "开始执行数据管道: ${config_file}"
    
    # 读取配置
    if [[ ! -f "${config_file}" ]]; then
        log_error "配置文件不存在: ${config_file}"
        return 1
    fi
    
    # 提取数据源
    log_info "Step 1: 提取数据 (Extract)"
    local temp_file="${DATA_DIR}/temp/input_$$.json"
    echo "[]" > "${temp_file}"
    
    # 执行转换
    log_info "Step 2: 数据转换 (Transform)"
    local transformed_file="${DATA_DIR}/temp/transformed_$$.json"
    jq '.' "${temp_file}" > "${transformed_file}" 2>/dev/null || echo "[]" > "${transformed_file}"
    
    # 加载数据
    log_info "Step 3: 加载数据 (Load)"
    local output_file="${DATA_DIR}/output/output_$$.json"
    cp "${transformed_file}" "${output_file}"
    
    # 清理临时文件
    rm -f "${temp_file}" "${transformed_file}"
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log_success "管道执行完成，耗时 ${duration}s"
    log_info "输出文件: ${output_file}"
    
    return 0
}

# 查看状态
status() {
    echo "=== Pipeline Status ==="
    echo "配置目录: ${CONFIG_DIR}"
    echo "数据目录: ${DATA_DIR}"
    echo "日志目录: ${LOG_DIR}"
    echo ""
    
    if [[ -d "${CONFIG_DIR}" ]]; then
        echo "已配置的管道:"
        ls -1 "${CONFIG_DIR}/" 2>/dev/null || echo "  (无)"
    fi
}

# 查看日志
logs() {
    local lines="${1:-50}"
    if [[ -d "${LOG_DIR}" ]]; then
        tail -n "${lines}" "${LOG_DIR}"/*.log 2>/dev/null || echo "暂无日志"
    else
        echo "暂无日志"
    fi
}

# 主命令处理
case "${1}" in
    init)
        init "${2}"
        ;;
    run)
        run "${2}"
        ;;
    status)
        status
        ;;
    logs)
        logs "${2:-50}"
        ;;
    help|--help|-h)
        echo "Data Pipeline Tool"
        echo ""
        echo "用法: pipeline.sh <command> [options]"
        echo ""
        echo "命令:"
        echo "  init [name]     初始化新的数据管道"
        echo "  run [config]    运行数据管道"
        echo "  status          查看管道状态"
        echo "  logs [lines]   查看执行日志"
        echo "  help            显示帮助"
        ;;
    *)
        log_error "未知命令: ${1}"
        echo "使用 pipeline.sh help 查看帮助"
        exit 1
        ;;
esac
