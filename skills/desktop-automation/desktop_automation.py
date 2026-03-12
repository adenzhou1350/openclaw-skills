#!/usr/bin/env python3
"""
Desktop Automation Core - 跨平台桌面自动化工具
"""

import os
import sys
import time
import json
import subprocess
from pathlib import Path
from typing import Optional, Tuple, List, Dict, Any
import argparse

# 跨平台截图
def capture_screen(region: Optional[List[int]] = None, output: str = None) -> str:
    """截取屏幕或区域"""
    import pyautogui
    
    if region:
        x, y, w, h = region
        img = pyautogui.screenshot(region=(x, y, w, h))
    else:
        img = pyautogui.screenshot()
    
    if output:
        img.save(output)
        return output
    
    # 保存到临时文件
    temp_path = f"/tmp/screenshot_{int(time.time()*1000)}.png"
    img.save(temp_path)
    return temp_path

# OCR 文字识别
def ocr_detect(image_path: str, text: str = None, return_type: str = "position") -> Any:
    """OCR 文字识别"""
    try:
        from paddleocr import PaddleOCR
        
        ocr = PaddleOCR(use_angle_cls=True, lang='ch', show_log=False)
        result = ocr.ocr(image_path, cls=True)
        
        if not result or not result[0]:
            return None
        
        results = []
        for line in result[0]:
            box = line[0]
            txt = line[1][0]
            conf = line[1][1]
            
            # 计算中心点
            cx = (box[0][0] + box[2][0]) / 2
            cy = (box[0][1] + box[2][1]) / 2
            
            results.append({
                "text": txt,
                "confidence": float(conf),
                "position": [cx, cy],
                "box": box
            })
        
        if text:
            # 查找包含指定文字的元素
            for r in results:
                if text in r["text"]:
                    if return_type == "position":
                        return r["position"]
                    elif return_type == "region":
                        return r["box"]
                    return r
            return None
        
        return results
        
    except ImportError:
        # 回退到 pytesseract
        try:
            import pytesseract
            from PIL import Image
            
            img = Image.open(image_path)
            data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)
            
            results = []
            n = len(data["text"])
            for i in range(n):
                if int(data["conf"][i]) > 30:
                    results.append({
                        "text": data["text"][i],
                        "position": [data["left"][i] + data["width"][i]/2, 
                                    data["top"][i] + data["height"][i]/2]
                    })
            
            if text:
                for r in results:
                    if text in r["text"]:
                        return r["position"] if return_type == "position" else r
                return None
            return results
        except:
            print("ERROR: Please install paddleocr or pytesseract")
            return None

# 模板匹配
def template_match(template_path: str, screenshot_path: str = None, 
                   threshold: float = 0.8, region: List[int] = None) -> Optional[Tuple[int, int]]:
    """模板匹配 - 找图标位置"""
    import cv2
    import numpy as np
    import pyautogui
    
    # 截图
    if screenshot_path is None:
        if region:
            img = pyautogui.screenshot(region=(*region[:2], region[2], region[3]))
        else:
            img = pyautogui.screenshot()
        screenshot_path = "/tmp/screen_temp.png"
        img.save(screenshot_path)
    
    # 读取图片
    img = cv2.imread(screenshot_path)
    template = cv2.imread(template_path)
    
    if template is None:
        print(f"ERROR: Template not found: {template_path}")
        return None
    
    # 灰度化
    if len(img.shape) == 3:
        img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    else:
        img_gray = img
        
    if len(template.shape) == 3:
        template_gray = cv2.cvtColor(template, cv2.COLOR_BGR2GRAY)
    else:
        template_gray = template
    
    # 模板匹配
    result = cv2.matchTemplate(img_gray, template_gray, cv2.TM_CCOEFF_NORMED)
    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
    
    if max_val >= threshold:
        # 返回中心点
        h, w = template_gray.shape
        cx = max_loc[0] + w // 2
        cy = max_loc[1] + h // 2
        return (cx, cy, max_val)
    
    return None

