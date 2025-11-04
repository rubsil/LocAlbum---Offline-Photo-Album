@echo off
chcp 65001 >nul
title LOCALBUM Manager - Offline Photo Album
setlocal EnableDelayedExpansion EnableExtensions

:: =====================================================
::  LOCALBUM - OFFLINE PHOTO ALBUM (versão 2025.11)
::  Autor: Rúben Silva
:: =====================================================

:: --- Verificar privilégios de administrador ---
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo ⚠️  A executar novamente como Administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "INI=%ROOT%\config.ini"
set "PWSH=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PWSH%" set "PWSH=powershell.exe"

:: =====================================================
::  OCULTAR ficheiros técnicos logo ao arrancar
:: =====================================================
for %%A in (z1.ps1 z3.ps1 template.html favicon.png) do (
  if exist "%ROOT%\%%A" (
    attrib +h +s "%ROOT%\%%A" >nul 2>&1
  )
)

:: =====================================================
::  SELECIONAR LÍNGUA
:: =====================================================
cls
echo =====================================================
echo              LOCALBUM - OFFLINE PHOTO ALBUM
echo =====================================================
echo.
echo 🌍 Escolhe o idioma / Choose language:
echo [1] PT  → Português
echo [2] EN  → English
echo.
set /p LANG_CHOICE="Seleciona uma opção / Choose (1 / 2): "
if "%LANG_CHOICE%"=="2" (
    set "LANG=en"
) else (
    set "LANG=pt"
)

cls
if "%LANG%"=="pt" (
    goto MENU_PT
) else (
    goto MENU_EN
)

:: =====================================================
::  MENU PORTUGUÊS
:: =====================================================
:MENU_PT
cls
echo =====================================================
echo        LOCALBUM - Gestor do Álbum Offline
echo =====================================================
echo.
echo [1] Organizar fotos automaticamente - (ideal para centenas/milhares de fotos)
echo [2] Atualizar / Criar álbum (HTML)  - (cria o Ver album.html ou atualiza um já criado)
echo [3] Repor / Resetar o álbum         - (repõe as definições do Álbum, NÃO apaga fotos/vídeos)
echo [i] Informações / Ajuda             - (explicações gerais)
echo [0] Sair
echo.
echo =====================================================
set /p op="Escolhe uma opção: "

if /i "%op%"=="1" goto ORGANIZE
if /i "%op%"=="2" goto GENERATE
if /i "%op%"=="3" goto RESET
if /i "%op%"=="i" goto INFO
if "%op%"=="0" exit
goto MENU_PT

:: =====================================================
::  MENU INGLÊS
:: =====================================================
:MENU_EN
cls
echo =====================================================
echo        LOCALBUM - Offline Album Manager
echo =====================================================
echo.
echo [1] Auto-organize photos          - (ideal for hundreds/thousands of photos)
echo [2] Update / Create album (HTML)  - (creates or updates “View album.html”)
echo [3] Reset album                   - (resets album settings, keeps all photos)
echo [i] Information / Help            - (how it all works)
echo [0] Exit
echo.
echo =====================================================
set /p op="Choose an option: "

if /i "%op%"=="1" goto ORGANIZE
if /i "%op%"=="2" goto GENERATE
if /i "%op%"=="3" goto RESET
if /i "%op%"=="i" goto INFO
if "%op%"=="0" exit
goto MENU_EN


:: =====================================================
::  INFO / AJUDA DETALHADA
:: =====================================================
:INFO
cls
if "%LANG%"=="pt" goto INFO_PT
goto INFO_EN

