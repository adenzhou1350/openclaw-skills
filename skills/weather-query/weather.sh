#!/bin/bash
# Weather Query Skill for OpenClaw
# 查询城市天气，支持今日和未来预报

CITY=$1
DAYS=${2:-1}

# 城市映射（中文 -> 拼音）
case $CITY in
  北京) CITY_EN="beijing";;
  上海) CITY_EN="shanghai";;
  深圳) CITY_EN="shenzhen";;
  广州) CITY_EN="guangzhou";;
  杭州) CITY_EN="hangzhou";;
  成都) CITY_EN="chengdu";;
  南京) CITY_EN="nanjing";;
  武汉) CITY_EN="wuhan";;
  西安) CITY_EN="xian";;
  重庆) CITY_EN="chongqing";;
  *) CITY_EN=$CITY;;
esac

# 使用免费天气 API (wttr.in)
if [ "$DAYS" = "3天" ] || [ "$DAYS" = "3" ]; then
  DATA=$(curl -s "wttr.in/${CITY_EN}?format=j1" 2>/dev/null)
  if [ -n "$DATA" ]; then
    echo "📅 $CITY 未来3天天气预报"
    echo ""
    echo "$DATA" | jq -r '.weather[] | "\(.date)\n\(.hourly[0].weatherDesc[0].value)\n🌡️ 温度: \(.hourly[0].tempC)°C\n💧 湿度: \(.hourly[0].humidity)%\n"'
  else
    echo "❌ 无法获取天气数据，请检查城市名称"
  fi
else
  DATA=$(curl -s "wttr.in/${CITY_EN}?format=j1" 2>/dev/null)
  if [ -n "$DATA" ]; then
    CURRENT=$(echo "$DATA" | jq -r '.current_condition[0]')
    echo "🌤️ $CITY 今日天气"
    echo ""
    echo "🌡️ 温度: $(echo $CURRENT | jq -r '.temp_C')°C"
    echo "💧 湿度: $(echo $CURRENT | jq -r '.humidity')%"
    echo "🌬️ 风力: $(echo $CURRENT | jq -r '.windspeedKmph') km/h"
    echo "🌅 日出: $(echo $CURRENT | jq -r '.sunrise')"
    echo "🌇 日落: $(echo $CURRENT | jq -r '.sunset')"
    echo ""
    echo "📝 $(echo $CURRENT | jq -r '.weatherDesc[0].value')"
  else
    echo "❌ 无法获取天气数据，请检查城市名称"
  fi
fi
