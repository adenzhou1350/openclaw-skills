# Todo Manager Skill

A command-line todo list manager for tracking tasks and priorities.

## Features

- Add, list, complete, and delete tasks
- Priority levels (high, medium, low)
- Due date support
- Categories/tags
- Persistent storage
- JSON output for integration

## Commands

### Add a task
```bash
todo add "Finish project report" --priority high --due 2026-03-10
```

### List tasks
```bash
todo list
todo list --pending
todo list --completed
todo list --priority high
```

### Complete a task
```bash
todo done <task_id>
```

### Delete a task
```bash
todo delete <task_id>
```

### Show stats
```bash
todo stats
```

## Options

- `--priority, -p`: Priority level (high/medium/low)
- `--due, -d`: Due date (YYYY-MM-DD)
- `--category, -c`: Category or tag
- `--json`: Output in JSON format
- `--help, -h`: Show help

## Storage

Tasks are stored in `~/.openclaw/data/todos.json`

## Examples

```bash
# Add high priority task
todo add "Review PR #42" -p high

# Add task with due date
todo add "Submit report" -d 2026-03-15 -p medium

# List all pending tasks
todo list --pending

# Complete task
todo done 1

# Show statistics
todo stats
```

## Exit Codes

- 0: Success
- 1: Error (invalid arguments, file not found, etc.)
