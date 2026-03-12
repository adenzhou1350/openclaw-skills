# GitHub Trending Skill

Monitor and fetch daily GitHub trending repositories.

## Features

- Fetch trending repositories by language
- Filter by time range (daily, weekly, monthly)
- Support multiple programming languages
- Generate formatted digest report

## Usage

```bash
# Get today's trending repos
openclaw skill run github-trending

# Get Python repos trending this week
openclaw skill run github-trending --lang python --range weekly

# Get Go repos trending this month
openclaw skill run github-trending --lang go --range monthly
```

## Configuration

Create `config.json`:

```json
{
  "languages": ["python", "go", "rust", "typescript"],
  "range": "daily",
  "limit": 10,
  "notifyChannels": ["telegram", "wecom"]
}
```

## Output Format

```
📊 GitHub Trending - 今日热门

🔥 Python (Top 5)
1. awesome-python/awesome-python
   ⭐ 125k | 🔀 1.2k | 📝 Python 优质资源集
2. ...

🔥 Go (Top 5)
1. ...
```

## Cron Integration

Add to crontab for daily digest:

```bash
0 8 * * * openclaw skill run github-trending --notify
```