:INFO_PT
echo =====================================================
echo 📘 INFORMAÇÕES / AJUDA - LOCALBUM
echo =====================================================
echo Versão 2025.11 — Rúben Silva
echo =====================================================
echo.
echo LOCALBUM organiza as tuas fotos por ano e mês automaticamente e cria um álbum HTML offline
echo que pode ser aberto/visto em PCs, Smart TVs (com navegador compatível) ou em macOS/Linux.
echo.
echo ================== EXPLICAÇÃO DE CADA OPÇÃO ==================
echo.
echo ► [1] ORGANIZAR FOTOS AUTOMATICAMENTE
echo      - Escolhe a pasta com as tuas fotos (podem estar também em subpastas) e define "Album\Fotos"
echo        como pasta de destino para que fiquem disponíveis para o LOCALBUM as visualizar.
echo      - Cria automaticamente as subpastas por ANO e MÊS.
echo      - Se encontrar ficheiros exatamente iguais, estes são ignorados.
echo      - Primeiro, esta ferramenta tenta detetar a data de cada foto pelo nome do ficheiro original;
echo        caso contrário, usa a data em que a foto foi tirada (guardada nas propriedades do ficheiro).
echo        Este último método pode tornar o processo um pouco mais demorado, mas é automático.
echo      - Mais tarde, se o utilizador quiser adicionar mais fotos a "Album\Fotos", pode fazê-lo
echo        manualmente (mantendo sempre a estrutura Ano\Mês) ou voltar a usar esta opção se forem muitas.
echo.
echo ► [2] ATUALIZAR / CRIAR ÁLBUM
echo      - Esta opção cria ou atualiza o "Ver album.html" com as fotos previamente organizadas
echo        dentro da pasta "Album\Fotos".
echo      - Caso não exista configuração (primeira utilização), será pedido ao utilizador que
echo        responda a duas perguntas para criar automaticamente o álbum.
echo      - Depois da primeira utilização, sempre que adicionar mais fotos em Album\Fotos,
echo        deve correr novamente esta opção para que o LOCALBUM detete as novas fotos e atualize
echo        o ficheiro "Ver album.html". Por isso, esta opção faz as duas funções (Atualizar e Criar).
echo.
echo ► [3] REPOR / RESETAR O ÁLBUM
echo      - Apaga os ficheiros HTML antigos e a configuração criada pela opção [2].
echo        Esta opção NÃO apaga as tuas fotos nem vídeos da pasta "Album\Fotos".
echo        Serve apenas para repor o LOCALBUM ao estado original, como se fosse novo.
echo        Depois, basta voltar a correr a opção [2] para criar tudo novamente.
echo.
echo ► [i] INFORMAÇÕES / AJUDA
echo      - Mostra esta explicação. Tudo é offline — nada é enviado/recebido da Internet.
echo.
echo =====================================================
echo NOTA:
echo O ficheiro "Ver album.html" (ou "View album.html" em inglês) é criado na pasta
echo diretamente acima da pasta "Album".
echo =====================================================
echo.
echo Prima qualquer tecla para voltar ao menu...
pause >nul
goto MENU_PT


:INFO_EN
echo =====================================================
echo 📘 INFORMATION / HELP - LOCALBUM
echo =====================================================
echo Version 2025.11 — Ruben Silva
echo =====================================================
echo.
echo LOCALBUM automatically organizes your photos by year and month and creates an offline HTML album
echo that can be opened/viewed on PCs, Smart TVs (with a compatible browser), or macOS/Linux systems.
echo.
echo ================== EXPLANATION OF EACH OPTION ==================
echo.
echo ► [1] AUTO-ORGANIZE PHOTOS
echo      - Choose the folder containing your photos (they can also be inside subfolders) and set
echo        "Album\Fotos" as the destination so that LOCALBUM can access and display them.
echo      - It automatically creates subfolders by YEAR and MONTH.
echo      - If it finds identical files (same name and size), they are ignored.
echo      - This tool first detects each photo’s date from its filename if possible; otherwise,
echo        it uses the date when the photo was actually taken (from file metadata).
echo        The latter method may take a bit longer, but LOCALBUM handles this automatically.
echo      - Later, if you add more photos to "Album\Fotos", you can do it manually (keeping the
echo        correct Year\Month folder structure) or rerun this tool again if there are many.
echo.
echo ► [2] UPDATE / CREATE ALBUM
echo      - This option creates or updates the "View album.html" file using all the photos
echo        organized inside the "Album\Fotos" folder.
echo      - If no configuration exists (first-time use), it will ask you two quick questions
echo        to automatically generate your personalized album.
echo      - After the first creation, whenever you add more photos to Album\Fotos, you must
echo        run this option again so LOCALBUM detects the new photos and updates the album.
echo        That’s why this option performs both functions (Create + Update).
echo.
echo ► [3] RESET ALBUM
echo      - Deletes old HTML files and configuration created by option [2].
echo        It does NOT delete your photos or videos in "Album\Fotos".
echo        This simply resets LOCALBUM to its original state, as if it was never used.
echo        After using this option, run [2] again to re-enter your information.
echo.
echo ► [i] INFORMATION / HELP
echo      - Displays this explanation window.
echo        Everything runs 100%% offline — nothing is sent to or received from the Internet.
echo.
echo =====================================================
echo NOTE:
echo The generated album file "View album.html" (or "Ver album.html" in Portuguese)
echo is created in the folder directly above the "Album" folder.
echo =====================================================
echo.
echo Press any key to return to the menu...
pause >nul
goto MENU_EN


