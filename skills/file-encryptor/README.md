# File Encryptor - 文件加密工具 🔐

一个简单易用的命令行文件加密工具，支持 AES-256-GCM 加密算法。

## 功能特性

- 🔒 **AES-256-CBC** - 军事级加密标准 (PBKDF2 密钥派生)
- 🔑 **两种模式** - 密码加密 / 密钥文件加密
- 📁 **任意文件** - 支持任何类型文件加密
- 🗝️ **密钥生成** - 安全随机密钥文件生成

## 安装

```bash
cd skills/file-encryptor
chmod +x file-encryptor.sh
```

## 使用方法

### 加密文件

```bash
# 使用密码加密
./file-encryptor.sh encrypt document.pdf -p mypassword

# 使用密钥文件加密
./file-encryptor.sh encrypt document.pdf -k key.bin
```

### 解密文件

```bash
# 使用密码解密
./file-encryptor.sh decrypt document.pdf.enc -p mypassword

# 使用密钥文件解密
./file-encryptor.sh decrypt document.pdf.enc -k key.bin
```

### 生成密钥文件

```bash
./file-encryptor.sh generate-key mykey.bin
```

### 查看帮助

```bash
./file-encryptor.sh help
```

## 适合简历展示的技能

- 🔐 **密码学应用** - AES-256-GCM 加密算法
- 🛡️ **安全意识** - 密钥管理、安全存储
- 🛠️ **CLI 工具开发** - Bash 脚本、系统工具
- 📄 **文件处理** - 二进制文件操作

## 技术栈

- OpenSSL
- Bash
- AES-256-GCM 对称加密
