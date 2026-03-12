# Task Queue Manager Skill

A powerful task queue management tool for background job processing, supporting multiple backends (Redis, RabbitMQ-like in-memory, file-based).

## Features

- **Multiple Backends**: Redis, in-memory, file-based queues
- **Job Management**: Enqueue, dequeue, retry, priority, delayed jobs
- **Worker Management**: Start/stop/status workers
- **Job Scheduling**: Cron-like scheduled jobs
- **Monitoring**: Queue stats, job history,失败重试

## Commands

```bash
# Queue operations
enqueue <queue> <payload>        # Add job to queue (JSON or text)
dequeue <queue>                   # Get next job from queue
list-queues                       # List all queues
queue-stats <queue>              # Show queue statistics
clear-queue <queue>              # Clear all jobs in queue

# Job operations
job-status <job-id>               # Check job status
job-retry <job-id>               # Retry failed job
job-cancel <job-id>              # Cancel pending job
job-list <queue>                 # List jobs in queue

# Worker operations
worker-start <queue> [--workers=N] # Start workers
worker-stop                       # Stop all workers
worker-status                     # Show worker status
worker-logs                       # Show worker logs

# Scheduled jobs
schedule add <name> <cron> <job> # Add scheduled job
schedule list                     # List scheduled jobs
schedule remove <name>           # Remove scheduled job
schedule enable <name>           # Enable scheduled job
schedule disable <name>          # Disable scheduled job

# Priority jobs
enqueue-priority <queue> <payload> # High priority job

# Delayed jobs
enqueue-delay <queue> <delay-secs> <payload> # Delayed job
```

## Quick Start

```bash
# Add a job
task-queue enqueue emails '{"to":"user@example.com","subject":"Hello"}'

# Process jobs (with 3 workers)
task-queue worker-start emails --workers=3

# Check status
task-queue queue-stats emails

# Schedule a job
task-queue schedule add backup "0 2 * * *" '{"cmd":"backup-db"}'
```

## Priority Levels

- `high` - Critical jobs (processed first)
- `normal` - Default priority
- `low` - Background jobs

## Job Status

- `pending` - Waiting in queue
- `processing` - Currently being worked on
- `completed` - Successfully finished
- `failed` - Failed (will be retried)
- `cancelled` - Manually cancelled

## Configuration

Config file: `~/.config/task-queue/config.json`

```json
{
  "backend": "redis",
  "redis": {
    "host": "localhost",
    "port": 6379
  },
  "defaults": {
    "max-retries": 3,
    "retry-delay": 60,
    "timeout": 300
  }
}
```

## Use Cases

- Email sending queue
- Image processing
- Webhook delivery
- Report generation
- Database cleanup
- Backup jobs

## Resume Keywords

- Background job processing
- Redis/MQ experience
- Distributed systems
- Async task management
- Worker pool design
- Job scheduling (cron)
