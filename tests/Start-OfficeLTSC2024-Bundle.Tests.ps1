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

if ($buildScriptContent -notmatch [regex]::Escape("Office 2024 LTSC Setup.exe")) {
    throw 'Expected build-office-bundle.ps1 to emit Office 2024 LTSC Setup.exe.'
}

if ($scriptContent -notmatch '\$appTitle\s*=\s*''Office 2024 LTSC Setup''') {
    throw 'Expected the launcher UI title to be Office 2024 LTSC Setup.'
}

if (-not $workflowContent) {
    throw 'Expected a GitHub Actions workflow for building the Office bundle.'
}

if ($workflowContent -notmatch 'Install-Module\s+ps2exe' -or $workflowContent -notmatch 'build-office-bundle\.ps1' -or $workflowContent -notmatch 'upload-artifact' -or $workflowContent -notmatch [regex]::Escape('Office 2024 LTSC Setup.exe')) {
    throw 'Expected the GitHub Actions workflow to install ps2exe, run build-office-bundle.ps1, and upload Office 2024 LTSC Setup.exe.'
}

if ($gitignoreContent -notmatch '(?m)^Office 2024 LTSC Setup\.exe$') {
    throw 'Expected .gitignore to ignore Office 2024 LTSC Setup.exe.'
}

$initialDialogPattern = '(\$initialDialogResult\s*=\s*Show-ThemedDialog[\s\S]*?-CloseConfirmationMessage\s+''Exit the Office installer\?''[\s\S]*?if\s*\(\$initialDialogResult\s*-ne\s*\[System\.Windows\.Forms\.DialogResult\]::OK\)\s*\{[\s\S]*?exit\s+0)'
if ($scriptContent -notmatch $initialDialogPattern) {
    throw 'Expected the initial warning dialog to confirm X-close and exit when dismissed without OK.'
}

$initialDialogCallMatch = [regex]::Match($scriptContent, '\$initialDialogResult\s*=\s*Show-ThemedDialog[^\r\n]*')
if (-not $initialDialogCallMatch.Success) {
    throw 'Expected an initial warning dialog call.'
}

if ($initialDialogCallMatch.Value -match '-CancelText\s+''Exit''') {
    throw 'Did not expect an explicit Exit button on the initial warning dialog.'
}

$downloadPromptPattern = '(?s)\$downloadPrompt\s*=\s*Show-ThemedDialog[\s\S]*?Could not locate the Office payload\.[\s\S]*?Download Office files now\?[\s\S]*?-OkText\s+''Download''[\s\S]*?-CancelText\s+''Exit''[\s\S]*?-CloseConfirmationMessage\s+''Exit the Office installer\?'''
if ($scriptContent -notmatch $downloadPromptPattern) {
    throw 'Expected a download prompt when the Office payload is missing.'
}

$downloadExitPattern = '(?s)\$downloadPrompt\s*=\s*Show-ThemedDialog[\s\S]*?if\s*\(\$downloadPrompt\s*-ne\s*\[System\.Windows\.Forms\.DialogResult\]::OK\)\s*\{[\s\S]*?exit\s+0'
if ($scriptContent -notmatch $downloadExitPattern) {
    throw 'Expected the missing-payload download dialog to exit when dismissed after X confirmation or Cancel.'
}

$downloadFlowPattern = '(?s)\$downloadPayloadRoot\s*=\s*Join-Path\s+\$workDir\s+''Office''[\s\S]*?Invoke-OdtSetup\s+-SetupPath\s+\$setupPath\s+-Mode\s+''/download'''
if ($scriptContent -notmatch $downloadFlowPattern) {
    throw 'Expected the script to download Office files into the temp work directory when payload is missing.'
}

$chooserOrderingPattern = '(?s)if\s*\(-not\s*\$payloadRoot\)[\s\S]*?\$form\s*=\s*New-Object\s+System\.Windows\.Forms\.Form'
if ($scriptContent -notmatch $chooserOrderingPattern) {
    throw 'Expected the app chooser dialog to be created only after payload resolution and download prompting.'
}

$retainFlowPattern = '(?s)Show-ThemedDialog\s+-Title\s+\$appTitle\s+-Message\s+''Keep the downloaded Office files for future installs\?''[\s\S]*?Move-Item\s+-LiteralPath\s+\$downloadPayloadRoot\s+-Destination\s+\$retainedPayloadRoot'
if ($scriptContent -notmatch $retainFlowPattern) {
    throw 'Expected the script to offer keeping downloaded Office files and move temp Office into the launch directory.'
}

Write-Host 'PASS: ConvertTo-XmlAttributeValue escapes XML-significant characters.'
Write-Host 'PASS: Write-BundledFile validates extracted bundled files.'
Write-Host 'PASS: build-office-bundle.ps1 bootstraps ps2exe and workflow builds/uploads the packaged exe.'
Write-Host 'PASS: initial warning dialog confirms X-close and exits when dismissed without OK.'
Write-Host 'PASS: missing payload triggers temp download and optional retention flow.'
Write-Host 'PASS: package name and UI title use Office 2024 LTSC Setup.'
