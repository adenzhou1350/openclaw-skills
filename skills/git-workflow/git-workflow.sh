#!/bin/bash
# Git Workflow - Automation tool for Git development workflows

set -e

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default branches
MAIN_BRANCH="main"
DEVELOP_BRANCH="develop"

show_help() {
    cat << EOF
Git Workflow Tool v$VERSION

Usage: git-workflow <command> [options]

Commands:
    feature <action>    Manage feature branches
    release <action>   Manage release branches
    hotfix <action>    Manage hotfix branches
    changelog          Generate changelog
    version <action>  Version management
    cleanup            Clean up merged branches
    init               Initialize workflow in current repo

Feature Commands:
    feature start <name>     Create and switch to feature branch
    feature finish <name>    Merge feature and cleanup

Release Commands:
    release start <version> Create release branch
    release finish           Finish release

Hotfix Commands:
    hotfix start <name>      Create hotfix branch
    hotfix finish           Finish hotfix

Changelog Options:
    --since-tag <tag>       From tag
    --to-tag <tag>          To tag (default: HEAD)
    --format <format>       Output format (markdown, json)

Version Options:
    version bump <major|minor|patch>  Bump version
    version show                      Show current version

Examples:
    git-workflow feature start login
    git-workflow feature finish login
    git-workflow changelog --since-tag v1.0.0
    git-workflow version bump minor
    git-workflow cleanup --dry-run
EOF
}

check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed${NC}"
        exit 1
    fi
    
    if ! git rev-parse --git-dir &> /dev/null; then
        echo -e "${RED}Error: Not in a git repository${NC}"
        exit 1
    fi
}

get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

