# =================================================
# LOCAlbum - Offline Photo Album - Generator (2025)
# =================================================

$root         = Split-Path -Parent $MyInvocation.MyCommand.Path
$base         = Join-Path $root "Fotos"
$templatePath = Join-Path $root "template.html"
$iniPath      = Join-Path $root "config.ini"

Write-Host ""
Write-Host "====================================================="
Write-Host "           LOCALBUM - OFFLINE PHOTO ALBUM            "
Write-Host "====================================================="
Write-Host ""
Write-Host "Lendo fotos em: $base"
Write-Host ""

# --- tiny INI reader (flat) ---
$cfg = @{}
if (Test-Path $iniPath) {
  Get-Content $iniPath -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -match '^\s*#') { return }
    if ($line -match '^\[') { return }
    if ($line -match '^\s*$') { return }
    $kv = $line -split '=', 2
    if ($kv.Count -eq 2) {
      $k = $kv[0].Trim().ToLower()
      $v = $kv[1].Trim()
      $cfg[$k] = $v
    }
  }
} else {
  Write-Host "⚠️  config.ini não encontrado — serão usados valores padrão."
}

# Defaults
function Sanitize($val, $def) {
    if ([string]::IsNullOrWhiteSpace($val)) { return $def }
    return ($val -replace '[:=]+','').Trim()
}
$cfg['language']     = Sanitize $cfg['language']     'pt'
$cfg['display_name'] = Sanitize $cfg['display_name'] 'Memórias'
$cfg['page_title']   = Sanitize $cfg['page_title']   'Offline Photo Album'
$cfg['birthdate']    = Sanitize $cfg['birthdate']    ''
$cfg['theme']        = Sanitize $cfg['theme']        'dark'
$cfg['donate_url']   = Sanitize $cfg['donate_url']   'https://www.paypal.me/rubsil'
$cfg['author']       = Sanitize $cfg['author']       'Rúben Silva'
$cfg['project_name'] = Sanitize $cfg['project_name'] 'Offline Photo Album'

# Nome de saída (dependente do idioma)
if ($cfg['language'] -eq 'en') {
    $outName = "View album.html"
} else {
    $outName = "Ver album.html"
}
$out = Join-Path (Split-Path $root -Parent) $outName

Write-Host "Gerando HTML em: $out"
Write-Host ""

