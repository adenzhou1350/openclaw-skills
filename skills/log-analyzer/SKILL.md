# Log Analyzer Skill

AI-powered log analysis tool for debugging and monitoring.

## Features

- Real-time log monitoring with pattern detection
- Error/warning/fatal level filtering
- Timestamp parsing and correlation
- JSON log parsing and visualization
- Pattern matching with regex
- Statistical analysis (error rate, response times)
- Export reports in multiple formats

## Commands

| Command | Description |
|---------|-------------|
| `analyze <file>` | Analyze log file and show summary |
| `monitor <file>` | Monitor log file in real-time |
| `errors <file>` | Show only error-level entries |
| `search <pattern> <file>` | Search for pattern in logs |
| `stats <file>` | Show log statistics |
| `export <file> <format>` | Export to json/csv/html |
| `tail <file> <lines>` | Show last N lines |
| `follow <file>` | Follow log in real-time |

## Usage Examples

```bash
# Analyze a log file
log-analyzer analyze /var/log/app.log

# Show only errors
log-analyzer errors /var/log/app.log

# Search for specific pattern
log-analyzer search "Exception" /var/log/app.log

# Show statistics
log-analyzer stats /var/log/app.log

# Monitor in real-time
log-analyzer monitor /var/log/app.log
```

## Installation

```bash
chmod +x log-analyzer.sh
sudo ln -s $(pwd)/log-analyzer.sh /usr/local/bin/log-analyzer
```

## Output Examples

### Analysis Summary
```
File: /var/log/app.log
Total lines: 10,000
Date range: 2026-03-01 to 2026-03-04

Levels:
  ERROR: 150 (1.5%)
  WARN:  320 (3.2%)
  INFO:  8,530 (85.3%)

Top errors:
  1. Connection timeout (45)
  2. Null pointer (30)
  3. Auth failed (25)
```

### Real-time Monitor
```
[2026-03-04 10:30:15] INFO  - Server started on port 8080
[2026-03-04 10:30:16] WARN  - Slow query detected (2.5s)
[2026-03-04 10:30:17] ERROR - Connection refused to database
```