feature_start() {
    local feature_name="$1"
    
    if [ -z "$feature_name" ]; then
        echo -e "${RED}Error: Feature name required${NC}"
        exit 1
    fi
    
    check_git
    
    local branch_name="feature/$feature_name"
    
    echo -e "${BLUE}🚀 Starting feature: $feature_name${NC}"
    
    # Check if develop exists, otherwise use main
    if ! git rev-parse --verify "$DEVELOP_BRANCH" &> /dev/null; then
        DEVELOP_BRANCH="$MAIN_BRANCH"
    fi
    
    # Create branch from develop
    git checkout -b "$branch_name" "$DEVELOP_BRANCH" 2>/dev/null || {
        echo -e "${RED}Error: Branch $branch_name already exists${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✓ Created branch: $branch_name${NC}"
    echo -e "${CYAN}   Make your changes and run: git-workflow feature finish $feature_name${NC}"
}

feature_finish() {
    local feature_name="$1"
    
    if [ -z "$feature_name" ]; then
        echo -e "${RED}Error: Feature name required${NC}"
        exit 1
    fi
    
    check_git
    
    local branch_name="feature/$feature_name"
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" != "$branch_name" ]; then
        echo -e "${YELLOW}Warning: You're not on $branch_name${NC}"
    fi
    
    echo -e "${BLUE}🎯 Finishing feature: $feature_name${NC}"
    
    # Switch to develop
    git checkout "$DEVELOP_BRANCH"
    
    # Merge feature
    git merge --no-ff "$branch_name" -m "Merge feature/$feature_name"
    
    # Delete branch
    git branch -d "$branch_name"
    
    echo -e "${GREEN}✓ Feature merged and branch deleted${NC}"
}

release_start() {
    local version="$1"
    
    if [ -z "$version" ]; then
        echo -e "${RED}Error: Version required (e.g., 1.2.0)${NC}"
        exit 1
    fi
    
    check_git
    
    local branch_name="release/$version"
    
    echo -e "${BLUE}🚀 Starting release: v$version${NC}"
    
    # Check if develop exists
    if ! git rev-parse --verify "$DEVELOP_BRANCH" &> /dev/null; then
        DEVELOP_BRANCH="$MAIN_BRANCH"
    fi
    
    # Create branch
    git checkout -b "$branch_name" "$DEVELOP_BRANCH"
    
    echo -e "${GREEN}✓ Created release branch: $branch_name${NC}"
    echo -e "${CYAN}   Update version and run: git-workflow release finish${NC}"
}

release_finish() {
    check_git
    
    local current_branch=$(get_current_branch)
    
    if [[ ! "$current_branch" =~ ^release/ ]]; then
        echo -e "${RED}Error: Not on a release branch${NC}"
        exit 1
    fi
    
    local version="${current_branch#release/}"
    
    echo -e "${BLUE}🎯 Finishing release: v$version${NC}"
    
    # Merge to main
    git checkout "$MAIN_BRANCH"
    git merge --no-ff "$current_branch" -m "Release v$version"
    
    # Tag
    git tag -a "v$version" -m "Release v$version"
    
    # Merge to develop
    git checkout "$DEVELOP_BRANCH"
    git merge --no-ff "$current_branch" -m "Merge release v$version"
    
    # Delete release branch
    git branch -d "$current_branch"
    
    echo -e "${GREEN}✓ Release v$version completed${NC}"
    echo -e "${CYAN}   Pushed tags: git push --tags${NC}"
}

hotfix_start() {
    local hotfix_name="$1"
    
    if [ -z "$hotfix_name" ]; then
        echo -e "${RED}Error: Hotfix name required${NC}"
        exit 1
    fi
    
    check_git
    
    local branch_name="hotfix/$hotfix_name"
    
    echo -e "${BLUE}🔥 Starting hotfix: $hotfix_name${NC}"
    
    # Create branch from main
    git checkout -b "$branch_name" "$MAIN_BRANCH"
    
    echo -e "${GREEN}✓ Created hotfix branch: $branch_name${NC}"
}

hotfix_finish() {
    check_git
    
    local current_branch=$(get_current_branch)
    
    if [[ ! "$current_branch" =~ ^hotfix/ ]]; then
        echo -e "${RED}Error: Not on a hotfix branch${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🎯 Finishing hotfix${NC}"
    
    # Merge to main
    git checkout "$MAIN_BRANCH"
    git merge --no-ff "$current_branch"
    
    # Merge to develop
    git checkout "$DEVELOP_BRANCH"
    git merge --no-ff "$current_branch"
    
    # Delete branch
    git branch -d "$current_branch"
    
    echo -e "${GREEN}✓ Hotfix merged${NC}"
}

generate_changelog() {
    local from_tag=""
    local to_tag="HEAD"
    local format="markdown"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --since-tag)
                from_tag="$2"
                shift 2
                ;;
            --to-tag)
                to_tag="$2"
                shift 2
                ;;
            --format)
                format="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    check_git
    
    echo -e "${BLUE}📝 Generating changelog${NC}"
    
    if [ -z "$from_tag" ]; then
        # Get latest tag
        from_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
    fi
    
    local range=""
    if [ -n "$from_tag" ]; then
        range="$from_tag..$to_tag"
    fi
    
    if [ "$format" = "json" ]; then
        git log $range --pretty=format:'{"hash":"%h","date":"%ad","message":"%s","author":"%an"}' 2>/dev/null | \
        jq -s '.' 2>/dev/null || echo "[]"
    else
        echo "## Changelog"
        echo ""
        if [ -n "$from_tag" ]; then
            echo "*From $from_tag to $to_tag*"
            echo ""
        fi
        
        git log $range --pretty=format:"- %s (%h)" 2>/dev/null || echo "No commits found"
    fi
}

