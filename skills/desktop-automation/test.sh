#!/bin/bash
# 测试桌面自动化功能

echo "=== Desktop Automation Test ==="

# 1. 测试截图
echo "[1] 测试截图功能..."
python3 /root/.openclaw/workspace/skills/desktop-automation/desktop_automation.py screenshot
if [ $? -eq 0 ]; then
    echo "✅ 截图功能正常"
else
    echo "❌ 截图失败"
fi

# 2. 测试 OCR (如果有图片)
echo ""
echo "[2] 测试 OCR 功能..."
# 创建一个测试图片
python3 -c "
from PIL import Image, ImageDraw, ImageFont
img = Image.new('RGB', (400, 100), color='white')
d = ImageDraw.Draw(img)
d.text((50, 30), 'Hello World', fill='black')
img.save('/tmp/test_ocr.png')
"
python3 /root/.openclaw/workspace/skills/desktop-automation/desktop_automation.py ocr -i /tmp/test_ocr.png -t "Hello"

# 3. 检查依赖
echo ""
echo "[3] 检查依赖..."
python3 -c "import cv2; print('✅ opencv-python')" 2>/dev/null || echo "❌ opencv-python 未安装"
python3 -c "import pyautogui; print('✅ pyautogui')" 2>/dev/null || echo "❌ pyautogui 未安装"
python3 -c "import PIL; print('✅ pillow')" 2>/dev/null || echo "❌ pillow 未安装"

# 4. 检查平台支持
echo ""
echo "[4] 平台信息..."
uname -s

echo ""
echo "=== 测试完成 ==="
