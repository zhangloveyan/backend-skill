# 备份脚本 (PowerShell)
# 用法: .\backup.ps1 [mysql|redis|all]

param(
    [Parameter(Position=0)]
    [ValidateSet("mysql", "redis", "all")]
    [string]$Target = "all"
)

$ErrorActionPreference = "Stop"

# 配置
$ProjectName = if ($env:PROJECT_NAME) { $env:PROJECT_NAME } else { "myproject" }
$BackupDir = if ($env:BACKUP_DIR) { $env:BACKUP_DIR } else { "C:\backup" }
$KeepDays = if ($env:KEEP_DAYS) { [int]$env:KEEP_DAYS } else { 7 }
$Date = Get-Date -Format "yyyyMMdd_HHmmss"

# 颜色输出
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Green }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

# 创建备份目录
New-Item -ItemType Directory -Force -Path "$BackupDir\mysql" | Out-Null
New-Item -ItemType Directory -Force -Path "$BackupDir\redis" | Out-Null

# 备份 MySQL
function Backup-MySQL {
    Write-Info "备份 MySQL..."
    $backupFile = "$BackupDir\mysql\${ProjectName}_${Date}.sql"

    docker exec "${ProjectName}-mysql" mysqldump `
        -u"$env:MYSQL_USER" `
        -p"$env:MYSQL_PASSWORD" `
        --single-transaction `
        --routines `
        --triggers `
        "$env:MYSQL_DATABASE" > $backupFile

    # 压缩
    Compress-Archive -Path $backupFile -DestinationPath "$backupFile.zip" -Force
    Remove-Item $backupFile

    Write-Info "MySQL 备份完成: $backupFile.zip"
}

# 备份 Redis
function Backup-Redis {
    Write-Info "备份 Redis..."
    $backupFile = "$BackupDir\redis\${ProjectName}_${Date}.rdb"

    docker exec "${ProjectName}-redis" redis-cli `
        -a "$env:REDIS_PASSWORD" `
        --no-auth-warning `
        BGSAVE

    Start-Sleep -Seconds 5

    docker cp "${ProjectName}-redis:/data/dump.rdb" $backupFile

    Write-Info "Redis 备份完成: $backupFile"
}

# 清理旧备份
function Remove-OldBackups {
    Write-Info "清理 $KeepDays 天前的备份..."
    $cutoffDate = (Get-Date).AddDays(-$KeepDays)

    Get-ChildItem -Path $BackupDir -Recurse -File |
        Where-Object { $_.LastWriteTime -lt $cutoffDate } |
        Remove-Item -Force
}

# 主函数
function Main {
    switch ($Target) {
        "mysql" { Backup-MySQL }
        "redis" { Backup-Redis }
        "all" {
            Backup-MySQL
            Backup-Redis
        }
    }

    Remove-OldBackups
    Write-Info "备份任务完成!"
}

Main
