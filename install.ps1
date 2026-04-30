# memctl installer — Windows PowerShell
# Usage: iwr -useb https://raw.githubusercontent.com/vdg-solutions/memctl-releases/master/install.ps1 | iex

$ErrorActionPreference = 'Stop'
$Repo = 'vdg-solutions/memctl-releases'
$Prefix = if ($env:MEMCTL_PREFIX) { $env:MEMCTL_PREFIX } else { Join-Path $env:LOCALAPPDATA 'Programs\memctl' }

$Arch = (Get-CimInstance Win32_Processor).Architecture
$RID = switch ($Arch) {
    9  { 'win-x64' }
    12 { 'win-x64' }
    default { 'win-x64' }
}

Write-Host "[memctl] Resolving latest release..."
$Headers = @{ 'User-Agent' = 'memctl-installer' }
$Latest = (Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest" -Headers $Headers).tag_name
if (-not $Latest) { throw "Cannot resolve latest release" }

$Ver = $Latest.TrimStart('v')
$Asset = "memctl-$RID-$Ver.zip"
$Url = "https://github.com/$Repo/releases/download/$Latest/$Asset"

$Tmp = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid()))
try {
    $ZipPath = Join-Path $Tmp $Asset
    Write-Host "[memctl] Downloading $Asset..."
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath -Headers $Headers

    Write-Host "[memctl] Extracting to $Prefix..."
    if (-not (Test-Path $Prefix)) { New-Item -ItemType Directory -Path $Prefix -Force | Out-Null }
    Expand-Archive -Path $ZipPath -DestinationPath $Tmp -Force

    Copy-Item -Path (Join-Path $Tmp 'memctl.exe') -Destination (Join-Path $Prefix 'memctl.exe') -Force

    $SkillSrc = Join-Path $Tmp 'SKILL.md'
    if (Test-Path $SkillSrc) {
        $SkillDir = Join-Path $env:USERPROFILE '.claude\skills\memctl'
        if (-not (Test-Path $SkillDir)) { New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null }
        Copy-Item -Path $SkillSrc -Destination (Join-Path $SkillDir 'SKILL.md') -Force
        Write-Host "[memctl] Installed Claude Code skill at ~\.claude\skills\memctl\SKILL.md"
    }

    $UserPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($UserPath -notlike "*$Prefix*") {
        [Environment]::SetEnvironmentVariable('PATH', "$UserPath;$Prefix", 'User')
        Write-Host "[memctl] Added $Prefix to user PATH (open new terminal to pick up)"
    }

    Write-Host ""
    Write-Host "[memctl] Installed: $Prefix\memctl.exe ($Latest)"
    & (Join-Path $Prefix 'memctl.exe') --version
}
finally {
    Remove-Item -Path $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}
