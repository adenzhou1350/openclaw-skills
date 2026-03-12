# Code Review Skill

AI-powered code review tool for automated code quality checks.

## Features

- **Syntax Check**: Detect syntax errors in multiple languages
- **Security Scan**: Identify common security vulnerabilities
- **Best Practices**: Suggest improvements based on coding standards
- **Complexity Analysis**: Calculate cyclomatic complexity
- **Comment Analysis**: Check for adequate documentation

## Usage

```bash
# Review a file
code-review review <file>

# Review a directory
code-review review ./src

# Check specific language
code-review review --lang python <file>

# Enable security scanning
code-review review --security <file>

# Output in JSON format
code-review review --json <file>

# Show detailed report
code-review report <file>
```

## Supported Languages

- JavaScript/TypeScript
- Python
- Go
- Rust
- Java
- C/C++
- Ruby
- PHP

## Exit Codes

- 0: No issues found
- 1: Warnings found
- 2: Errors found
- 3: Security issues found

## Examples

```bash
# Basic review
code-review review app.js

# Security-focused review
code-review review --security --json api.go

# Full report
code-review report ./src
```
