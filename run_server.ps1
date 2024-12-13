# Определяем путь к приложению и имя процесса
$AppPath = "$(Get-Location)\Content.Server\Content.Server.exe"
$ProcessName = "Content.Server"

# Функция для проверки наличия обновлений
function Check-GitUpdates {
    git fetch > $null 2>&1
    $localCommit = & git.exe rev-parse HEAD
    $remoteCommit = & git.exe rev-parse origin/HEAD

    if ($localCommit -ne $remoteCommit) {
        return $true
    } else {
        return $false
    }
}

# Перезапускаем приложение
Write-Host "Запускаю приложение..." -ForegroundColor Yellow
Start-Process -FilePath $AppPath
Write-Host "Приложение запущено." -ForegroundColor Green

# Основной цикл
while ($true) {
    # Проверяем обновления
    if (Check-GitUpdates) {
        Write-Host "Найдены обновления. Останавливаю процесс..." -ForegroundColor Yellow

        # Останавливаем процесс
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Name $ProcessName -Force
            Write-Host "Процесс остановлен." -ForegroundColor Green
        } else {
            Write-Host "Процесс не найден." -ForegroundColor Gray
        }

        # Получаем обновления
        Write-Host "Получаю обновления из GIT..." -ForegroundColor Yellow
        & git.exe pull

        # Перезапускаем приложение
        Write-Host "Перезапускаю приложение..." -ForegroundColor Yellow
        Start-Process -FilePath $AppPath
        Write-Host "Приложение перезапущено." -ForegroundColor Green
    } else {
        Write-Host "Обновлений не найдено." -ForegroundColor Gray
    }

    # Ждем 1 минуту
    Start-Sleep -Seconds 30
}
