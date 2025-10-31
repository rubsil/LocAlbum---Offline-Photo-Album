Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Escolher idioma
Write-Host "-------------------------------------------"
Write-Host " LOCAlbum - Organizar Fotos Automaticamente"
Write-Host "-------------------------------------------"
Write-Host ""
Write-Host "1. Portugues"
Write-Host "2. English"
$choice = Read-Host "Escolhe / Choose (1/2)"

if ($choice -eq "2") {
    $lang = "en-US"
    $msg_select_source = "Choose the folder with all your photos"
    $msg_select_dest = "Choose destination folder (ex: LOCAlbum\Fotos)"
    $msg_cancel = "No folder selected. Exiting..."
    $msg_done = "Done! Your photos are now organized by year and month."
    $msg_no_exif = "No EXIF date - skipped"
    $msg_start = "Starting photo organization..."
} else {
    $lang = "pt-PT"
    $msg_select_source = "Escolhe a pasta com as fotos a organizar"
    $msg_select_dest = "Escolhe a pasta de destino (ex: LOCAlbum\Fotos)"
    $msg_cancel = "Nenhuma pasta selecionada. A sair..."
    $msg_done = "Organizacao concluida! As fotos foram agrupadas por ano e mes."
    $msg_no_exif = "Sem data EXIF - ignorada"
    $msg_start = "A iniciar a organizacao de fotos..."
}
if ($lang -eq "en-US") {
    $noDateFolderName = "__FILES WITHOUT DATE - CHECK AND SORT MANUALLY"
} else {
    $noDateFolderName = "__FICHEIROS SEM DATA - VERIFICAR E ORDENAR MANUALMENTE"
}

function Select-FolderDialog($description) {
    $dialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $dialog.Description = $description
    $dialog.ShowNewFolderButton = $true
    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $dialog.SelectedPath
    } else {
        return $null
    }
}

Write-Host ""
Write-Host $msg_start
Write-Host "-------------------------------------------"

$sourceFolder = Select-FolderDialog $msg_select_source
if (-not $sourceFolder) { Write-Host $msg_cancel; Pause; exit }

$destFolder = Select-FolderDialog $msg_select_dest
if (-not $destFolder) { Write-Host $msg_cancel; Pause; exit }
Get-ChildItem -Path $sourceFolder -Include *.jpg, *.jpeg, *.png -Recurse | ForEach-Object {
    $file = $_.FullName
    $name = $_.Name
    try {
        $img = [System.Drawing.Image]::FromFile($file)
        $prop = $img.GetPropertyItem(36867) # DateTaken
        $dateTaken = [System.Text.Encoding]::ASCII.GetString($prop.Value).Trim([char]0)
        $img.Dispose()

        $dt = [datetime]::ParseExact($dateTaken, "yyyy:MM:dd HH:mm:ss", $null)
        $year = $dt.Year
        $month = $dt.ToString("MMMM", [System.Globalization.CultureInfo]::GetCultureInfo($lang))

        $targetPath = Join-Path -Path $destFolder -ChildPath "$year\$month"
        if (!(Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }

        Copy-Item $file -Destination $targetPath -Force
        Write-Host "[OK] $name -> $year\$month"
    }
    catch {
        # Pasta para ficheiros sem data
        $noDateFolder = Join-Path -Path $destFolder -ChildPath $noDateFolderName
        if (!(Test-Path $noDateFolder)) {
            New-Item -ItemType Directory -Path $noDateFolder -Force | Out-Null
        }

        # Copiar o ficheiro problemático para lá
        if (Test-Path $file) {
            Copy-Item $file -Destination $noDateFolder -Force
            Write-Warning ("{0}: {1}" -f $msg_no_exif, $name)
        }
    }
}

Write-Host ""
Write-Host "-------------------------------------------"
Write-Host $msg_done
Write-Host ""
Write-Host "Pressiona qualquer tecla para sair... / Press any key to exit..."
[System.Console]::ReadKey() | Out-Null
exit

