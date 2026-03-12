# URL Shortener Skill

短链接生成工具，支持多种短链接服务。

## 功能特性

- ✅ 多服务支持（TinyURL, is.gd）
- ✅ 自动选择可用服务
- ✅ 短链接展开
- ✅ 二维码生成
- ✅ 历史记录

## 快速开始

```bash
# 进入目录
cd skills/url-shortener

# 生成短链接
./urlshort.sh short 'https://very-long-url.com/something'

# 展开短链接
./urlshort.sh expand 'https://tinyurl.com/abc123'

# 生成短链接二维码
./urlshort.sh qr 'https://github.com'

# 查看历史
./urlshort.sh history

# 列出支持的服务
./urlshort.sh services
```

## 安装依赖

```bash
# Ubuntu/Debian
sudo apt-get install -y curl jq qrencode

# macOS
brew install curl jq qrencode
```

## 适合简历展示

- **API 集成能力**: 第三方 API 调用
- **错误处理**: 网络请求容错
- **用户体验**: 多服务自动切换
- **工具开发**: CLI 工具设计

## 技术栈

- Bash 脚本
- cURL 网络请求
- jq JSON 处理
