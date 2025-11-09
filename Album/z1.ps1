# =================================================
# LOCAlbum - Offline Photo Album - Generator (2025)
# =================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# --- Auto-elevate to Administrator if needed ---
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[INFO] Reexecutando como Administrador..."
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`" @args"
    exit
}

# --- Garantir modo STA (necessário em Windows 11 para System.Drawing) ---
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Write-Host "[INFO] Reiniciando o script em modo STA (necessário para W11)..."
    powershell.exe -STA -ExecutionPolicy Bypass -File "$PSCommandPath" @args
    exit
}

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
  Write-Host "Nenhum ficheiro config.ini foi encontrado."
  Write-Host "Vamos criar um album novo com as tuas preferencias:"
  Write-Host ""

  $cfg = @{}

  Write-Host ""
  Write-Host "====================================================="
  Write-Host "Escolhe o idioma / Choose language:"
  Write-Host "[1] Portugues"
  Write-Host "[2] English"
  Write-Host "====================================================="
  $choice = Read-Host "Seleciona uma opcao [1-2]"
  switch ($choice) {
      "2" { $lang = "en" }
      default { $lang = "pt" }
  }
  $cfg['language'] = $lang
  Write-Host ""

  if ($cfg['language'] -eq 'en') {
    Write-Host ""
    Write-Host "Please enter two quick details to create your new album:"
    Write-Host ""

    # Show example screenshot (help)
    $screenshot = Join-Path $root "ajuda_album.png"
    if (Test-Path $screenshot) {
        # Mostrar screenshot explicativo numa janela controlada
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (Test-Path $screenshot) {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Ajuda - LOCALBUM"
        $form.StartPosition = "Manual"
        $form.Left = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - 840
        $form.Top  = 100
        $form.Width = 700
        $form.Height = 600
        $form.FormBorderStyle = 'FixedSingle'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true

        $pic = New-Object System.Windows.Forms.PictureBox
        $pic.Image = [System.Drawing.Image]::FromFile($screenshot)
        $pic.SizeMode = 'Zoom'
        $pic.Dock = 'Fill'

        $form.Controls.Add($pic)
        $form.Add_Shown({$form.Activate()})
        $null = $form.ShowDialog()
    } catch {
        # fallback caso haja erro, abre pelo método padrão
        Start-Process $screenshot
    }
}
        Write-Host ">>> An example image was opened to show where the title and age appear."
        Write-Host "Close the image window and continue here."
        Write-Host ""
    }

    $cfg['display_name'] = Read-Host "1/2 - Album name to show as Album title (ex: Ines Memories)"
    $cfg['birthdate']    = Read-Host "2/2 - Birthdate (OPTIONAL), ideal for albums with photos from birth onwards (YYYY-MM-DD)"
    $cfg['theme']        = "dark"
    $cfg['page_title']   = "LOCALBUM - Offline Photo Album"
    $cfg['donate_url']   = "https://www.paypal.me/rubsil"
    $cfg['author']       = "Ruben Silva"
    $cfg['project_name'] = "LOCALBUM - Offline Photo Album"
    Write-Host ""
    Write-Host "Configuration saved to config.ini"
  }
  else {
    Write-Host ""
    Write-Host "Introduz 2 dados rapidos para criar o teu novo album:"
    Write-Host ""

    # Mostrar screenshot explicativo
    $screenshot = Join-Path $root "ajuda_album.png"
    if (Test-Path $screenshot) {
        # Mostrar screenshot explicativo numa janela controlada
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

if (Test-Path $screenshot) {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Ajuda - LOCALBUM"
        $form.StartPosition = "Manual"
        $form.Left = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - 840
        $form.Top  = 100
        $form.Width = 700
        $form.Height = 600
        $form.FormBorderStyle = 'FixedSingle'
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.TopMost = $true

        $pic = New-Object System.Windows.Forms.PictureBox
        $pic.Image = [System.Drawing.Image]::FromFile($screenshot)
        $pic.SizeMode = 'Zoom'
        $pic.Dock = 'Fill'

        $form.Controls.Add($pic)
        $form.Add_Shown({$form.Activate()})
        $null = $form.ShowDialog()
    } catch {
        # fallback caso haja erro, abre pelo método padrão
        Start-Process $screenshot
    }
}
        Write-Host ">>> Uma imagem de exemplo foi aberta para mostrar onde o titulo e a idade aparecem."
        Write-Host "Fecha a imagem e continua aqui."
        Write-Host ""
    }

    $cfg['display_name'] = Read-Host "1/2 - Nome do album para mostrar como titulo (ex: Memorias da Ines)"
    $cfg['birthdate']    = Read-Host "2/2 - Data de nascimento (OPCIONAL), ideal para albuns com fotos desde a nascenca para mostrar a idade do bebe/crianca nas fotos (AAAA-MM-DD)"
    $cfg['theme']        = "dark"
    $cfg['page_title']   = "LOCALBUM - Offline Photo Album"
    $cfg['donate_url']   = "https://www.paypal.me/rubsil"
    $cfg['author']       = "Ruben Silva"
    $cfg['project_name'] = "LOCALBUM - Offline Photo Album"
    Write-Host ""
    Write-Host "Ficheiro config.ini criado com sucesso!"
  }


  # Gravar config.ini e ocultar
  $lines = @()
  foreach ($k in $cfg.Keys) { $lines += "$k=$($cfg[$k])" }
  Set-Content -Path $iniPath -Value $lines -Encoding UTF8
  attrib +h +s "$iniPath" > $null 2>&1
  Write-Host ""
  Write-Host "Ficheiro config.ini guardado e ocultado em:"
  Write-Host "  $iniPath"
  Write-Host ""
}

# Defaults (caso falte algo)
function Sanitize($val, $def) {
    if ([string]::IsNullOrWhiteSpace($val)) { return $def }
    return ($val -replace '[:=]+','').Trim()
}
$cfg['language']     = Sanitize $cfg['language']     'pt'
$cfg['display_name'] = Sanitize $cfg['display_name'] 'Memorias'
$cfg['page_title']   = Sanitize $cfg['page_title']   'LOCALBUM - Offline Photo Album'
$cfg['birthdate']    = Sanitize $cfg['birthdate']    ''
$cfg['theme']        = Sanitize $cfg['theme']        'dark'
$cfg['donate_url']   = Sanitize $cfg['donate_url']   'https://www.paypal.me/rubsil'
$cfg['author']       = Sanitize $cfg['author']       'Ruben Silva'
$cfg['project_name'] = Sanitize $cfg['project_name'] 'LOCALBUM - Offline Photo Album'

# Nome de saída (dependente do idioma)
if ($cfg['language'] -eq 'en') { $outName = "View album.html" } else { $outName = "Ver album.html" }
$out = Join-Path (Split-Path $root -Parent) $outName

Write-Host "Gerando HTML em: $out"
Write-Host ""

# -------------------------------
# Build manifest
# -------------------------------
$manifest = @{}
if (-not (Test-Path $base)) { New-Item -ItemType Directory -Path $base | Out-Null }

# Pastas a ignorar (PT e EN)
$foldersToIgnore = @(
    "__FICHEIROS_SEM_DATA - VERIFICAR_MANUALMENTE",
    "__FILES_WITHOUT_DATE - CHECK_MANUALLY"
)

Get-ChildItem -Path $base -Directory | Sort-Object Name | ForEach-Object {

    # Ignorar as pastas especiais de "sem data"
    if ($foldersToIgnore -contains $_.Name) { return }

    $yearFolder = $_.Name
    if (-not $manifest.ContainsKey($yearFolder)) { $manifest[$yearFolder] = @{} }


    Get-ChildItem -Path $_.FullName -Directory | Sort-Object Name | ForEach-Object {
        $monthFolder = $_.Name
        $manifest[$yearFolder][$monthFolder] = @()

        Get-ChildItem -Path $_.FullName -File | Sort-Object Name | ForEach-Object {
            $photoDate = $null
            $name = $_.Name

            $patterns = @(
                '(\d{4})(\d{2})(\d{2})[_-](\d{2})(\d{2})(\d{2})',
                '(\d{4})(\d{2})(\d{2})[_-]',
                '(\d{8})[_-]',
                '(\d{4})[-_](\d{2})[-_](\d{2})',
                'PXL_(\d{4})(\d{2})(\d{2})_',
                'IMG_(\d{4})(\d{2})(\d{2})',
                'VID_(\d{4})(\d{2})(\d{2})',
                'PHOTO_(\d{4})(\d{2})(\d{2})'
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

            if (-not $photoDate) {
                try {
                    $img = [System.Drawing.Image]::FromFile($_.FullName)
                    $prop = $img.GetPropertyItem(36867)
                    $dateTaken = [System.Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0)
                    $img.Dispose()
                    $dt = [datetime]::ParseExact($dateTaken, "yyyy:MM:dd HH:mm:ss", $null)
                    $photoDate = $dt.ToString("yyyy-MM-dd")
                } catch {
                    $photoDate = $null
                }
            }

            if (-not $photoDate) {
                $photoDate = $_.LastWriteTime.ToString("yyyy-MM-dd")
            }

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
    Write-Host "ERRO: template.html nao encontrado em $templatePath"
    pause
    exit
}

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

# Gerar favicon com versão dinâmica para forçar atualização no browser
$versionTag = (Get-Date).ToString("yyyyMMddHHmmss")
$favicon = "<link rel='icon' type='image/png' href='Album/favicon.png?v=$versionTag'/>"

# Injeta o favicon logo a seguir ao título do HTML
$htmlFinal = $htmlFinal -replace '(<title>LOCAlbum - Offline Photo Album</title>)', "`$1`r`n  $favicon"

Set-Content -Path $out -Value $htmlFinal -Encoding UTF8

Write-Host ""
Write-Host "LOCALBUM gerou com sucesso em: $out"
Write-Host ""
Write-Host "Pressiona Enter para fechar..."
pause > $null
