#!/bin/bash

# 获取系统用户名
username=$(whoami)

# 获取当前操作系统
platform=$(uname)

# 构建输出信息
Found="\033[32m已找到！\033[0m"
notFound="\033[31m未找到！\033[0m"
Error="\033[31m请检查是否安装了Notion并开启运行过一次。\n如果确认，请在 Notion 客户端中按键 Shift + Command + R，强制刷新后再次执行。\033[0m"
Success="\033[32m汉化成功！\n\033[0m"
Restart="\033[32m\n开始重启 Notion ...\n\033[0m"
Start="\033[32m\n开始启动 Notion ...\n\033[0m"
Fail="\033[31m汉化失败！出现了未知错误。\033[0m"

# 清除控制台
clear


# 根据当前系统设置文件夹路径，macOS、Windows 10、Windows 11 适用
folderPath=""
if [[ "$platform" == "Darwin" ]]; then
    folderPath="/Users/$username/Library/Application Support/Notion/notionAssetCache-v2"
    platformName="macOS"
elif [[ "$platform" == "MINGW64_NT"* || "$platform" == "MSYS_NT"* || "$platform" == "CYGWIN_NT"* ]]; then
    folderPath="/c/Users/$username/AppData/Roaming/Notion/notionAssetCache-v2"
    platformName="Windows"
else
    echo "当前操作系统不支持。"
    exit 1
fi
# 设置输出欢迎信息的数组
patternImg=("nnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
    "nnnn                         nnnn"
    "nnnnnnn                          nnnn"
    "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
    "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
    "nnnnnnnn                           nnn"
    "nnnnnnnn    nnnnnnnn     nnnnnnn   nnn"
    "nnnnnnnn      nnnnnnn      nnn     nnn"
    "nnnnnnnn      nnnnnnnn     nnn     nnn"
    "nnnnnnnn      nnnnnnnnnn   nnn     nnn"
    "nnnnnnnn      nnn nnnnnnn  nnn     nnn"
    "nnnnnnnn      nnn  nnnnnnnnnnn     nnn"
    "nnnnnnnn      nnn   nnnnnnnnnn     nnn"
    "nnnnnnnn      nnn    nnnnnnnnn     nnn"
    "nnnnnnnn      nnn      nnnnnnn     nnn"
    "nnnnnnnn    nnnnnnnn    nnnnnn     nnn"
    "  nnnnnn                           nnn"
    "    nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
    "      nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn"
    "")
patternText=(
    "======================================"
    ""
    "嗨～ $username ，欢迎使用 Notion 汉化工具"
    "当前操作系统为 $platformName"
    ""
    "======================================"
    "")

# 输出欢迎信息
for line in "${patternImg[@]}"; do
    echo -e "\033[32m$line\033[0m"
done
for line in "${patternText[@]}"; do
    echo -e "$line"
done
# 提示按任意键继续
read -n 1 -s -r -p "按任意键开始汉化，或按 Ctrl + C 退出。"
echo -e "\n"
# 检查 Notion 缓存文件夹
if [[ ! -d "$folderPath" ]]; then
    echo -e "Notion 的缓存文件夹 ------- $notFound"
    echo -e "$Error"
    exit 1
else
    # 显示缓存文件夹路径
    echo -e "Notion 的缓存文件夹 ------- $Found"
fi

# 检查 latestVersion.json 文件
latestVersionFile="$folderPath/latestVersion.json"
if [[ ! -f "$latestVersionFile" ]]; then
    echo -e "latestVersion.json  ------- $notFound"
    echo -e "$Error"
    exit 1
else
    # 显示 latestVersion.json 文件路径
    echo -e "latestVersion.json文件  --- $Found"
fi

# 读取 latestVersion.json 文件以获取最新版本号
latestVersion=$(awk -F '"' '/"version":/ {print $4}' "$latestVersionFile")

# 构建 assets.json 文件路径
assetsJsonPath="$folderPath/$latestVersion/assets.json"

# 检查 assets.json 文件
if [[ ! -f "$assetsJsonPath" ]]; then
    echo -e "assets.json 文件 ---------- $notFound"
    exit 1
else
    # 显示 assets.json 文件路径
    echo -e "assets.json 文件 ---------- $Found"
fi

# 提取 "zh-CN" 的值
zhCNPart=$(grep -o '"zh-CN":[^,]*' "$assetsJsonPath")
# 从提取的部分中获取值
zhCNValue=$(echo "$zhCNPart" | grep -o '/_assets/[^"]*')
# 替换值
zhCNtext="\"en-US\":\"$zhCNValue\""

# 提取 "en-US" 的值
enUSPart=$(grep -o '"en-US":[^,]*' "$assetsJsonPath")
# 从提取的部分中获取值
enUSValue=$(echo "$enUSPart" | grep -o '/_assets/[^"]*')
# 替换值
enUStext="\"en-US\":\"$enUSValue\""

# 构建 sed 命令
sedmain="s|$enUStext|$zhCNtext|g"

# 替换
sed -i '' "$sedmain" "$assetsJsonPath"

# 检查是否替换成功
if [[ $? -eq 0 ]]; then
    echo -e "$Success"
    # 判断 Notion 是否在运行，如果不在运行则启动，如果在运行则重启
    if [[ "$platform" == "Darwin" ]]; then
        # macOS
        if [[ $(ps aux | grep -i "Notion.app/Contents/MacOS/Notion" | grep -v grep | wc -l) -eq 0 ]]; then
            echo -e "$Start"
            open -a /Applications/Notion.app
        else
            killall Notion
            # 等待 2 秒
            echo -e "$Restart"
            sleep 2
            open -a /Applications/Notion.app
        fi
    elif [[ "$platform" == "MINGW64_NT"* || "$platform" == "MSYS_NT"* || "$platform" == "CYGWIN_NT"* ]]; then
        # Windows
        if [[ $(tasklist | grep -i "Notion.exe" | grep -v grep | wc -l) -eq 0 ]]; then
            echo -e "$Start"
            start "" "C:\Users\$username\AppData\Local\Programs\Notion\Notion.exe"
        else
            taskkill /f /im Notion.exe
            # 等待 2 秒
            echo -e "$Restart"
            sleep 2
            start "" "C:\Users\$username\AppData\Local\Programs\Notion\Notion.exe"
        fi
    fi
else
    echo -e "$Fail"
fi
