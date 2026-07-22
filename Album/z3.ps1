# =================================================
# LOCALBUM - Offline Photo Album - Organizer
# =================================================

param(
    [string]$lang = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# --- Garantir modo STA (necessário em Windows 11 para System.Drawing e Forms) ---
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Write-Host "[INFO] Reiniciando o script em modo STA (necessario para W11)..."
    powershell.exe -STA -ExecutionPolicy Bypass -File "$PSCommandPath" -lang "$lang"
    exit
}

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
} catch {
    Write-Host "[AVISO] Alguns componentes visuais nao puderam ser carregados." -ForegroundColor Yellow
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$iniPath = Join-Path $root "config.ini"

# -------------------------------
# Determinar idioma
# -------------------------------
if (-not $lang) { $lang = "pt" }

if (Test-Path $iniPath) {
    try {
        $cfg = Get-Content $iniPath -Encoding UTF8 | Where-Object {$_ -match "="}
        foreach ($line in $cfg) {
            $kv = $line -split "=", 2
            if ($kv[0].Trim().ToLower() -eq "language" -and -not $lang) {
                $lang = $kv[1].Trim().ToLower()
            }
        }
    } catch { }
}

# -------------------------------
# Mensagens multilíngua
# -------------------------------
if ($lang -eq "en") {
    $msg_select_source = "Select the folder containing your photos to organize"
    $msg_select_dest   = "Select the destination folder for your photos (default: Album\Fotos)"
    $msg_cancel        = "No folder selected. Exiting..."
    $msg_done          = "[OK] Organization complete! Photos were grouped by year and month folders."
    $msg_reminder      = ">>> Remember to go back to the LOCALBUM Manager and run OPTION 2 to create or update your album."
    $msg_no_exif       = "No EXIF or valid date - moved to manual folder"
    $msg_start         = "[INFO] Starting photo organization..."
    $noDateFolderName  = "__FILES_WITHOUT_DATE - CHECK_MANUALLY"
    $ci = [System.Globalization.CultureInfo]::GetCultureInfo("en-GB")
}
else {
    $msg_select_source = "Escolhe a pasta com as fotos a organizar"
    $msg_select_dest   = "Escolhe a pasta de destino (por defeito: Album\Fotos)"
    $msg_cancel        = "Nenhuma pasta selecionada. A sair..."
    $msg_done          = "[OK] Organizacao concluida! As fotos foram agrupadas por pastas de ano e mes."
    $msg_reminder      = ">>> Nao te esquecas de voltar ao Gestor LOCALBUM e correr a OPCAO [2] para criar ou atualizar o album."
    $msg_no_exif       = "Sem data (nome/EXIF) - movido para pasta manual"
    $msg_start         = "[INFO] A iniciar a organizacao das fotos..."
    $noDateFolderName  = "__FICHEIROS_SEM_DATA - VERIFICAR_MANUALMENTE"
    $ci = [System.Globalization.CultureInfo]::GetCultureInfo("pt-PT")
}

Write-Host ""
Write-Host $msg_start
Write-Host "-------------------------------------------"

# Verificar exiftool — primeiro na pasta local, depois no PATH
$exiftoolLocal = Join-Path $root "exiftool.exe"
if (Test-Path $exiftoolLocal) {
    $env:PATH = "$root;$env:PATH"  # garante que o script o encontra
} elseif (-not (Get-Command exiftool -ErrorAction SilentlyContinue)) {
    if ($lang -eq "en") {
        Write-Host "[WARNING] exiftool not found - dates for some videos may be inaccurate"
        Write-Host "          Download from https://exiftool.org and place exiftool.exe in the Album folder"
        $open = Read-Host "Open download page now? (Y/N)"
        if ($open -eq "Y") { Start-Process "https://exiftool.org" }
    } else {
        Write-Host "[AVISO] exiftool nao encontrado - datas de alguns videos podem ser imprecisas"
        Write-Host "        Descarrega em https://exiftool.org e coloca o exiftool.exe na pasta Album"
        $open = Read-Host "Abrir pagina de download agora? (S/N)"
        if ($open -eq "S") { Start-Process "https://exiftool.org" }
    }
}

# -------------------------------
# Função: Escolher pasta (sempre no topo)
# -------------------------------
function Select-FolderDialog([string]$description,[string]$initialPath=$null){
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    $d.Description = $description
    $d.ShowNewFolderButton = $true
    if($initialPath -and (Test-Path $initialPath)){
        try { $d.SelectedPath = (Resolve-Path $initialPath) } catch {}
    }

    $top = New-Object System.Windows.Forms.Form
    $top.TopMost = $true
    $top.ShowInTaskbar = $false
    $top.StartPosition = "CenterScreen"

    $res = $d.ShowDialog($top)
    $top.Dispose()

    if($res -eq [System.Windows.Forms.DialogResult]::OK){
        return $d.SelectedPath
    } else {
        return $null
    }
}

# -------------------------------
# Seleção de pastas
# -------------------------------
$src = Select-FolderDialog $msg_select_source
if(-not $src){ Write-Host $msg_cancel; pause; exit }

$defaultDest = Join-Path $root "Fotos"
$dst = Select-FolderDialog $msg_select_dest $defaultDest
if(-not $dst){ Write-Host $msg_cancel; pause; exit }


# ✅ Inicializar Explorer Shell
$global:ShellApp = New-Object -ComObject Shell.Application

# -------------------------------
# Função: Obter data inteligente
# -------------------------------
function Get-DateSmart($f){
    $n   = $f.Name
    $ext = [System.IO.Path]::GetExtension($n).ToLowerInvariant()
    $d   = $null

    # 1️⃣ Detecção por nome do ficheiro
    $pats = @(
        '(\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})',
        '(\d{4})(\d{2})(\d{2})[_-]',
        '(\d{8})[_-]',
        '(\d{4})[-_](\d{2})[-_](\d{2})',
        'PXL_(\d{4})(\d{2})(\d{2})_',
        'IMG_(\d{4})(\d{2})(\d{2})',
        'MVIMG_(\d{4})(\d{2})(\d{2})',
        'Screenshot_(\d{4})(\d{2})(\d{2})',
        'VID_(\d{4})(\d{2})(\d{2})_WA',
        '202\d(\d{2})(\d{2})_(\d{6})',
        'IMG_(\d{4})(\d{2})(\d{2})_(\d{6})',
        'IMG-(\d{4})(\d{2})(\d{2})-WA',
        'GOPR(\d{4})(\d{2})(\d{2})',
        'GH(\d{4})(\d{2})(\d{2})',
        'DSC_(\d{4})(\d{2})(\d{2})',
        'DSC(\d{4})(\d{2})(\d{2})',
        'DSC\d+_(\d{4})(\d{2})(\d{2})',
        'IMG_(\d{4})(\d{2})(\d{2})_(?:\d{6})',
        '(\d{4})(\d{2})(\d{2})'
    )

    foreach($p in $pats){
        if($n -match $p){
            try {
                $y=[int]$matches[1]; $m=[int]$matches[2]; $day=[int]$matches[3]
                return (Get-Date -Year $y -Month $m -Day $day)
            } catch {}
        }
    }

# 2️⃣ Data via exiftool
try {
    $exifDate = & exiftool `
        -DateTimeOriginal `
        -CreateDate `
        -MediaCreateDate `
        -TrackCreateDate `
        -s -s -s `
        -d "%Y-%m-%d %H:%M:%S" `
        $f.FullName | Select-Object -First 1

    if ($exifDate) {
        Write-Host "[EXIF SMART]" $exifDate
        return [datetime]::Parse($exifDate)
    }
}
catch {}

# 3️⃣ Windows Date Taken
try {
    $folder = $global:ShellApp.Namespace($f.DirectoryName)
    $item   = $folder.ParseName($f.Name)

    # índices comuns para datas media
    $indexes = @(12,208,206,204)

    foreach ($idx in $indexes) {

        $raw = $folder.GetDetailsOf($item, $idx)

        if ($raw) {

            Write-Host "[WINDOWS RAW idx=$idx]" $raw

            $clean = $raw -replace '[^\d/: ]',''

            try {
                $culture = [System.Globalization.CultureInfo]::CurrentCulture
                $dt = [datetime]::Parse($clean, $culture)

                Write-Host "[WINDOWS DATE OK]" $dt
                return $dt
            }
            catch {}
        }
    }
}
catch {}



    # 4 Sem data válida
    return $null
}

# -------------------------------
# Processar ficheiros
# -------------------------------
$files = Get-ChildItem -Path $src -Include *.jpg,*.jpeg,*.png,*.gif,*.webp,*.tif,*.tiff,*.heic,*.heif,
        *.mp4,*.mov,*.webm,*.mkv,*.avi,*.mts,*.m2ts,*.3gp,*.hevc -Recurse

$heicCount = ($files | Where-Object { $_.Extension -match '\.(heic|heif)$' }).Count
if ($heicCount -gt 0 -and -not (Get-Command exiftool -ErrorAction SilentlyContinue)) {
    if ($lang -eq "en") {
        Write-Host "[WARNING] $heicCount HEIC file(s) found. Without exiftool, dates may not be detected."
        Write-Host "          Also note: HEIC may not display in Chrome/Firefox on Windows."
    } else {
        Write-Host "[AVISO] $heicCount ficheiro(s) HEIC encontrado(s). Sem exiftool, datas podem nao ser detetadas."
        Write-Host "        Nota: HEIC pode nao exibir no Chrome/Firefox no Windows."
    }
    Write-Host ""
}

foreach($f in $files){
    $dt = Get-DateSmart $f

    if (-not $dt) {
        $no = Join-Path $dst $noDateFolderName
        if (!(Test-Path $no)) { New-Item -ItemType Directory -Path $no -Force | Out-Null }
        $target = Join-Path $no $f.Name
        if (-not (Test-Path $target)) {
            Copy-Item $f.FullName -Destination $target
            Write-Host "[WARN] $msg_no_exif : $($f.Name)"
        }
        continue
    }

    $now = Get-Date
    if ($dt -gt $now.AddYears(1) -or $dt.Year -lt 1970) {
        $no = Join-Path $dst $noDateFolderName
        if (!(Test-Path $no)) { New-Item -ItemType Directory -Path $no -Force | Out-Null }
        $target = Join-Path $no $f.Name
        if (-not (Test-Path $target)) {
            Copy-Item $f.FullName -Destination $target
            Write-Host "[WARN] Data invalida ($($dt)) -> movido para: $noDateFolderName ($($f.Name))"
        }
        continue
    }

    $year  = $dt.Year
    $month = $dt.ToString("MMMM", $ci)
    $tgt   = Join-Path $dst "$year\$month"
    if (!(Test-Path $tgt)) { New-Item -ItemType Directory -Path $tgt -Force | Out-Null }

    $target = Join-Path $tgt $f.Name

    if (-not (Test-Path $target)) {
Copy-Item $f.FullName -Destination $target
        Write-Host "[OK] $($f.Name) -> $year\$month" -ForegroundColor Green
        # Descongelar pasta de destino
        $frozenFlag = Join-Path $tgt "_frozen.flag"
        if (Test-Path $frozenFlag) { Remove-Item $frozenFlag -Force }
    }
else {
    try {
        $hash1 = (Get-FileHash -Algorithm SHA1 -Path $f.FullName).Hash
        $hash2 = (Get-FileHash -Algorithm SHA1 -Path $target).Hash

        if ($hash1 -eq $hash2) {
            Write-Host "[SKIP] $($f.Name) (duplicado exato - mesmo conteudo)"
        }
        else {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
            $ext = [System.IO.Path]::GetExtension($f.Name)
            $dupIndex = 1
            do {
                $newName = "${baseName}_DUP$dupIndex$ext"
                $newTarget = Join-Path $tgt $newName
                $dupIndex++
            } while (Test-Path $newTarget)

            Copy-Item $f.FullName -Destination $newTarget
            Write-Host "[COPIADO] $($f.Name) (conteudo diferente, guardado como $newName)"
            # Descongelar pasta de destino
            $frozenFlag = Join-Path $tgt "_frozen.flag"
            if (Test-Path $frozenFlag) { Remove-Item $frozenFlag -Force }
        }
    }
    catch {
        Write-Host "[ERRO] Falha ao comparar hash de $($f.Name): $_" -ForegroundColor Red
    }
}
}

Write-Host ""
Write-Host "-------------------------------------------"
Write-Host $msg_done -ForegroundColor Green
Write-Host $msg_reminder
Write-Host ""
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
