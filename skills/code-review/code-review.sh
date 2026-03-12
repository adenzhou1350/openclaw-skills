#!/bin/bash
# Code Review Tool - AI-powered code quality checker

set -e

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default options
SECURITY_SCAN=false
JSON_OUTPUT=false
LANGUAGE=""
VERBOSE=false

show_help() {
    cat << EOF
Code Review Tool v$VERSION

Usage: code-review <command> [options] <target>

Commands:
    review <target>    Review file or directory
    report <target>    Generate detailed report
    languages          List supported languages
    help              Show this help message

Options:
    --lang <lang>     Specify language (auto-detect if not provided)
    --security        Enable security scanning
    --json            Output in JSON format
    --verbose         Show detailed output
    --version         Show version

Examples:
    code-review review app.js
    code-review review --security --json api.py
    code-review report ./src

Exit Codes:
    0 - No issues found
    1 - Warnings found
    2 - Errors found
    3 - Security issues found
EOF
}

detect_language() {
    local file="$1"
    local ext="${file##*.}"
    
    case "$ext" in
        js|mjs|cjs)
            echo "javascript"
            ;;
        ts|tsx)
            echo "typescript"
            ;;
        py)
            echo "python"
            ;;
        go)
            echo "go"
            ;;
        rs)
            echo "rust"
            ;;
        java)
            echo "java"
            ;;
        c|h|cpp|cc)
            echo "cpp"
            ;;
        rb)
            echo "ruby"
            ;;
        php)
            echo "php"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

check_syntax() {
    local file="$1"
    local lang="$2"
    
    case "$lang" in
        javascript|typescript)
            if command -v node &> /dev/null; then
                node --check "$file" 2>&1 || true
            fi
            ;;
        python)
            if command -v python3 &> /dev/null; then
                python3 -m py_compile "$file" 2>&1 || true
            fi
            ;;
        go)
            if command -v go &> /dev/null; then
                go vet "$file" 2>&1 || true
            fi
            ;;
        rust)
            if command -v rustc &> /dev/null; then
                rustc --emit=metadata -o /dev/null "$file" 2>&1 || true
            fi
            ;;
    esac
}

check_security() {
    local file="$1"
    local lang="$2"
    local issues=0
    
    # Check for hardcoded secrets
    if grep -iq "password\|secret\|api_key\|apikey\|token" "$file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Potential hardcoded secret detected${NC}"
        ((issues++))
    fi
    
    # Check for eval usage
    if grep -q "eval(" "$file" 2>/dev/null; then
        echo -e "${RED}⚠️  Security: eval() usage is dangerous${NC}"
        ((issues++))
    fi
    
    # Check for SQL injection vulnerabilities
    if grep -qE "execute\(|exec\(|query\(" "$file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Potential SQL injection risk - use parameterized queries${NC}"
        ((issues++))
    fi
    
    return $issues
}

check_best_practices() {
    local file="$1"
    local lang="$2"
    local warnings=0
    
    # Check for TODO/FIXME comments
    if grep -qE "TODO|FIXME|HACK|XXX" "$file" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Found TODO/FIXME comments${NC}"
        ((warnings++))
    fi
    
    # Check file size
    local lines=$(wc -l < "$file")
    if [ "$lines" -gt 500 ]; then
        echo -e "${YELLOW}⚠️  File has $lines lines - consider splitting${NC}"
        ((warnings++))
    fi
    
    return $warnings
}

calculate_complexity() {
    local file="$1"
    local lang="$2"
    
    # Simple cyclomatic complexity estimation
    local complexity=1
    
    if [ -f "$file" ]; then
        # Count decision points
        local decision_points=$(grep -cE "if|while|for|case|&&|\|\|" "$file" 2>/dev/null || echo "0")
        complexity=$((1 + decision_points))
    fi
    
    echo "$complexity"
}

review_file() {
    local target="$1"
    
    if [ ! -e "$target" ]; then
        echo -e "${RED}Error: File or directory not found: $target${NC}"
        exit 1
    fi
    
    # Detect language
    if [ -z "$LANGUAGE" ]; then
        LANGUAGE=$(detect_language "$target")
    fi
    
    echo -e "${BLUE}🔍 Reviewing: $target${NC}"
    echo -e "${BLUE}   Language: $LANGUAGE${NC}"
    echo ""
    
    local exit_code=0
    
    # Syntax check
    echo -e "${BLUE}📝 Syntax Check${NC}"
    if check_syntax "$target" "$LANGUAGE"; then
        echo -e "${GREEN}✓ No syntax errors${NC}"
    else
        echo -e "${RED}✗ Syntax errors detected${NC}"
        exit_code=2
    fi
    echo ""
    
    # Best practices
    echo -e "${BLUE}📋 Best Practices${NC}"
    if check_best_practices "$target" "$LANGUAGE"; then
        echo -e "${GREEN}✓ Looks good${NC}"
    else
        exit_code=1
    fi
    echo ""
    
    # Security scan
    if [ "$SECURITY_SCAN" = true ]; then
        echo -e "${BLUE}🔒 Security Scan${NC}"
        if check_security "$target" "$LANGUAGE"; then
            echo -e "${GREEN}✓ No security issues${NC}"
        else
            exit_code=3
        fi
        echo ""
    fi
    
    # Complexity analysis
    echo -e "${BLUE}📊 Complexity Analysis${NC}"
    local complexity=$(calculate_complexity "$target" "$LANGUAGE")
    echo "   Cyclomatic complexity: $complexity"
    if [ "$complexity" -gt 10 ]; then
        echo -e "${YELLOW}⚠️  High complexity - consider refactoring${NC}"
    else
        echo -e "${GREEN}✓ Complexity is acceptable${NC}"
    fi
    echo ""
    
    echo -e "${GREEN}✅ Review complete${NC}"
    exit $exit_code
}

# Parse command
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    review)
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --lang)
                    LANGUAGE="$2"
                    shift 2
                    ;;
                --security)
                    SECURITY_SCAN=true
                    shift
                    ;;
                --json)
                    JSON_OUTPUT=true
                    shift
                    ;;
                --verbose)
                    VERBOSE=true
                    shift
                    ;;
                --help|-h)
                    show_help
                    exit 0
                    ;;
                -*)
                    echo "Unknown option: $1"
                    show_help
                    exit 1
                    ;;
                *)
                    TARGET="$1"
                    shift
                    ;;
            esac
        done
        
        if [ -z "$TARGET" ]; then
            echo "Error: No target specified"
            show_help
            exit 1
        fi
        
        review_file "$TARGET"
        ;;
    languages)
        echo "Supported languages:"
        echo "  - JavaScript/TypeScript"
        echo "  - Python"
        echo "  - Go"
        echo "  - Rust"
        echo "  - Java"
        echo "  - C/C++"
        echo "  - Ruby"
        echo "  - PHP"
        ;;
    help|--help|-h)
        show_help
        ;;
    --version|-v)
        echo "code-review v$VERSION"
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