version_bump() {
    local bump_type="$1"
    
    if [ -z "$bump_type" ]; then
        echo -e "${RED}Error: Specify major, minor, or patch${NC}"
        exit 1
    fi
    
    check_git
    
    # Get current version tag
    local current_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
    local major=$(echo "$current_tag" | cut -d. -f1 | tr -d 'v')
    local minor=$(echo "$current_tag" | cut -d. -f2)
    local patch=$(echo "$current_tag" | cut -d. -f3)
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type. Use major, minor, or patch${NC}"
            exit 1
            ;;
    esac
    
    local new_version="v${major}.${minor}.${patch}"
    
    echo -e "${BLUE}🔖 Bumping version: $current_tag → $new_version${NC}"
    
    git tag -a "$new_version" -m "Version $new_version"
    
    echo -e "${GREEN}✓ Tagged: $new_version${NC}"
    echo -e "${CYAN}   Push: git push --tags${NC}"
}

version_show() {
    check_git
    local current_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "No tags")
    echo "Current version: $current_tag"
}

cleanup_branches() {
    local dry_run=false
    
    if [ "$1" = "--dry-run" ]; then
        dry_run=true
    fi
    
    check_git
    
    echo -e "${BLUE}🧹 Cleaning up merged branches${NC}"
    
    # Get merged branches (excluding main and develop)
    local branches=$(git branch --merged | grep -vE "^\*|main|develop|$MAIN_BRANCH|$DEVELOP_BRANCH" | sed 's/^[[:space:]]*//')
    
    if [ -z "$branches" ]; then
        echo -e "${GREEN}✓ No branches to clean up${NC}"
        return
    fi
    
    echo "Merged branches:"
    echo "$branches"
    echo ""
    
    if [ "$dry_run" = true ]; then
        echo -e "${YELLOW}Dry run - no branches will be deleted${NC}"
    else
        read -p "Delete these branches? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "$branches" | xargs -r git branch -d
            echo -e "${GREEN}✓ Branches deleted${NC}"
        fi
    fi
}

init_workflow() {
    check_git
    
    echo -e "${BLUE}⚙️  Initializing Git Workflow${NC}"
    
    # Create commit template
    mkdir -p ~/.git-template
    cat > ~/.git-template/commit-msg << 'EOF'
# <type>(<scope>): <subject>
#
# Types: feat, fix, docs, style, refactor, test, chore
#
# Example: feat(auth): add OAuth2 login
EOF
    
    # Configure git to use template
    git config --global init.templateDir ~/.git-template
    
    echo -e "${GREEN}✓ Git Workflow initialized${NC}"
    echo "  - Commit template created"
    echo "  - You're ready to use git-workflow commands"
}

# Main command parser
COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    feature)
        FEATURE_CMD="${1:-help}"
        shift
        
        case "$FEATURE_CMD" in
            start)
                feature_start "$@"
                ;;
            finish)
                feature_finish "$@"
                ;;
            *)
                echo "Usage: git-workflow feature <start|finish> <name>"
                exit 1
                ;;
        esac
        ;;
    release)
        RELEASE_CMD="${1:-help}"
        shift
        
        case "$RELEASE_CMD" in
            start)
                release_start "$@"
                ;;
            finish)
                release_finish
                ;;
            *)
                echo "Usage: git-workflow release <start|finish> [version]"
                exit 1
                ;;
        esac
        ;;
    hotfix)
        HOTFIX_CMD="${1:-help}"
        shift
        
        case "$HOTFIX_CMD" in
            start)
                hotfix_start "$@"
                ;;
            finish)
                hotfix_finish
                ;;
            *)
                echo "Usage: git-workflow hotfix <start|finish> <name>"
                exit 1
                ;;
        esac
        ;;
    changelog)
        generate_changelog "$@"
        ;;
    version)
        VERSION_CMD="${1:-help}"
        shift
        
        case "$VERSION_CMD" in
            bump)
                version_bump "$@"
                ;;
            show)
                version_show
                ;;
            *)
                echo "Usage: git-workflow version <bump|show>"
                exit 1
                ;;
        esac
        ;;
    cleanup)
        cleanup_branches "$@"
        ;;
    init)
        init_workflow
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac
