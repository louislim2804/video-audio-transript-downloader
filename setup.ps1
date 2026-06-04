# setup.ps1 — first-time environment setup for ytget
# Downloads yt-dlp.exe and ffmpeg.exe into the same folder as this script.
# Safe to re-run: skips files that are already present and up to date.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding            = [System.Text.Encoding]::UTF8

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ytdlpPath  = Join-Path $scriptDir "yt-dlp.exe"
$ffmpegPath = Join-Path $scriptDir "ffmpeg.exe"

function Write-Cyan  ($m) { Write-Host $m -ForegroundColor Cyan }
function Write-Green ($m) { Write-Host $m -ForegroundColor Green }
function Write-Red   ($m) { Write-Host $m -ForegroundColor Red }
function Write-Yellow($m) { Write-Host $m -ForegroundColor Yellow }

function Get-File ($url, $dest, $label) {
    Write-Cyan "Downloading $label …"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Green "$label downloaded."
        return $true
    } catch {
        Write-Red "Failed to download $label`: $_"
        return $false
    }
}

Write-Host ""
Write-Cyan "=== ytget setup ==="
Write-Host ""

# ---- yt-dlp ----
if (Test-Path $ytdlpPath) {
    $ver = & $ytdlpPath --version 2>$null
    Write-Green "yt-dlp already installed ($ver)."
    Write-Yellow "  Tip: run option 4 in the menu to update it anytime."
} else {
    $ok = Get-File `
        "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" `
        $ytdlpPath `
        "yt-dlp"
    if (-not $ok) {
        Write-Red "Setup cannot continue without yt-dlp. Check your internet connection and try again."
        Read-Host "`nPress Enter to close"
        exit 1
    }
}

# ---- ffmpeg ----
if (Test-Path $ffmpegPath) {
    Write-Green "ffmpeg already installed."
} else {
    Write-Host ""
    Write-Yellow "ffmpeg not found — downloading (~120 MB, one-time). Please wait…"
    $zipUrl     = "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl.zip"
    $tmpZip     = Join-Path $env:TEMP "ffmpeg-ytget.zip"
    $tmpExtract = Join-Path $env:TEMP "ffmpeg-ytget-extract"

    if (Get-File $zipUrl $tmpZip "ffmpeg archive") {
        Write-Cyan "Extracting ffmpeg.exe …"
        try {
            if (Test-Path $tmpExtract) { Remove-Item $tmpExtract -Recurse -Force }
            Expand-Archive -Path $tmpZip -DestinationPath $tmpExtract -Force
            $exe = Get-ChildItem -Path $tmpExtract -Recurse -Filter "ffmpeg.exe" |
                   Select-Object -First 1
            if ($exe) {
                Copy-Item $exe.FullName -Destination $ffmpegPath -Force
                Write-Green "ffmpeg installed."
            } else {
                Write-Red "Could not find ffmpeg.exe inside the downloaded archive."
            }
        } catch {
            Write-Red "Extraction failed: $_"
        } finally {
            Remove-Item $tmpZip     -ErrorAction SilentlyContinue
            Remove-Item $tmpExtract -Recurse -ErrorAction SilentlyContinue
        }
    }
}

# ---- final check ----
Write-Host ""
$allGood = $true

if (Test-Path $ytdlpPath)  { Write-Green "✓ yt-dlp  : $( & $ytdlpPath --version 2>$null )" }
else                        { Write-Red   "✗ yt-dlp  : NOT found"; $allGood = $false }

if (Test-Path $ffmpegPath) {
    $v = & $ffmpegPath -version 2>&1 | Select-Object -First 1
    Write-Green "✓ ffmpeg  : $v"
} else {
    Write-Red "✗ ffmpeg  : NOT found"; $allGood = $false
}

Write-Host ""
if ($allGood) {
    Write-Green "Setup complete! Double-click ytget.bat to start."
} else {
    Write-Red "Setup finished with errors. Check messages above, fix, and run setup.bat again."
}

Write-Host ""
Read-Host "Press Enter to close"
