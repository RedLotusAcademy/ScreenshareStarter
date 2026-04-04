Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

function Prompt-YN {
    param([string]$Message)
    do { $ans = Read-Host $Message } while ($ans -notmatch '^[YyNn]$')
    return ($ans -match '^[Yy]$')
}

function Invoke-RemoteScript {
    param([string]$Name, [string]$Url)
    if (Prompt-YN "Run $Name ? [Y/N]") {
        try   { Invoke-Expression (Invoke-RestMethod -Uri $Url -UseBasicParsing) }
        catch { Write-Host "ERROR - $Name : $_" -ForegroundColor Red }
    }
}
Invoke-RemoteScript "Services.ps1"          "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/Services.ps1"
Invoke-RemoteScript "DoomsDayDetector.ps1"  "https://raw.githubusercontent.com/zedoonvm1/powershell-scripts/refs/heads/main/DoomsDayDetector.ps1"
Invoke-RemoteScript "HabibiModAnalyzer.ps1" "https://raw.githubusercontent.com/HadronCollision/PowershellScripts/refs/heads/main/HabibiModAnalyzer.ps1"
Invoke-RemoteScript "CommonDirectories.ps1" "https://raw.githubusercontent.com/praiselily/lilith-ps/refs/heads/main/CommonDirectories.ps1"
Invoke-RemoteScript "HotspotLogs.ps1"       "https://raw.githubusercontent.com/praiselily/WeHateFakers/refs/heads/main/HotspotLogs.ps1"

$CollectorZipUrl  = "https://github.com/RedLotusForensics/tool/releases/download/Tool/Collector.zip"
$CollectorZipPath = Join-Path $env:TEMP "Collector.zip"
$CollectorDir     = Join-Path $env:TEMP "collector"
$CollectorExe     = Join-Path $CollectorDir "Collector.exe"

if (Prompt-YN "Run Collector.exe ? [Y/N]") {
    try {
        Write-Host "Downloading..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $CollectorZipUrl -OutFile $CollectorZipPath -UseBasicParsing
        Expand-Archive -Path $CollectorZipPath -DestinationPath $env:TEMP -Force
        if (Test-Path $CollectorExe) {
            Start-Process -FilePath $CollectorExe -Verb RunAs -Wait
        } else {
            Write-Host "ERROR - Collector.exe not found at: $CollectorExe" -ForegroundColor Red
        }
    } catch {
        Write-Host "ERROR - Collector: $_" -ForegroundColor Red
    }
}
if (Prompt-YN "Cleanup files? (Collector.zip, collector\, C:\Screenshare\) [Y/N]") {
    foreach ($path in @($CollectorZipPath, $CollectorDir, "C:\Screenshare")) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
