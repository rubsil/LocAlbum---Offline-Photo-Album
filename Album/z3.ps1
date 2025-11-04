# =================================================
# LOCALBUM - Offline Photo Album - Organizer
# =================================================

param(
    [string]$lang = ""
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $msg_no_exif       = "No EXIF date - moved to manual folder"
    $msg_start         = "[INFO] Starting photo organization..."
    $noDateFolderName  = "__FILES_WITHOUT_DATE - CHECK_MANUALLY"
    $ci = [System.Globalization.CultureInfo]::GetCultureInfo("en-GB")
}
else {
    $msg_select_source = "Escolhe a pasta com as fotos a organizar"
    $msg_select_dest   = "Escolhe a pasta de destino (por defeito: Album\Fotos)"
    $msg_cancel        = "Nenhuma pasta selecionada. A sair..."
    $msg_done          = "[OK] Organizacao concluida! As fotos foram agrupadas por pastas de ano e mes."
    $msg_no_exif       = "Sem data EXIF - movido para pasta manual"
    $msg_start         = "[INFO] A iniciar a organizacao das fotos..."
    $noDateFolderName  = "__FICHEIROS_SEM_DATA - VERIFICAR_MANUALMENTE"
    $ci = [System.Globalization.CultureInfo]::GetCultureInfo("pt-PT")
}

Write-Host ""
Write-Host $msg_start
Write-Host "-------------------------------------------"

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

    # Forçar a janela a aparecer no topo
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

# -------------------------------
# Função: Obter data inteligente
# -------------------------------
function Get-DateSmart($f){
    $n = $f.Name
    $d = $null
    $pats = @(
        '(\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})',
        '(\d{4})(\d{2})(\d{2})[_-]',
        '(\d{8})[_-]',
        '(\d{4})[-_](\d{2})[-_](\d{2})',
        'PXL_(\d{4})(\d{2})(\d{2})_',
        'IMG_(\d{4})(\d{2})(\d{2})',
        'VID_(\d{4})(\d{2})(\d{2})',
        'PHOTO_(\d{4})(\d{2})(\d{2})'
    )
    foreach($p in $pats){
        if($n -match $p){
            try {
                $y=[int]$matches[1];$m=[int]$matches[2];$day=[int]$matches[3]
                $d=Get-Date -Year $y -Month $m -Day $day
                break
            } catch {}
        }
    }
    if(-not $d){
        try {
            $img=[System.Drawing.Image]::FromFile($f.FullName)
            $prop=$img.GetPropertyItem(36867)
            $dt=[System.Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0)
            $img.Dispose()
            $d=[datetime]::ParseExact($dt,"yyyy:MM:dd HH:mm:ss",$null)
        } catch {
            $d=$null
        }
    }
    if(-not $d){ $d=$f.LastWriteTime }
    return $d
}

# -------------------------------
# Processar ficheiros
# -------------------------------
$files = Get-ChildItem -Path $src -Include *.jpg,*.jpeg,*.png,*.gif,*.webp,*.mp4,*.mov,*.webm -Recurse

foreach($f in $files){
    $dt = Get-DateSmart $f
    if(-not $dt){
        $no = Join-Path $dst $noDateFolderName
        if(!(Test-Path $no)){ New-Item -ItemType Directory -Path $no -Force | Out-Null }
        $target = Join-Path $no $f.Name
        if (-not (Test-Path $target)) {
            Copy-Item $f.FullName -Destination $target
            Write-Host "[WARN] $msg_no_exif : $($f.Name)"
        }
        continue
    }

    $year = $dt.Year
    $month = $dt.ToString("MMMM",$ci)
    $tgt = Join-Path $dst "$year\$month"

    if(!(Test-Path $tgt)){ New-Item -ItemType Directory -Path $tgt -Force | Out-Null }

    $target = Join-Path $tgt $f.Name

    # Agora IGNORA ficheiros duplicados (não cria _DUP)
    if (-not (Test-Path $target)) {
        Copy-Item $f.FullName -Destination $target
        Write-Host "[OK] $($f.Name) -> $year\$month"
    } else {
        Write-Host "[SKIP] $($f.Name) (já existe)"
    }
}

Write-Host ""
Write-Host "-------------------------------------------"
Write-Host $msg_done
Write-Host ""
Write-Host "Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
