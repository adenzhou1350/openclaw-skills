# QR Code Generator Skill

二维码生成工具，支持多种格式的二维码创建。

## 功能特性

- ✅ 文本/URL 二维码生成
- ✅ WiFi 二维码（自动连接）
- ✅ 电话号码二维码
- ✅ 邮箱二维码
- ✅ 名片（vCard）二维码
- ✅ 历史记录管理

## 快速开始

```bash
# 进入目录
cd skills/qrcode-generator

# 生成文本二维码
./qrcode.sh generate "Hello World"

# 生成 URL 二维码
./qrcode.sh url "https://github.com"

# 生成 WiFi 二维码
./qrcode.sh wifi "MyWiFi" "password123"

# 生成电话二维码
./qrcode.sh phone "+86-138-0000-1234"

# 生成邮箱二维码
./qrcode.sh email "user@example.com"

# 生成名片二维码
./qrcode.sh vcard "张三" "13800001234" "zhangsan@example.com" "某公司"

# 查看历史
./qrcode.sh list

# 清理历史
./qrcode.sh clean
```

## 安装依赖

```bash
# Ubuntu/Debian
sudo apt-get install -y qrencode

# CentOS/RHEL
sudo yum install -y qrencode

# macOS
brew install qrencode
```

## 适合简历展示

- **实用工具开发能力**: 命令行工具设计
- **用户交互体验**: 多种生成模式
- **文件操作能力**: 历史记录管理
- **跨平台支持**: Linux/macOS 兼容

## 技术栈

- Bash 脚本
- qrencode 库
