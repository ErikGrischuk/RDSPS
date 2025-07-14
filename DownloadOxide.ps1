# --- Get script root path ---
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# --- Archive settings ---
$zipUrl = "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip"
$zipFile = Join-Path $ScriptRoot "Oxide.Rust.zip"
$tempExtract = Join-Path $ScriptRoot "_oxide_tmp"
$sourceSubfolder = "RustDedicated_Data"
$destination = Join-Path $ScriptRoot "RustDedicated_Data"

Write-Host "Downloading Oxide archive..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing

Write-Host "Extracting archive..." -ForegroundColor Cyan
if (Test-Path $tempExtract) { Remove-Item -Recurse -Force $tempExtract }
Expand-Archive -Path $zipFile -DestinationPath $tempExtract -Force

$source = Join-Path $tempExtract $sourceSubfolder
if (-not (Test-Path $source)) {
    Write-Host "Error: '$sourceSubfolder' folder not found in archive!" -ForegroundColor Red
    Exit 1
}

Write-Host "Merging '$sourceSubfolder' into local RustDedicated_Data..." -ForegroundColor Cyan

# Counters
$replaced = 0
$added = 0

# Get all source files
$files = Get-ChildItem -Path $source -Recurse -File

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($source.Length).TrimStart('\')
    $targetFile = Join-Path $destination $relativePath

    if (Test-Path $targetFile) {
        $replaced++
        Write-Host "[REPLACED] $relativePath" -ForegroundColor Yellow
    } else {
        $added++
        Write-Host "[ADDED]    $relativePath" -ForegroundColor Green
    }

    # Ensure directory exists
    $targetDir = Split-Path $targetFile
    if (-not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }

    Copy-Item -Path $file.FullName -Destination $targetFile -Force
}

# Cleanup
Remove-Item $zipFile -Force
Remove-Item $tempExtract -Recurse -Force

# Summary
Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Files added:    $added"
Write-Host "  Files replaced: $replaced"
Write-Host "`nOxide installed successfully!" -ForegroundColor Green

# Wait for user
Write-Host "`nPress any key to exit..." -ForegroundColor DarkGray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")