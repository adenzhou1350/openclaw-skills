#!/bin/bash
# API Documentation Generator
# 自动生成 API 文档

set -e

VERSION="1.0.0"
COMMAND=${1:-help}
PROJECT_DIR=${2:-.}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}📚 API Documentation Generator v${VERSION}${NC}"
    echo ""
}

print_help() {
    print_header
    echo "用法: apidoc <command> [options]"
    echo ""
    echo "命令:"
    echo "  help              显示帮助信息"
    echo "  init <dir>        初始化示例项目"
    echo "  generate <dir>    生成 API 文档"
    echo "  version           显示版本信息"
    echo ""
    echo "选项:"
    echo "  --format <type>   输出格式 (markdown/html), 默认 markdown"
    echo "  --output <dir>     输出目录, 默认 ./output"
    echo ""
    echo "示例:"
    echo "  apidoc init my-api"
    echo "  apidoc generate ./my-api --format markdown"
    echo "  apidoc generate ./my-api --format html --output ./docs"
}

init_example() {
    local dir=${1:-example}
    mkdir -p "$dir/routes" "$dir/models"
    
    cat > "$dir/routes/users.js" << 'EOF'
/**
 * @api {GET} /users 获取用户列表
 * @apiName GetUsers
 * @apiGroup User
 * @apiDescription 获取所有用户的列表
 * @apiSuccess {Array} users 用户数组
 * @apiSuccess {Number} users.id 用户ID
 * @apiSuccess {String} users.name 用户名
 * @apiSuccess {String} users.email 邮箱
 */

/**
 * @api {GET} /users/:id 获取单个用户
 * @apiName GetUser
 * @apiGroup User
 * @apiParam {Number} id 用户ID
 * @apiSuccess {Object} user 用户信息
 */

/**
 * @api {POST} /users 创建用户
 * @apiName CreateUser
 * @apiGroup User
 * @apiBody {String} name 用户名
 * @apiBody {String} email 邮箱
 * @apiSuccess {Object} user 创建的用户
 */

/**
 * @api {PUT} /users/:id 更新用户
 * @apiName UpdateUser
 * @apiGroup User
 * @apiParam {Number} id 用户ID
 * @apiBody {String} name 用户名
 * @apiBody {String} email 邮箱
 */

/**
 * @api {DELETE} /users/:id 删除用户
 * @apiName DeleteUser
 * @apiGroup User
 * @apiParam {Number} id 用户ID
 */
EOF

    cat > "$dir/routes/posts.js" << 'EOF'
/**
 * @api {GET} /posts 获取文章列表
 * @apiName GetPosts
 * @apiGroup Post
 * @apiDescription 获取所有文章的列表
 * @apiSuccess {Array} posts 文章数组
 */

/**
 * @api {GET} /posts/:id 获取单个文章
 * @apiName GetPost
 * @apiGroup Post
 * @apiParam {Number} id 文章ID
 */

/**
 * @api {POST} /posts 创建文章
 * @apiName CreatePost
 * @apiGroup Post
 * @apiBody {String} title 标题
 * @apiBody {String} content 内容
 * @apiBody {Number} authorId 作者ID
 */
EOF

    cat > "$dir/models/schema.js" << 'EOF'
/**
 * @apiSchema UserSchema
 * @apiDescription 用户数据模型
 * @apiProperty {Number} id 用户ID
 * @apiProperty {String} name 用户名
 * @apiProperty {String} email 邮箱
 * @apiProperty {String} avatar 头像URL
 * @apiProperty {Date} createdAt 创建时间
 */

/**
 * @apiSchema PostSchema
 * @apiDescription 文章数据模型
 * @apiProperty {Number} id 文章ID
 * @apiProperty {String} title 标题
 * @apiProperty {String} content 内容
 * @apiProperty {Number} authorId 作者ID
 * @apiProperty {Date} createdAt 创建时间
 */
EOF

    echo -e "${GREEN}✅ 示例项目已创建: $dir/${NC}"
    echo "   运行: cd $dir && apidoc generate ."
}

generate_docs() {
    local dir=${1:-.}
    local format="markdown"
    local output="./output"
    
    # 解析参数
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --format)
                format=$2
                shift 2
                ;;
            --output)
                output=$2
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}❌ 目录不存在: $dir${NC}"
        exit 1
    fi
    
    mkdir -p "$output"
    
    echo -e "${BLUE}📚 正在生成 API 文档...${NC}"
    echo "   来源: $dir"
    echo "   格式: $format"
    echo "   输出: $output"
    echo ""
    
    # 生成 Markdown 文档
    if [[ "$format" == "markdown" ]] || [[ "$format" == "md" ]]; then
        cat > "$output/api-docs.md" << 'EOF'
# API Documentation

## Overview

This document describes the API endpoints and data models.

---

## Endpoints

EOF
        
        # 提取 API 注释并生成文档
        for file in $(find "$dir" -name "*.js" -o -name "*.py" -o -name "*.go" 2>/dev/null); do
            if grep -q "@api {" "$file" 2>/dev/null; then
                echo "Processing: $file"
                # 提取 API 信息
                while IFS= read -r line; do
                    local method=$(echo "$line" | grep -oP '@api \{\K[^}]+' || echo "")
                    local path=$(echo "$line" | grep -oP '@api \{[^}]+\} \K[^ ]+' || echo "")
                    local name=$(echo "$line" | grep -oP '@apiName \K[^ ]+' || echo "")
                    local group=$(echo "$line" | grep -oP '@apiGroup \K[^ ]+' || echo "")
                    local desc=$(echo "$line" | grep -oP '@apiDescription \K.*$' || echo "")
                    
                    if [[ -n "$method" ]] && [[ -n "$path" ]]; then
                        echo "### $method $path" >> "$output/api-docs.md"
                        echo "" >> "$output/api-docs.md"
                        [[ -n "$name" ]] && echo "- **Name:** $name" >> "$output/api-docs.md"
                        [[ -n "$group" ]] && echo "- **Group:** $group" >> "$output/api-docs.md"
                        [[ -n "$desc" ]] && echo "- **Description:** $desc" >> "$output/api-docs.md"
                        echo "" >> "$output/api-docs.md"
                    fi
                done < <(grep -E "@api \{|@apiName|@apiGroup|@apiDescription" "$file")
            fi
        done
        
        echo "" >> "$output/api-docs.md"
        echo "---" >> "$output/api-docs.md"
        echo "*Generated by API Documentation Generator*" >> "$output/api-docs.md"
        
        echo -e "${GREEN}✅ 文档已生成: $output/api-docs.md${NC}"
    fi
    
    # 统计信息
    local endpoint_count=$(grep -r "@api {" "$dir" 2>/dev/null | wc -l | tr -d ' ')
    echo ""
    echo -e "${GREEN}📊 统计: $endpoint_count 个 API 端点${NC}"
}

show_version() {
    echo "apidoc version $VERSION"
}

case $COMMAND in
    help|--help|-h)
        print_help
        ;;
    init)
        init_example "$PROJECT_DIR"
        ;;
    generate)
        generate_docs "$PROJECT_DIR" "$@"
        ;;
    version|--version|-v)
        show_version
        ;;
    *)
        echo -e "${RED}❌ 未知命令: $COMMAND${NC}"
        echo "运行 'apidoc help' 查看帮助"
        exit 1
        ;;
esac
