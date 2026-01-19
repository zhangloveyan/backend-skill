# 部署脚本 (PowerShell)
# 用法: .\deploy.ps1 [admin|api|all] [-Build]

param(
    [Parameter(Position=0)]
    [ValidateSet("admin", "api", "all", "logs")]
    [string]$Target = "all",

    [Parameter(Position=1)]
    [string]$Service = "app-admin",

    [switch]$Build
)

$ErrorActionPreference = "Stop"

# 配置
$ProjectName = if ($env:PROJECT_NAME) { $env:PROJECT_NAME } else { "myproject" }
$DockerDir = Split-Path -Parent $PSScriptRoot

# 颜色输出
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

# 检查环境
function Test-Environment {
    if (-not (Test-Path "$DockerDir\.env")) {
        Write-Err ".env 文件不存在，请从 .env.template 复制并配置"
        exit 1
    }

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Err "Docker 未安装"
        exit 1
    }

    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Err "Docker Compose 未安装"
        exit 1
    }
}

# 构建镜像
function Build-Image {
    param([string]$ServiceName)
    Write-Info "构建 $ServiceName 镜像..."
    Push-Location $DockerDir
    docker-compose build $ServiceName
    Pop-Location
}

# 部署服务
function Deploy-Service {
    param([string]$ServiceName)
    Write-Info "部署 $ServiceName..."
    Push-Location $DockerDir
    docker-compose up -d $ServiceName
    Pop-Location
    Write-Info "$ServiceName 部署完成"
}

# 健康检查
function Test-Health {
    param([string]$ServiceName, [int]$Port)

    $maxAttempts = 30
    $attempt = 1

    Write-Info "等待 $ServiceName 启动..."
    while ($attempt -le $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$Port/actuator/health" -UseBasicParsing -TimeoutSec 2
            if ($response.StatusCode -eq 200) {
                Write-Info "$ServiceName 健康检查通过"
                return $true
            }
        } catch {
            # 忽略错误，继续重试
        }
        Start-Sleep -Seconds 2
        $attempt++
    }

    Write-Err "$ServiceName 健康检查失败"
    return $false
}

# 查看日志
function Show-Logs {
    param([string]$ServiceName)
    Push-Location $DockerDir
    docker-compose logs -f --tail=100 $ServiceName
    Pop-Location
}

# 主函数
function Main {
    Test-Environment

    switch ($Target) {
        "admin" {
            if ($Build) { Build-Image "app-admin" }
            Deploy-Service "app-admin"
            Test-Health "app-admin" 9501
        }
        "api" {
            if ($Build) { Build-Image "app-api" }
            Deploy-Service "app-api"
            Test-Health "app-api" 9502
        }
        "all" {
            if ($Build) {
                Build-Image "app-admin"
                Build-Image "app-api"
            }
            Push-Location $DockerDir
            docker-compose up -d
            Pop-Location
            Test-Health "app-admin" 9501
            Test-Health "app-api" 9502
        }
        "logs" {
            Show-Logs $Service
        }
    }

    Write-Info "部署完成!"
}

Main