:: =====================================================
::  ORGANIZE PHOTOS
:: =====================================================
:ORGANIZE
cls
if "%LANG%"=="pt" (
  echo [INFO] A iniciar o organizador de fotos...
) else (
  echo [INFO] Starting photo organizer...
)
echo.
if not exist "%ROOT%\z3.ps1" (
  echo [ERRO] Ficheiro z3.ps1 nao encontrado!
  pause
  if "%LANG%"=="pt" (goto MENU_PT) else (goto MENU_EN)
)
"%PWSH%" -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; & '%ROOT%\z3.ps1' -lang '%LANG%'"
if "%LANG%"=="pt" (goto MENU_PT) else (goto MENU_EN)

:: =====================================================
::  GENERATE / UPDATE ALBUM
:: =====================================================
:GENERATE
cls
if "%LANG%"=="pt" (
  echo [INFO] A gerar / atualizar o álbum...
) else (
  echo [INFO] Generating / updating album...
)
echo.
if not exist "%ROOT%\z1.ps1" (
  echo [ERRO] Ficheiro z1.ps1 nao encontrado!
  pause
  if "%LANG%"=="pt" (goto MENU_PT) else (goto MENU_EN)
)
"%PWSH%" -ExecutionPolicy Bypass -File "%ROOT%\z1.ps1"
if "%LANG%"=="pt" (goto MENU_PT) else (goto MENU_EN)

:: =====================================================
::  RESET / REINICIAR
:: =====================================================
:RESET
cls
if "%LANG%"=="pt" (
  echo [INFO] A repor o álbum LOCALBUM...
  echo Este processo irá apagar o ficheiro de configuração e os ficheiros HTML.
  echo As tuas fotos em "Album/Fotos" NÃO serão apagadas.
  echo.
  choice /c SN /m "Queres continuar?"
  if errorlevel 2 (echo Operação cancelada.&timeout /t 2 >nul&goto MENU_PT)
  attrib -h -s "%INI%" >nul 2>&1
  del /f /q "%INI%" >nul 2>&1
  del /f /q "%ROOT%\..\Ver album.html" >nul 2>&1
  del /f /q "%ROOT%\..\View album.html" >nul 2>&1
  echo [OK] Reset concluído com sucesso!
  pause
  goto MENU_PT
) else (
  echo [INFO] Resetting LOCALBUM...
  echo This will delete configuration and HTML files.
  echo Your photos in "Album/Fotos" will remain untouched.
  echo.
  choice /c YN /m "Do you want to continue?"
  if errorlevel 2 (echo Operation cancelled.&timeout /t 2 >nul&goto MENU_EN)
  attrib -h -s "%INI%" >nul 2>&1
  del /f /q "%INI%" >nul 2>&1
  del /f /q "%ROOT%\..\Ver album.html" >nul 2>&1
  del /f /q "%ROOT%\..\View album.html" >nul 2>&1
  echo [OK] Reset completed successfully!
  pause
  goto MENU_EN
)
