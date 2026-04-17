$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSCommandPath
$bundleScript = Join-Path $projectRoot 'Start-OfficeLTSC2024-Bundle.ps1'
$bundleExe = Join-Path $projectRoot 'Office 2024 LTSC Setup.exe'
$iconPath = Join-Path $projectRoot 'setup-icon.ico'

if (-not (Test-Path -LiteralPath $bundleScript)) {
    throw "Missing bundle script: $bundleScript"
}

if (-not (Test-Path -LiteralPath $iconPath)) {
    throw "Missing icon file: $iconPath"
}

if (-not (Get-Command -Name Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    $psGallery = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
    if ($psGallery -and $psGallery.InstallationPolicy -ne 'Trusted') {
        Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    }

    Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber
}

Import-Module ps2exe -Force

Invoke-ps2exe `
    -inputFile $bundleScript `
    -outputFile $bundleExe `
    -iconFile $iconPath `
    -title 'Office 2024 LTSC Setup' `
    -description 'Launches the Office 2024 LTSC installer.' `
    -product 'Office 2024 LTSC Setup' `
    -company 'tkirkland' `
    -version '1.0.0' `
    -x64 `
    -STA `
    -noConsole

Write-Host "Built $bundleExe"
