# 获取系统用户名和操作系统类型
$username = $env:USERNAME

# 判断当前操作系统，构建目录

$Notion = "C:\Users\$username\AppData\Roaming\Notion"
$NotionAppFiles = "$Notion\Resources"
$Backup = "$NotionAppFiles\Backup"
$platformName = "Windows"

# 汉化脚本仓库所有者和仓库名
$owner = "Reamd7"
$repo = "notion-zh_CN"
$github_url = "https://github.com/$owner/$repo"

# 欢迎信息输出函数
function Welcome {
    Write-Host "======================================"
    Write-Host ""
    Write-Host "嗨～，欢迎使用 Notion 汉化工具 $platformName v1.0.0"
    Write-Host "作者：Rainforest"
    Write-Host ""
    Write-Host "原汉化包作者 $owner ，仓库 $repo"
    Write-Host "仓库地址: $github_url"
    Write-Host ""
    Write-Host "======================================"
    Write-Host "按任意键开始汉化，或按 Ctrl + C 退出。"
    $null = [Console]::ReadKey($true)
}

# 备份函数
function Backup {
    if (!(Test-Path -Path $Backup)) {
        New-Item -Path $Backup -ItemType Directory
    }
    # 备份原始文件 app.asar
    if (Test-Path -Path "$NotionAppFiles\app.asar") {
        Move-Item -Path "$NotionAppFiles\app.asar" -Destination "$Backup\app.asar"
        Write-Host "app.asar 原始文件备份成功！" -ForegroundColor Green
    } elseif (Test-Path -Path "$Backup\app.asar") {
        Write-Host "app.asar 原始文件已经备份过！" -ForegroundColor Green
    } else {
        Write-Host "app.asar 原始文件不存在！" -ForegroundColor Red
        exit 1
    }
    # 备份原始文件 app-update.yml
    if (Test-Path -Path "$NotionAppFiles\app-update.yml") {
        Move-Item -Path "$NotionAppFiles\app-update.yml" -Destination "$Backup\app-update.yml"
        Write-Host "app-update.yml 自动更新脚本备份成功！" -ForegroundColor Green
    } elseif (Test-Path -Path "$Backup\app-update.yml") {
        Write-Host "app-update.yml 自动更新脚本已经备份过！" -ForegroundColor Green
    } else {
        Write-Host "app-update.yml 自动更新脚本不存在！" -ForegroundColor Red
        exit 1
    }
}

# 下载链接获取函数
function Download-Url {
    $api_url = "https://api.github.com/repos/$owner/$repo/releases/latest"
    $response = Invoke-RestMethod -Uri $api_url -Method Get
    $download_url_win = ($response.assets | Where-Object { $_.name -like "*app.win.zip" }).browser_download_url

    if (-not $download_url_win) {
        Write-Host "错误：无法获取Windows下载链接。" -ForegroundColor Red
        exit 1
    }
}

# 创建下载函数
function Download-File {
    param (
        [string]$url,
        [string]$destination
    )

    Write-Host "正在下载汉化包..."
    Invoke-WebRequest -Uri $url -OutFile $destination
    if ($?) {
        Write-Host "汉化包下载成功！" -ForegroundColor Green
        Unzip-File $destination
    } else {
        Write-Host "汉化包下载失败！" -ForegroundColor Red
        exit 1
    }
}

# 创建解压缩函数
function Unzip-File {
    param (
        [string]$zipFile
    )

    Write-Host "正在解压汉化包..."
    Expand-Archive -Path $zipFile -DestinationPath $NotionAppFiles -Force
    if ($?) {
        Write-Host "汉化包解压成功！" -ForegroundColor Green
        Remove-Item -Path $zipFile
    } else {
        Write-Host "汉化包解压失败！" -ForegroundColor Red
        exit 1
    }
}

Welcome
Backup
Download-Url
Download-File -url $download_url_win -destination "$NotionAppFiles\app.zip"