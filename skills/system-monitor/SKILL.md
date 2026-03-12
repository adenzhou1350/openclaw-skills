# System Monitor Skill

实时系统监控和性能分析工具。

## 功能

- **overview**: 系统概览（CPU、内存、磁盘、网络）
- **cpu**: CPU 使用率和核心信息
- **memory**: 内存使用详情
- **disk**: 磁盘使用情况
- **network**: 网络接口统计
- **process**: 进程信息
- **top**: Top 进程（类似 htop）
- **watch**: 实时监控模式

## 使用方法

```bash
system-monitor <command> [options]
```

## 命令

### overview
显示系统概览。

```bash
system-monitor overview
```

### cpu
显示 CPU 详细信息。

```bash
system-monitor cpu
```

### memory
显示内存使用详情。

```bash
system-monitor memory
```

### disk
显示磁盘使用情况。

```bash
system-monitor disk
```

### network
显示网络接口统计。

```bash
system-monitor network
```

### process
显示进程信息。

```bash
system-monitor process [sort] [limit]
# sort: cpu, memory, pid
# 示例
system-monitor process cpu 10
system-monitor process memory 20
```

### top
显示资源占用最高的进程。

```bash
system-monitor top [count]
# 示例
system-monitor top 15
```

### watch
实时监控模式（按 Ctrl+C 退出）。

```bash
system-monitor watch [interval]
# 示例
system-monitor watch 2
```

## 示例输出

```
$ system-monitor overview
╔═══════════════════════════════════════════════════════╗
║              System Overview                          ║
╠═══════════════════════════════════════════════════════╣
║ Hostname:     server-01                               ║
║ Uptime:       15 days, 3 hours                        ║
║ Load Avg:     0.52, 0.48, 0.45                       ║
╠═══════════════════════════════════════════════════════╣
║ CPU:          12.5% used (8 cores)                   ║
║ Memory:       4.2GB / 16GB (26.3%)                   ║
║ Disk:         45.2GB / 500GB (9.0%)                  ║
║ Network:      ↓ 1.2MB  ↑ 0.3MB                       ║
╚═══════════════════════════════════════════════════════╝
```

## 简历亮点

- 系统管理能力
- 性能优化能力
- Shell 脚本开发
- 运维自动化
