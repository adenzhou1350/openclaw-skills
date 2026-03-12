#!/bin/bash

# Backup Manager - 文件和数据库备份管理工具
# 作者: OpenClaw Agent
# 功能: 备份、恢复、列表、定时、验证、清理

set -e

VERSION="1.0.0"
BACKUP_DIR="${BACKUP_DIR:-/backup}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_version() {
    echo "backup-manager v$VERSION"
}

print_help() {
    echo "Backup Manager - 文件和数据库备份管理工具"
    echo ""
    echo "用法: backup-manager <command> [options]"
    echo ""
    echo "命令:"
    echo "  backup <source> [dest]     创建备份"
    echo "  restore <backup> [dest]    恢复备份"
    echo "  list [path]                列出备份"
    echo "  schedule <src> <dst> <cron> 设置定时备份"
    echo "  verify <backup>            验证备份"
    echo "  clean <path> [days]        清理旧备份"
    echo ""
    echo "选项:"
    echo "  --help     显示帮助"
    echo "  --version  显示版本"
    echo ""
    echo "环境变量:"
    echo "  BACKUP_DIR    默认备份目录 (默认: /backup)"
}

ensure_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_info "创建备份目录: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

get_timestamp() {
    date +"%Y%m%d_%H%M%S"
}

get_date() {
    date +"%Y-%m-%d %H:%M"
}

cmd_backup() {
    local source="$1"
    local dest="$2"
    
    if [[ -z "$source" ]]; then
        log_error "请指定要备份的源路径"
        echo "用法: backup-manager backup <source> [destination]"
        exit 1
    fi
    
    # 检查源路径是否存在
    if [[ ! -e "$source" ]]; then
        log_error "源路径不存在: $source"
        exit 1
    fi
    
    # 如果是 mysql 备份
    if [[ "$source" == "mysql" ]]; then
        local db_name="$2"
        local db_dest="$3"
        
        if [[ -z "$db_name" ]]; then
            log_error "请指定数据库名"
            echo "用法: backup-manager backup mysql <database> [destination]"
            exit 1
        fi
        
        local backup_file="${db_dest:-$BACKUP_DIR/${db_name}_$(get_timestamp).sql}"
        
        log_info "备份 MySQL 数据库: $db_name"
        log_info "目标: $backup_file"
        
        if mysqldump "$db_name" > "$backup_file" 2>/dev/null; then
            local size
            size=$(du -h "$backup_file" | cut -f1)
            log_success "备份完成! (大小: $size)"
        else
            log_error "MySQL 备份失败 (请检查数据库连接)"
            exit 1
        fi
        return 0
    fi
    
    ensure_backup_dir
    
    # 确定备份文件名
    local basename
    basename=$(basename "$source")
    local backup_file
    
    if [[ -n "$dest" ]]; then
        backup_file="$dest"
    else
        backup_file="$BACKUP_DIR/${basename}_$(get_timestamp).tar.gz"
    fi
    
    log_info "创建备份: $source"
    log_info "目标: $backup_file"
    
    # 创建备份
    if [[ -d "$source" ]]; then
        tar -czf "$backup_file" -C "$(dirname "$source")" "$(basename "$source")"
    else
        gzip -c "$source" > "$backup_file"
    fi
    
    if [[ -f "$backup_file" ]]; then
        local size
        size=$(du -h "$backup_file" | cut -f1)
        log_success "备份完成! (大小: $size)"
    else
        log_error "备份失败"
        exit 1
    fi
}

cmd_restore() {
    local backup_file="$1"
    local dest="$2"
    
    if [[ -z "$backup_file" ]]; then
        log_error "请指定备份文件"
        echo "用法: backup-manager restore <backup-file> [destination]"
        exit 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "备份文件不存在: $backup_file"
        exit 1
    fi
    
    # 如果是 mysql 恢复
    if [[ "$backup_file" == *.sql ]]; then
        local db_name="${dest:-mysql}"
        
        log_info "恢复 MySQL 数据库: $db_name"
        log_info "来源: $backup_file"
        
        if mysql "$db_name" < "$backup_file" 2>/dev/null; then
            log_success "数据库恢复完成!"
        else
            log_error "数据库恢复失败 (请检查数据库连接)"
            exit 1
        fi
        return 0
    fi
    
    # 文件恢复
    local restore_dir="${dest:-$(dirname "$backup_file")/restore}"
    
    log_info "恢复备份: $backup_file"
    log_info "目标: $restore_dir"
    
    mkdir -p "$restore_dir"
    
    if [[ "$backup_file" == *.tar.gz ]]; then
        tar -xzf "$backup_file" -C "$restore_dir"
    elif [[ "$backup_file" == *.gz ]]; then
        gunzip -c "$backup_file" > "$restore_dir/$(basename "$backup_file" .gz)"
    else
        cp "$backup_file" "$restore_dir/"
    fi
    
    log_success "恢复完成!"
}