# -------------------------------
# Date helpers
# -------------------------------
function Get-DateFromName($name) {
    $clean = $name -replace '^\d+\s*-\s*','' -replace ',','' -replace '\.\w+$',''
    $m = [regex]::Match($clean, '(\d{1,2})\s+(?:de\s+)?([\p{L}]+)\s+(?:de\s+)?(\d{4})')
    if (-not $m.Success) { return $null }

    $dia     = [int]$m.Groups[1].Value
    $mesNome = $m.Groups[2].Value.ToLower()
    $ano     = [int]$m.Groups[3].Value

    $meses = @{
        "janeiro"=1; "fevereiro"=2; "marco"=3; "março"=3; "abril"=4;
        "maio"=5; "junho"=6; "julho"=7; "agosto"=8; "setembro"=9;
        "outubro"=10; "novembro"=11; "dezembro"=12
    }

    $norm = $mesNome -replace '[ãâáàä]','a' -replace '[êéèë]','e' -replace '[îíìï]','i' `
                     -replace '[õôóòö]','o' -replace '[ûúùü]','u' -replace 'ç','c'

    if (-not $meses.ContainsKey($norm)) { return $null }

    try { return Get-Date -Year $ano -Month $meses[$norm] -Day $dia }
    catch { return $null }
}

# -------------------------------
# Build manifest
# -------------------------------
$manifest = @{}
if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base | Out-Null }

Get-ChildItem -Path $base -Directory | Sort-Object Name | ForEach-Object {
    $yearFolder = $_.Name
    if (-not $manifest.ContainsKey($yearFolder)) { $manifest[$yearFolder] = @{} }

    Get-ChildItem -Path $_.FullName -Directory | Sort-Object Name | ForEach-Object {
        $monthFolder = $_.Name
        $manifest[$yearFolder][$monthFolder] = @()

        Get-ChildItem -Path $_.FullName -File | Sort-Object Name | ForEach-Object {
            # define a data da foto
            # === determinar data da foto ===
$photoDate = $null

# 1️⃣ tentar extrair a data a partir do nome do ficheiro
$name = $_.Name

# formatos comuns de nomes (Pixel, Samsung, iPhone, etc.)
# exemplos: IMG_20230612_154322.jpg, PXL_20241201_194253935.jpg, 2020-08-14_12-34-56.jpg
$patterns = @(
    '(\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})',  # 20230612_154322
    '(\d{4})(\d{2})(\d{2})[_-]',                       # 20230612_
    '(\d{8})[_-]',                                     # 20230612-
    '(\d{4})[-_](\d{2})[-_](\d{2})',                   # 2023-06-12
    'PXL_(\d{4})(\d{2})(\d{2})_',                      # PXL_20241201_
    'IMG_(\d{4})(\d{2})(\d{2})',                       # IMG_20230612
    'VID_(\d{4})(\d{2})(\d{2})',                       # vídeos
    'PHOTO_(\d{4})(\d{2})(\d{2})'                      # Google Photos exports
)

foreach ($pat in $patterns) {
    if ($name -match $pat) {
        try {
            $y = [int]$matches[1]; $m = [int]$matches[2]; $d = [int]$matches[3]
            $photoDate = (Get-Date -Year $y -Month $m -Day $d).ToString("yyyy-MM-dd")
            break
        } catch { }
    }
}

# 2️⃣ se não encontrou no nome, tentar via EXIF (mais lento)
if (-not $photoDate) {
    try {
        $img = [System.Drawing.Image]::FromFile($_.FullName)
        $prop = $img.GetPropertyItem(36867)  # DateTaken
        $dateTaken = [System.Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0)
        $img.Dispose()

        $dt = [datetime]::ParseExact($dateTaken, "yyyy:MM:dd HH:mm:ss", $null)
        $photoDate = $dt.ToString("yyyy-MM-dd")
    } catch {
        $photoDate = $null
    }
}

# 3️⃣ fallback final (caso nao tenha EXIF nem data no nome)
if (-not $photoDate) {
    $photoDate = $_.LastWriteTime.ToString("yyyy-MM-dd")
}


            # adiciona nome e caminho completo
            $manifest[$yearFolder][$monthFolder] += [PSCustomObject]@{
                name = $_.Name
                path = "Album/Fotos/$yearFolder/$monthFolder/$($_.Name)"
                date = $photoDate
            }
        }
    }
}


# -------------------------------
# Inject into template
# -------------------------------
if (-not (Test-Path $templatePath)) {
    Write-Host "❌ ERRO: template.html não encontrado em $templatePath"
    pause
    exit
}

# Prepare CONFIG + MANIFEST JS
$configObj = [ordered]@{
  language     = $cfg['language']
  displayName  = $cfg['display_name']
  pageTitle    = $cfg['page_title']
  birthdate    = $cfg['birthdate']
  theme        = $cfg['theme']
  donateURL    = $cfg['donate_url']
  author       = $cfg['author']
  projectName  = $cfg['project_name']
}
$CONFIG   = "const CONFIG = "   + (ConvertTo-Json $configObj -Compress) + ";"
$MANIFEST = "const manifest = " + (ConvertTo-Json $manifest -Depth 6 -Compress) + ";"

$template  = Get-Content -Raw $templatePath -Encoding UTF8
$htmlFinal = $template -replace '<!--CONFIG-->',   $CONFIG `
                       -replace '<!--MANIFEST-->', $MANIFEST

# adiciona ícone personalizado (favicon)
$favicon = '<link rel="icon" type="image/png" href="Album/favicon.png"/>'
$htmlFinal = $htmlFinal -replace '(<title>Offline Photo Album</title>)', "`$1`r`n  $favicon"

Set-Content -Path $out -Value $htmlFinal -Encoding UTF8

Write-Host ""
Write-Host "✅ LOCAlbum gerou com sucesso em: $out"
Write-Host ""
Write-Host "Pressiona Enter para fechar..."
pause > $null

