# Builds Automated ID System as a desktop .exe (own window, no browser).
# Output folder: .\publish\AutomatedIDSystem\

$ErrorActionPreference = "Stop"
$DesktopProject = Join-Path $PSScriptRoot "src\SirPayaAttendance.Desktop\SirPayaAttendance.Desktop.csproj"
$WebProject = Join-Path $PSScriptRoot "src\SirPayaAttendance.Web\SirPayaAttendance.Web.csproj"
$Output = Join-Path $PSScriptRoot "publish\AutomatedIDSystem"
$WebStage = Join-Path $env:TEMP "AutomatedIDSystem.WebPublish"
$FaviconSource = Join-Path $PSScriptRoot "src\SirPayaAttendance.Web\wwwroot\favicon.ico"

Write-Host "Publishing Automated ID System desktop app for Windows x64..." -ForegroundColor Cyan

Stop-Process -Name "AutomatedIDSystem","GateTrack" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "SirPayaAttendance.Web" -Force -ErrorAction SilentlyContinue

if (Test-Path $WebStage) {
    Remove-Item $WebStage -Recurse -Force
}

dotnet publish $DesktopProject `
    -c Release `
    -r win-x64 `
    --self-contained true `
    -p:PublishReadyToRun=true `
    -o $Output

if ($LASTEXITCODE -ne 0) {
    Write-Host "Desktop publish failed." -ForegroundColor Red
    exit 1
}

Write-Host "Staging Blazor static assets..." -ForegroundColor Cyan

dotnet publish $WebProject `
    -c Release `
    -r win-x64 `
    -o $WebStage

if ($LASTEXITCODE -ne 0) {
    Write-Host "Web static asset publish failed." -ForegroundColor Red
    exit 1
}

$stageWwwRoot = Join-Path $WebStage "wwwroot"
$stageEndpoints = Join-Path $WebStage "SirPayaAttendance.Web.staticwebassets.endpoints.json"

if (-not (Test-Path $stageWwwRoot)) {
    Write-Host "Web publish did not produce wwwroot." -ForegroundColor Red
    exit 1
}

$destWwwRoot = Join-Path $Output "wwwroot"
if (Test-Path $destWwwRoot) {
    Remove-Item $destWwwRoot -Recurse -Force
}
Copy-Item $stageWwwRoot $destWwwRoot -Recurse -Force
Copy-Item $stageEndpoints (Join-Path $Output "AutomatedIDSystem.staticwebassets.endpoints.json") -Force

if (Test-Path $FaviconSource) {
    Copy-Item $FaviconSource (Join-Path $Output "favicon.ico") -Force
    Copy-Item $FaviconSource (Join-Path $destWwwRoot "favicon.ico") -Force
}

$webViewCache = Join-Path $Output "AutomatedIDSystem.exe.WebView2"
if (Test-Path $webViewCache) {
    Remove-Item $webViewCache -Recurse -Force -ErrorAction SilentlyContinue
}

Remove-Item $WebStage -Recurse -Force

Write-Host ""
Write-Host "Tip: Start WAMP MySQL, then run setup-mysql.ps1 if the database is missing." -ForegroundColor Cyan
Write-Host ""
Write-Host "Done! Desktop app ready:" -ForegroundColor Green
Write-Host "  $Output\AutomatedIDSystem.exe"
Write-Host ""
Write-Host "Double-click AutomatedIDSystem.exe - it opens in its own window, not your browser."
