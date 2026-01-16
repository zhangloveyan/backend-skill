# 回滚脚本 (PowerShell)
# 用法: .\rollback.ps1 [admin|api] [version]

param(
    [Parameter(Position=0)]
    [ValidateSet("admin", "api")]
    [string]$Service = "admin",

    [Parameter(Position=1)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# 配置
$ProjectName = if ($env:PROJECT_NAME) { $env:PROJECT_NAME } else { "myproject" }
$DockerDir = Split-Path -Parent $PSScriptRoot

# 颜色输出
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

# 列出可用版本
function Get-Versions {
    param([string]$ServiceName)
    Write-Info "可用的 $ServiceName 版本:"
    docker images "${ProjectName}-${ServiceName}" --format "{{.Tag}}`t{{.CreatedAt}}" | Select-Object -First 10
}

# 回滚到指定版本
function Invoke-Rollback {
    param([string]$ServiceName, [string]$TargetVersion)

    Write-Info "回滚 $ServiceName 到版本 $TargetVersion..."

    Push-Location $DockerDir

    # 停止当前服务
    docker-compose stop "app-$ServiceName"

    # 更新镜像标签
    docker tag "${ProjectName}-${ServiceName}:${TargetVersion}" "${ProjectName}-${ServiceName}:latest"

    # 启动服务
    docker-compose up -d "app-$ServiceName"

    Pop-Location

    Write-Info "回滚完成!"
}

# 主函数
function Main {
    if ([string]::IsNullOrEmpty($Version)) {
        Get-Versions $Service
    } else {
        Invoke-Rollback $Service $Version
    }
}

Main
