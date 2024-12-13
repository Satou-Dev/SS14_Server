# ���������� ���� � ���������� � ��� ��������
$AppPath = "$(Get-Location)\Content.Server\Content.Server.exe"
$ProcessName = "Content.Server"
$ResourcesFolder = "$(Get-Location)\Resources"
$ParentFolder = "$(Get-Location)\..\Resources"

# ������� ��� �������� ������� ����������
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

# ������� ��� ����������� ����� Resources
function Copy-Resources {
    if (Test-Path $ResourcesFolder) {
        Write-Host "������� ����� Resources � ������������ ����������..." -ForegroundColor Yellow
        Copy-Item -Path $ResourcesFolder -Destination $ParentFolder -Recurse -Force
        Write-Host "����� Resources �����������." -ForegroundColor Green
    } else {
        Write-Host "����� Resources �� �������." -ForegroundColor Gray
    }
}

# �������� ����� Resources ��� �������
Copy-Resources

# ������������� ����������
Write-Host "�������� ����������..." -ForegroundColor Yellow
Start-Process -FilePath $AppPath
Write-Host "���������� ��������." -ForegroundColor Green

# �������� ����
while ($true) {
    # ��������� ����������
    if (Check-GitUpdates) {
        Write-Host "������� ����������. ������������ �������..." -ForegroundColor Yellow

        # ������������� �������
        $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Name $ProcessName -Force
            Write-Host "������� ����������." -ForegroundColor Green
        } else {
            Write-Host "������� �� ������." -ForegroundColor Gray
        }

        # �������� ����������
        Write-Host "������� ���������� �� GIT..." -ForegroundColor Yellow
        & git.exe pull

        # �������� ����� Resources ��� ����������
        Copy-Resources

        # ������������� ����������
        Write-Host "������������ ����������..." -ForegroundColor Yellow
        Start-Process -FilePath $AppPath
        Write-Host "���������� ������������." -ForegroundColor Green
    } else {
        Write-Host "���������� �� �������." -ForegroundColor Gray
    }

    # ���� 30 ������
    Start-Sleep -Seconds 30
}