# 键鼠操作
def click_at(x: float, y: float, relative: bool = False, 
             button: str = "left", clicks: int = 1):
    """点击指定位置"""
    import pyautogui
    
    if relative:
        # 相对坐标 (0-1)
        screen_w, screen_h = pyautogui.size()
        x = int(x * screen_w)
        y = int(y * screen_h)
    
    pyautogui.click(x, y, clicks=clicks, button=button)

def type_text(text: str, paste: bool = True):
    """输入文本"""
    import pyautogui
    
    if paste:
        # 剪贴板方式更快
        import pyperclip
        pyperclip.copy(text)
        pyautogui.hotkey("ctrl", "v")
    else:
        pyautogui.write(text)

def press_key(key: str):
    """按下按键"""
    import pyautogui
    pyautogui.press(key)

def hotkey(*keys):
    """组合键"""
    import pyautogui
    pyautogui.hotkey(*keys)

def scroll(clicks: int):
    """滚动"""
    import pyautogui
    pyautogui.scroll(clicks)

# 等待条件
def wait_until(condition: str, value: str, timeout: float = 10) -> bool:
    """等待条件满足"""
    start = time.time()
    
    while time.time() - start < timeout:
        if condition == "text_appear":
            screen = capture_screen()
            result = ocr_detect(screen, value)
            if result:
                return True
        elif condition == "text_disappear":
            screen = capture_screen()
            result = ocr_detect(screen, value)
            if not result:
                return True
        elif condition == "template_found":
            result = template_match(value)
            if result:
                return True
        
        time.sleep(0.5)
    
    return False

# 验证操作
def verify_operation(expected: str, value: str, screenshot: str = None) -> bool:
    """验证操作结果"""
    if screenshot is None:
        screenshot = capture_screen()
    
    if expected == "text_appear":
        result = ocr_detect(screenshot, value)
        return result is not None
    elif expected == "text_disappear":
        result = ocr_detect(screenshot, value)
        return result is None
    elif expected == "template_found":
        result = template_match(value, screenshot)
        return result is not None
    
    return False

# 主函数
def main():
    parser = argparse.ArgumentParser(description="Desktop Automation Tool")
    subparsers = parser.add_subparsers(dest="command")
    
    # screenshot
    subparsers.add_parser("screenshot", help="截取屏幕")
    subparsers.add_parser("capture", help="截取屏幕")
    
    # ocr
    ocr_parser = subparsers.add_parser("ocr", help="OCR识别")
    ocr_parser.add_argument("-i", "--image", required=True)
    ocr_parser.add_argument("-t", "--text", help="查找文字")
    
    # click
    click_parser = subparsers.add_parser("click", help="点击")
    click_parser.add_argument("-x", "--x", type=float, required=True)
    click_parser.add_argument("-y", "--y", type=float, required=True)
    click_parser.add_argument("-r", "--relative", action="store_true")
    click_parser.add_argument("-b", "--button", default="left")
    
    # type
    type_parser = subparsers.add_parser("type", help="输入文本")
    type_parser.add_argument("-t", "--text", required=True)
    type_parser.add_argument("-p", "--paste", action="store_true")
    
    # template
    tmpl_parser = subparsers.add_parser("template", help="模板匹配")
    tmpl_parser.add_argument("-m", "--match", required=True)
    tmpl_parser.add_argument("-s", "--screenshot")
    tmpl_parser.add_argument("-t", "--threshold", type=float, default=0.8)
    
    args = parser.parse_args()
    
    if args.command in ("screenshot", "capture"):
        result = capture_screen()
        print(json.dumps({"path": result}))
        
    elif args.command == "ocr":
        result = ocr_detect(args.image, args.text)
        print(json.dumps(result, ensure_ascii=False))
        
    elif args.command == "click":
        click_at(args.x, args.y, args.relative, args.button)
        print(json.dumps({"status": "ok"}))
        
    elif args.command == "type":
        type_text(args.text, args.paste)
        print(json.dumps({"status": "ok"}))
        
    elif args.command == "template":
        result = template_match(args.match, args.screenshot, args.threshold)
        print(json.dumps({"found": result is not None, "position": result[:2] if result else None}))

if __name__ == "__main__":
    main()
