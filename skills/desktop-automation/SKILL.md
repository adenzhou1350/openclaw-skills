# Desktop Automation Skill

让 OpenClaw 能像人一样操作桌面应用和游戏。

## 功能

- 🎯 **截图捕获** - 跨平台屏幕截图
- 👁️ **视觉感知** - OCR文字识别、模板匹配、目标检测
- 🖱️ **键鼠模拟** - 点击、输入、快捷键
- ✅ **结果验证** - 操作前后截图对比
- 🧠 **智能决策** - 规则引擎 + 状态机 + VLM fallback

## 架构

```
┌─────────────────────────────────────────────────┐
│              Task (用户任务)                     │
├─────────────────────────────────────────────────┤
│              策略层 (低成本)                     │
│  • 模板匹配 - 固定UI (按钮、图标)              │
│  • 坐标记忆 - 常见元素位置缓存                   │
│  • 规则引擎 - 简单操作序列                       │
├─────────────────────────────────────────────────┤
│              感知层 (中成本)                     │
│  • OCR - 文字定位                               │
│  • 模板匹配 - OpenCV                            │
│  • 色块/线条检测                                │
├─────────────────────────────────────────────────┤
│              理解层 (高成本 - VLM)              │
│  • 仅复杂任务调用                               │
│  • 理解界面意图                                 │
└─────────────────────────────────────────────────┘
```

## 工具

### screen_capture
获取屏幕截图

```
{
  "region": [x, y, width, height],  // 可选，截取区域
  "output": "path/to/save.png"       // 可选，保存路径
}
```

### ocr_detect
OCR 文字识别

```
{
  "image": "path/to/screenshot.png",
  "text": "要查找的文字",           // 查找包含此文字的元素
  "return": "position"              // 返回: position/region/all
}
```

### template_match
模板匹配 - 找图标/按钮

```
{
  "template": "path/to/icon.png",   // 模板图片
  "threshold": 0.8,                  // 匹配阈值
  "search_region": [x, y, w, h]     // 可选，搜索区域
}
```

### click_at
点击指定位置

```
{
  "position": [x, y],               // 坐标 [0-1] 相对坐标 或 绝对坐标
  "relative": false,                 // true=相对坐标
  "button": "left",                  // left/right/middle
  "clicks": 1                        // 点击次数
}
```

### type_text
输入文本

```
{
  "text": "hello world",
  "paste": true                      // true=剪贴板粘贴(更快)
}
```

### wait_until
等待条件满足

```
{
  "condition": "text_appear",        // text_appear / text_disappear / template_found
  "value": "确认按钮",
  "timeout": 10                      // 超时秒数
}
```

### verify_operation
验证操作结果

```
{
  "expected": "text_appear",
  "value": "提交成功",
  "screenshot": "path/to/after.png"  // 操作后截图
}
```

## 使用示例

### 简单任务 - 模板匹配
```
用户: "点击开始按钮"

1. 截图当前屏幕
2. 用模板匹配找"开始按钮"图标
3. 点击找到的坐标
4. 验证点击成功
```

### 中等任务 - OCR
```
用户: "点击提交表单"

1. 截图
2. OCR识别屏幕文字，找到"提交"按钮位置
3. 点击
4. 验证成功
```

### 复杂任务 - VLM
```
用户: "帮我填写这个表单"

1. 截图
2. 调用 VLM 分析表单结构 + 理解意图
3. 按顺序填写字段
4. 验证每步结果
```

## 依赖安装

```bash
# 核心依赖
pip install opencv-python pillow pytesseract pyautogui numpy

# OCR (可选，推荐)
pip install paddlepaddle paddleocr  # 或
pip install easyocr

# Windows 额外
pip install pygetwindow pyautogui

# macOS 额外
pip install pyobjc
```

## 配置

配置文件: `~/.openclaw/desktop-automation.json`

```json
{
  "platform": "auto",           // auto/windows/mac/linux
  "screenshot_delay": 0.1,      // 截图延迟
  "click_delay": 0.05,          // 点击延迟
  "ocr_engine": "paddle",       // paddle/easyocr/tesseract
  "template_cache_dir": "./templates",
  "log_level": "info"
}
```

## 模板管理

保存常用UI元素模板:

```
templates/
├── game/
│   ├── start_button.png
│   ├── menu.png
│   └── close.png
├── app/
│   ├── submit.png
│   └── cancel.png
```

## 注意事项

- ⚠️ 复杂/敏感操作需要用户确认
- 🎮 游戏自动化可能违反 TOS，请谨慎使用
- 🔒 不要在自动化中输入敏感密码