cmd_list() {
    local path="${1:-$BACKUP_DIR}"
    
    if [[ ! -d "$path" ]]; then
        log_error "目录不存在: $path"
        exit 1
    fi
    
    echo -e "${BLUE}备份列表: $path${NC}"
    echo "========================"
    
    local count=0
    local total_size=0
    
    for file in "$path"/*; do
        if [[ -f "$file" ]]; then
            local size
            size=$(du -h "$file" | cut -f1)
            local date
            date=$(get_date -r "$file")
            local name
            name=$(basename "$file")
            
            printf "%-40s %10s   %s\n" "$name" "$size" "$date"
            
            ((count++))
        fi
    done
    
    echo ""
    echo "总计: $count 个备份"
}

cmd_schedule() {
    local source="$1"
    local dest="$2"
    local schedule="$3"
    
    if [[ -z "$source" || -z "$dest" || -z "$schedule" ]]; then
        log_error "参数不完整"
        echo "用法: backup-manager schedule <source> <destination> <cron>"
        echo "示例: backup-manager schedule /data /backup/daily '0 2 * * *'"
        exit 1
    fi
    
    ensure_backup_dir
    
    # 创建备份脚本
    local script_name="backup_$(basename "$source")_$(date +%s).sh"
    local script_path="/etc/cron.daily/$script_name"
    
    cat > "$script_path" << EOF
#!/bin/bash
backup-manager backup "$source" "$dest"
EOF
    
    chmod +x "$script_path"
    
    # 添加 cron 任务
    (crontab -l 2>/dev/null | grep -v "$script_path"; echo "$schedule $script_path") | crontab -
    
    log_success "定时备份已设置!"
    log_info "备份源: $source"
    log_info "备份目标: $dest"
    log_info "执行计划: $schedule"
}

cmd_verify() {
    local backup_file="$1"
    
    if [[ -z "$backup_file" ]]; then
        log_error "请指定备份文件"
        echo "用法: backup-manager verify <backup-file>"
        exit 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "备份文件不存在: $backup_file"
        exit 1
    fi
    
    log_info "验证备份: $backup_file"
    
    if [[ "$backup_file" == *.tar.gz ]]; then
        if tar -tzf "$backup_file" > /dev/null 2>&1; then
            log_success "备份文件完整!"
        else
            log_error "备份文件损坏!"
            exit 1
        fi
    elif [[ "$backup_file" == *.sql ]]; then
        if grep -q "Database:" "$backup_file" 2>/dev/null || [[ -s "$backup_file" ]]; then
            log_success "备份文件完整!"
        else
            log_error "备份文件可能损坏!"
            exit 1
        fi
    else
        if [[ -s "$backup_file" ]]; then
            log_success "备份文件完整!"
        else
            log_error "备份文件为空或损坏!"
            exit 1
        fi
    fi
    
    local size
    size=$(du -h "$backup_file" | cut -f1)
    echo -e "文件大小: $size"
}

cmd_clean() {
    local path="${1:-$BACKUP_DIR}"
    local days="${2:-30}"
    
    if [[ ! -d "$path" ]]; then
        log_error "目录不存在: $path"
        exit 1
    fi
    
    log_info "清理 $path 中 $days 天前的备份..."
    
    local count=0
    find "$path" -type f -mtime +"$days" -print0 | while read -r file; do
        rm -f "$file"
        log_info "删除: $(basename "$file")"
        ((count++))
    done
    
    log_success "已清理 $count 个旧备份"
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
        backup)
            shift
            cmd_backup "$@"
            ;;
        restore)
            shift
            cmd_restore "$@"
            ;;
        list)
            shift
            cmd_list "$@"
            ;;
        schedule)
            shift
            cmd_schedule "$@"
            ;;
        verify)
            shift
            cmd_verify "$@"
            ;;
        clean)
            shift
            cmd_clean "$@"
            ;;
        "")
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}未知命令: $command${NC}"
            echo "使用 backup-manager --help 查看帮助"
            exit 1
            ;;
    esac
}

main "$@"
