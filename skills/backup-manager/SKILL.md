# Backup Manager Skill

文件和数据库备份管理工具。

## 功能

- **backup**: 备份文件或目录
- **restore**: 恢复备份
- **list**: 列出可用备份
- **schedule**: 设置定时备份
- **verify**: 验证备份完整性
- **clean**: 清理旧备份

## 使用方法

```bash
backup-manager <command> [options]
```

## 命令

### backup
创建备份。

```bash
backup-manager backup <source> [destination]
# 示例
backup-manager backup /home/user/data
backup-manager backup /home/user/data /backup/my-backup.tar.gz
backup-manager backup mysql mydb /backup/mydb.sql
```

### restore
恢复备份。

```bash
backup-manager restore <backup-file> [destination]
# 示例
backup-manager restore /backup/my-backup.tar.gz
backup-manager restore /backup/mydb.sql mysql
```

### list
列出可用备份。

```bash
backup-manager list [path]
# 示例
backup-manager list
backup-manager list /backup
```

### schedule
设置定时备份（使用 cron）。

```bash
backup-manager schedule <source> <destination> <schedule>
# 示例
backup-manager schedule /data /backup/daily "0 2 * * *"
backup-manager schedule /home /backup/home-weekly "0 3 * * 0"
```

### verify
验证备份完整性。

```bash
backup-manager verify <backup-file>
# 示例
backup-manager verify /backup/my-backup.tar.gz
```

### clean
清理旧备份。

```bash
backup-manager clean <path> [days]
# 示例
backup-manager clean /backup 30
```

## 示例输出

```
$ backup-manager backup /home/user/documents
[INFO] 创建备份: /home/user/documents
[INFO] 目标: /backup/documents_20240304_110000.tar.gz
[INFO] 备份完成! (大小: 15.2 MB)

$ backup-manager list
备份列表: /backup
========================
documents_20240304_110000.tar.gz    15.2 MB   2024-03-04 11:00
documents_20240303_110000.tar.gz    14.8 MB   2024-03-03 11:00
documents_20240302_110000.tar.gz    14.5 MB   2024-03-02 11:00
```

## 简历亮点

- 备份策略设计
- 运维自动化
- 数据安全意识
- Shell 脚本开发
- 定时任务管理
