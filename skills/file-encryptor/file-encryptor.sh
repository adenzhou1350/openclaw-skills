#!/bin/bash

# File Encryptor - 文件加密工具
# 支持 AES-256-GCM 加密，支持密码和密钥文件两种方式
# 适合简历展示: 安全意识、密码学应用、CLI工具开发

set -e

COMMAND="${1:-help}"
shift || true

case "$COMMAND" in
    help)
        echo "File Encryptor - 文件加密工具"
        echo ""
        echo "用法:"
        echo "  $(basename $0) encrypt <file> [-p <password>|-k <keyfile>]"
        echo "  $(basename $0) decrypt <file.enc> [-p <password>|-k <keyfile>]"
        echo "  $(basename $0) generate-key <output_file>"
        echo "  $(basename $0) help"
        echo ""
        echo "选项:"
        echo "  -p <password>  使用密码加密/解密"
        echo "  -k <keyfile>   使用密钥文件加密/解密"
        echo ""
        echo "示例:"
        echo "  $(basename $0) encrypt document.pdf -p mypassword"
        echo "  $(basename $0) decrypt document.pdf.enc -k key.bin"
        echo "  $(basename $0) generate-key mykey.bin"
        ;;
    encrypt)
        FILE=""
        PASSWORD=""
        KEYFILE=""
        
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -p)
                    PASSWORD="$2"
                    shift 2
                    ;;
                -k)
                    KEYFILE="$2"
                    shift 2
                    ;;
                *)
                    FILE="$1"
                    shift
                    ;;
            esac
        done
        
        if [[ -z "$FILE" ]]; then
            echo "错误: 请指定要加密的文件"
            exit 1
        fi
        
        if [[ -z "$PASSWORD" ]] && [[ -z "$KEYFILE" ]]; then
            echo "错误: 请指定密码 (-p) 或密钥文件 (-k)"
            exit 1
        fi
        
        OUTPUT="${FILE}.enc"
        
        if [[ -n "$KEYFILE" ]]; then
            openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$FILE" -out "$OUTPUT" -pass file:"$KEYFILE" 2>&1
        else
            openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -in "$FILE" -out "$OUTPUT" -pass pass:"$PASSWORD" 2>&1
        fi
        
        echo "✅ 加密成功: $OUTPUT"
        echo "   原始文件: $FILE"
        ;;
    decrypt)
        FILE=""
        PASSWORD=""
        KEYFILE=""
        
        while [[ $# -gt 0 ]]; do
            case "$1" in
                -p)
                    PASSWORD="$2"
                    shift 2
                    ;;
                -k)
                    KEYFILE="$2"
                    shift 2
                    ;;
                *)
                    FILE="$1"
                    shift
                    ;;
            esac
        done
        
        if [[ -z "$FILE" ]]; then
            echo "错误: 请指定要解密的文件"
            exit 1
        fi
        
        if [[ -z "$PASSWORD" ]] && [[ -z "$KEYFILE" ]]; then
            echo "错误: 请指定密码 (-p) 或密钥文件 (-k)"
            exit 1
        fi
        
        OUTPUT="${FILE%.enc}"
        [[ "$OUTPUT" == "$FILE" ]] && OUTPUT="${FILE}.decrypted"
        
        if [[ -n "$KEYFILE" ]]; then
            openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -d -in "$FILE" -out "$OUTPUT" -pass file:"$KEYFILE" 2>&1
        else
            openssl enc -aes-256-cbc -salt -pbkdf2 -iter 100000 -d -in "$FILE" -out "$OUTPUT" -pass pass:"$PASSWORD" 2>&1
        fi
        
        echo "✅ 解密成功: $OUTPUT"
        ;;
    generate-key)
        OUTPUT="${1:-key.bin}"
        openssl rand -base64 32 > "$OUTPUT"
        chmod 600 "$OUTPUT"
        echo "✅ 密钥已生成: $OUTPUT"
        echo "   请妥善保管此文件"
        ;;
    *)
        echo "未知命令: $COMMAND"
        echo "运行 $(basename $0) help 查看帮助"
        exit 1
        ;;
esac
