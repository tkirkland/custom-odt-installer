$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $PSScriptRoot '..\Start-OfficeLTSC2024-Bundle.ps1'
$scriptContent = Get-Content -LiteralPath $scriptPath -Raw
$buildScriptPath = Join-Path $PSScriptRoot '..\build-office-bundle.ps1'
$buildScriptContent = Get-Content -LiteralPath $buildScriptPath -Raw
$gitignorePath = Join-Path $PSScriptRoot '..\.gitignore'
$gitignoreContent = Get-Content -LiteralPath $gitignorePath -Raw
$workflowPath = Join-Path $PSScriptRoot '..\.github\workflows\build-office-bundle.yml'
$workflowContent = if (Test-Path -LiteralPath $workflowPath) { Get-Content -LiteralPath $workflowPath -Raw } else { '' }

$xmlFunctionMatch = [regex]::Match(
    $scriptContent,
    'function\s+ConvertTo-XmlAttributeValue\s*\{[\s\S]*?^\}',
    [System.Text.RegularExpressions.RegexOptions]::Multiline
)

if (-not $xmlFunctionMatch.Success) {
    throw 'Expected Start-OfficeLTSC2024-Bundle.ps1 to define ConvertTo-XmlAttributeValue.'
}

. ([scriptblock]::Create($xmlFunctionMatch.Value))

$extractFunctionMatch = [regex]::Match(
    $scriptContent,
    'function\s+Write-BundledFile\s*\{[\s\S]*?^\}',
    [System.Text.RegularExpressions.RegexOptions]::Multiline
)

if (-not $extractFunctionMatch.Success) {
    throw 'Expected Start-OfficeLTSC2024-Bundle.ps1 to define Write-BundledFile.'
}

. ([scriptblock]::Create($extractFunctionMatch.Value))

$escaped = ConvertTo-XmlAttributeValue 'C:\Deploy\R&D\<Office>"Suite"'
$expected = 'C:\Deploy\R&amp;D\&lt;Office&gt;&quot;Suite&quot;'

if ($escaped -ne $expected) {
    throw "Expected escaped XML attribute value '$expected' but got '$escaped'."
}

$tempDir = Join-Path ([IO.Path]::GetTempPath()) ("office-installer-tests-{0}" -f ([guid]::NewGuid().ToString('N')))
$null = New-Item -Path $tempDir -ItemType Directory -Force

try {
    $writtenFile = Join-Path $tempDir 'written.bin'
    Write-BundledFile -Path $writtenFile -WriteAction {
        param($TargetPath)
        [IO.File]::WriteAllBytes($TargetPath, [byte[]](1, 2, 3))
    }

    if (-not (Test-Path -LiteralPath $writtenFile)) {
        throw 'Expected Write-BundledFile to create the output file.'
    }

    if ((Get-Item -LiteralPath $writtenFile).Length -ne 3) {
        throw 'Expected Write-BundledFile to preserve written file content.'
    }

    $emptyFile = Join-Path $tempDir 'empty.bin'
    $message = $null

    try {
        Write-BundledFile -Path $emptyFile -WriteAction {
            param($TargetPath)
            [IO.File]::WriteAllBytes($TargetPath, [byte[]]::new(0))
        }
    }
    catch {
        $message = $_.Exception.Message
    }

    if ($message -ne 'Failed to extract bundled files.') {
        throw "Expected Write-BundledFile to throw 'Failed to extract bundled files.' but got '$message'."
    }
}
finally {
    if (Test-Path -LiteralPath $tempDir) {
        Remove-Item -LiteralPath $tempDir -Recurse -Force
    }
}

if ($buildScriptContent -match [regex]::Escape('tools\ps2exe')) {
    throw 'Did not expect build-office-bundle.ps1 to reference vendored ps2exe files.'
}

if ($buildScriptContent -notmatch 'Install-Module\s+ps2exe' -or $buildScriptContent -notmatch 'Import-Module\s+ps2exe' -or $buildScriptContent -notmatch 'Invoke-ps2exe') {
    throw 'Expected build-office-bundle.ps1 to bootstrap ps2exe from PowerShell Gallery and call Invoke-ps2exe.'
}

if (-not $workflowContent) {
    throw 'Expected a GitHub Actions workflow for building the Office bundle.'
}

if ($workflowContent -notmatch 'Install-Module\s+ps2exe' -or $workflowContent -notmatch 'build-office-bundle\.ps1' -or $workflowContent -notmatch 'upload-artifact') {
    throw 'Expected the GitHub Actions workflow to install ps2exe, run build-office-bundle.ps1, and upload the built exe.'
}

if ($gitignoreContent -notmatch '(?m)^Start-OfficeLTSC2024-Bundle\.exe$') {
    throw 'Expected .gitignore to ignore Start-OfficeLTSC2024-Bundle.exe.'
}

$initialDialogPattern = '(\$initialDialogResult\s*=\s*Show-ThemedDialog[\s\S]*?-CloseConfirmationMessage\s+''Exit the Office installer\?''[\s\S]*?if\s*\(\$initialDialogResult\s*-ne\s*\[System\.Windows\.Forms\.DialogResult\]::OK\)\s*\{[\s\S]*?exit\s+0)'
if ($scriptContent -notmatch $initialDialogPattern) {
    throw 'Expected the initial warning dialog to confirm X-close and exit when dismissed without OK.'
}

if ($scriptContent -match '-CancelText\s+''Exit''') {
    throw 'Did not expect an explicit Exit button on the initial warning dialog.'
}

Write-Host 'PASS: ConvertTo-XmlAttributeValue escapes XML-significant characters.'
Write-Host 'PASS: Write-BundledFile validates extracted bundled files.'
Write-Host 'PASS: build-office-bundle.ps1 bootstraps ps2exe and workflow builds/uploads the packaged exe.'
Write-Host 'PASS: initial warning dialog confirms X-close and exits when dismissed without OK.'
