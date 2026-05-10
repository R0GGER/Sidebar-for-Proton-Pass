#requires -Version 5.1
<#
.SYNOPSIS
    Builds an .xpi of the Sidebar for Proton Pass Firefox extension.

.DESCRIPTION
    Reads the version from manifest.json, zips the extension files at the
    correct level (manifest.json sits at the root of the archive) and
    produces an .xpi file in the dist\ folder.

.EXAMPLE
    .\build.ps1
    Creates dist\sidebar-for-proton-pass-<version>.xpi.

.EXAMPLE
    .\build.ps1 -OutputDir .
    Writes the .xpi file to the current folder instead of dist\.
#>

[CmdletBinding()]
param(
    [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$manifestPath = Join-Path $PSScriptRoot "manifest.json"
if (-not (Test-Path $manifestPath)) {
    throw "manifest.json not found in $PSScriptRoot"
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$name     = ($manifest.name -replace '\s+', '-').ToLower()
$version  = $manifest.version

if ([string]::IsNullOrWhiteSpace($version)) {
    throw "No 'version' found in manifest.json"
}

$includes = @(
    "manifest.json",
    "background.js",
    "sidebar.html",
    "icons"
)

foreach ($item in $includes) {
    if (-not (Test-Path (Join-Path $PSScriptRoot $item))) {
        throw "Expected file or folder is missing: $item"
    }
}

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$outFile = Join-Path $OutputDir ("{0}-{1}.xpi" -f $name, $version)

if (Test-Path $outFile) { Remove-Item $outFile -Force }

# Build the .xpi via System.IO.Compression so that ZIP entry names always
# use forward slashes ('/'). Compress-Archive on Windows PowerShell 5.1
# writes backslashes, which the AMO validator rejects with errors like
# "Invalid file name in archive: icons\icon.svg".
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Add-FileToZip {
    param(
        [System.IO.Compression.ZipArchive]$Zip,
        [string]$SourcePath,
        [string]$EntryName
    )
    $entry  = $Zip.CreateEntry($EntryName, [System.IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    try {
        $bytes = [System.IO.File]::ReadAllBytes($SourcePath)
        $stream.Write($bytes, 0, $bytes.Length)
    } finally {
        $stream.Dispose()
    }
}

$zipStream  = [System.IO.File]::Open($outFile, [System.IO.FileMode]::CreateNew)
$zipArchive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($item in $includes) {
        $fullPath = Join-Path $PSScriptRoot $item
        if (Test-Path -LiteralPath $fullPath -PathType Container) {
            $files = Get-ChildItem -LiteralPath $fullPath -Recurse -File
            foreach ($file in $files) {
                $relative = $file.FullName.Substring($PSScriptRoot.Length).TrimStart('\','/').Replace('\','/')
                Add-FileToZip -Zip $zipArchive -SourcePath $file.FullName -EntryName $relative
            }
        } else {
            Add-FileToZip -Zip $zipArchive -SourcePath $fullPath -EntryName $item.Replace('\','/')
        }
    }
} finally {
    $zipArchive.Dispose()
    $zipStream.Dispose()
}

$size = "{0:N1} KB" -f ((Get-Item $outFile).Length / 1KB)
Write-Host ""
Write-Host "Build successful:" -ForegroundColor Green
Write-Host "  File    : $outFile"
Write-Host "  Version : $version"
Write-Host "  Size    : $size"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  - Test temporarily : about:debugging -> Load Temporary Add-on -> select manifest.json"
Write-Host "  - Make permanent   : upload the .xpi file to https://addons.mozilla.org/developers/"
