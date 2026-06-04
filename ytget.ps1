# ytget.ps1 — video / audio / transcript downloader
# Run setup.bat first to install yt-dlp.exe and ffmpeg.exe

$version   = "v3"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding            = [System.Text.Encoding]::UTF8

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$ytdlp      = Join-Path $scriptDir "yt-dlp.exe"
$ffmpegDir  = $scriptDir   # ffmpeg.exe lives in the same folder

# Output folders — created next to this script
$videoDl  = Join-Path $scriptDir "video download"
$audioDl  = Join-Path $scriptDir "audio download"
$transcDl = Join-Path $scriptDir "transcript download"
foreach ($d in @($videoDl, $audioDl, $transcDl)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null }
}

# Archive files — re-running a playlist skips already-finished videos
$videoArchive = Join-Path $videoDl ".downloaded.txt"
$audioArchive = Join-Path $audioDl ".downloaded.txt"

# Output filename template
$outTpl = "%(title)s [%(id)s].%(ext)s"

# Flags shared by every download mode
$commonFlags = @(
    "--ignore-errors",
    "--no-overwrites",
    "--embed-metadata",
    "--ffmpeg-location", $ffmpegDir
)

# Current input list — set by Build-Inputs, read by every download mode
$script:Inputs = @()

function Write-Cyan  ($m) { Write-Host $m -ForegroundColor Cyan }
function Write-Red   ($m) { Write-Host $m -ForegroundColor Red }
function Write-Yellow($m) { Write-Host $m -ForegroundColor Yellow }

# Strip surrounding quotes (drag-and-drop adds them) and trim whitespace
function Clean-Str ($s) { return $s.Trim().Trim('"').Trim("'").Trim() }

# Build $script:Inputs from a cleaned string.
# If the whole string is an existing .txt file → batch mode (handles spaces in path).
# Otherwise split on whitespace — each token is a URL.
# Returns $true on success, $false on failure.
function Build-Inputs ($s) {
    $script:Inputs = @()
    if ([string]::IsNullOrWhiteSpace($s)) { Write-Red "No input given."; return $false }
    if ($s -like "*.txt" -and (Test-Path $s)) {
        $script:Inputs = @("-a", $s); return $true
    }
    $tokens = ($s -split '\s+') | Where-Object { $_ -ne '' }
    if ($tokens.Count -eq 0) { Write-Red "No valid URL or .txt file found."; return $false }
    $script:Inputs = @($tokens)
    return $true
}

# Prompt the user for URL(s) or a .txt path.
# Returns $true if input was given, $false if the user typed b to go back.
function Prompt-Input {
    $raw = Read-Host "URL(s) or .txt path  (b = back)"
    $c   = Clean-Str $raw
    if ($c -eq 'b' -or $c -eq 'B') { return $false }
    return (Build-Inputs $c)
}

# ---- download modes ----

function Invoke-Video ($height = "") {
    $fmt = if ($height) {
        "bv*[height<=$height]+ba/b[height<=$height]/bv*+ba/b"
    } else {
        "bv*+ba/b"
    }
    Write-Cyan "▶ Video → $videoDl"
    $inp = @($script:Inputs)
    & $ytdlp @commonFlags `
        "--download-archive" $videoArchive `
        "-P"                 $videoDl `
        "-f"                 $fmt `
        "--merge-output-format" "mp4" `
        "-o"                 $outTpl `
        @inp
}

function Invoke-Audio {
    Write-Cyan "♪ Audio (m4a) → $audioDl"
    $inp = @($script:Inputs)
    & $ytdlp @commonFlags `
        "--download-archive" $audioArchive `
        "-P"                 $audioDl `
        "--embed-thumbnail" `
        "-f"                 "bestaudio" `
        "-x" "--audio-format" "m4a" "--audio-quality" "0" `
        "-o"                 $outTpl `
        @inp
}

function Invoke-Transcript {
    Write-Cyan "✎ Transcript (en / zh / ja) → $transcDl"
    $inp    = @($script:Inputs)
    $before = @(Get-ChildItem $transcDl -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.Extension -in ".srt", ".vtt" }).Count
    & $ytdlp "--ignore-errors" `
        "-P"                  $transcDl `
        "--skip-download" `
        "--write-subs" "--write-auto-subs" `
        "--sub-langs"         "en,en-orig,en-US,zh-Hans,zh-CN,zh-Hant,zh-TW,zh-HK,ja" `
        "--convert-subs"      "srt" `
        "--sleep-requests"    "0.5" `
        "-o"                  $outTpl `
        @inp
    $after = @(Get-ChildItem $transcDl -Recurse -ErrorAction SilentlyContinue |
               Where-Object { $_.Extension -in ".srt", ".vtt" }).Count
    if ($after -le $before) {
        Write-Yellow "No subtitles found (en/zh/ja) — the video may not have CC enabled."
    }
}

function Invoke-Update {
    Write-Cyan "↻ Updating yt-dlp via pip…"
    $done = $false
    foreach ($cmd in @("python", "py", "python3")) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            & $cmd -m pip install -U yt-dlp; $done = $true; break
        }
    }
    if (-not $done) {
        Write-Red "python not found — update manually:  python -m pip install -U yt-dlp"
    }
    Write-Host ""
    Write-Cyan "yt-dlp: $( & $ytdlp --version 2>$null )"
    $ff = Join-Path $ffmpegDir "ffmpeg.exe"
    if (Test-Path $ff) {
        Write-Cyan "ffmpeg: $( & $ff -version 2>&1 | Select-Object -First 1 )"
    } else {
        Write-Red "ffmpeg NOT found at $ffmpegDir"
    }
}

# ---- home screen ----

function Show-Home {
    Write-Cyan "=== ytget $version ==="
    Write-Host "  1) Custom quality video"
    Write-Host "  2) Audio only (m4a)"
    Write-Host "  3) Transcript  (en / zh / ja)"
    Write-Host "  4) Update yt-dlp"
    Write-Host "  q) Quit"
    Write-Host ""

    $raw = Read-Host "Number or paste link(s)"
    $c   = Clean-Str $raw
    if ([string]::IsNullOrWhiteSpace($c)) { return }

    switch ($c) {
        "1" {
            $h = Clean-Str (Read-Host "Max height e.g. 720, 1080, 1440  (b = back)")
            if ($h -eq 'b') { return }
            if (Prompt-Input) { Invoke-Video $h }
        }
        "2" { if (Prompt-Input) { Invoke-Audio } }
        "3" { if (Prompt-Input) { Invoke-Transcript } }
        "4" { Invoke-Update }
        { $_ -eq "q" -or $_ -eq "Q" } { exit 0 }
        default {
            # direct paste of URL(s) → best quality video
            if (Build-Inputs $c) { Invoke-Video }
        }
    }
}

# ---- main loop ----

while ($true) {
    try {
        Show-Home
    } catch [System.Management.Automation.PipelineStoppedException] {
        exit 0   # Ctrl+C during a download → return to menu or exit cleanly
    }
    Write-Host ""
}
