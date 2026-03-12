# Password Manager Skill

本地密码管理工具，安全存储各类账号密码。

## 功能特性

- ✅ 密码存储（服务名/用户名/密码）
- ✅ 强密码生成
- ✅ 搜索功能
- ✅ 分类管理
- ✅ 备份功能

## 快速开始

```bash
# 进入目录
cd skills/password-manager

# 添加密码
./password.sh add github.com john@email.com
./password.sh add github.com john@email.com mypass123

# 获取密码
./password.sh get github.com

# 列出所有
./password.sh list

# 搜索
./password.sh search github

# 生成强密码
./password.sh generate 16

# 编辑密码
./password.sh edit github.com

# 删除密码
./password.sh delete github.com

# 备份
./password.sh backup
```

## 安装依赖

```bash
# Ubuntu/Debian
sudo apt-get install -y gnupg pwgen

# macOS
brew install gnupg pwgen
```

## 适合简历展示

- **安全意识**: 密码加密存储理念
- **CLI 工具开发**: 完整的命令行交互
- **数据管理**: 文件 I/O 操作
- **用户体验**: 帮助信息、交互提示

## 技术栈

- Bash 脚本
- 文件存储（可升级为 GPG 加密）
