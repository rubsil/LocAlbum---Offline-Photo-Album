@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title Update LOCALBUM

echo.
echo =====================================================
echo          LOCALBUM - OFFLINE PHOTO ALBUM
echo =====================================================
echo.

:: === detetar local atual ===
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

:: === caminhos importantes ===
set "PS1=%ROOT%\[1].ps1"
set "INI=%ROOT%\config.ini"

:: === garantir favicon ===
if not exist "%ROOT%\favicon.png" (
  if exist "%ROOT%\assets\favicon_base.png" (
    copy "%ROOT%\assets\favicon_base.png" "%ROOT%\favicon.png" >nul
    echo Favicon padrão criado.
  ) else (
    echo ⚠️ Nenhum favicon encontrado. O HTML será criado sem ícone.
  )
)

:: === verificar existencia do PowerShell script ===
if not exist "%PS1%" (
  echo.
  echo ERRO: O ficheiro PowerShell nao foi encontrado.
  echo Esperado em: "%PS1%"
  echo.
  pause
  exit /b 1
)

echo Pasta detetada: %ROOT%
echo.

:: ===== primeira execucao (cria config.ini oculto) =====
if not exist "%INI%" goto :first_run
goto :after_questions


:first_run
echo =====================================================
echo LOCALBUM Offline Photo Album - primeira configuracao
echo =====================================================
echo.

echo 🌍 Escolhe o idioma / Choose language:
echo [P] PT  → Português
echo [E] EN  → English
echo.

choice /c PE /m "Seleciona uma opção:"

if %errorlevel%==1 goto :ask_pt
if %errorlevel%==2 goto :ask_en


:ask_pt
set "LANG=pt"
cls
echo.
echo =====================================================
echo   Bem-vindo à configuração inicial do teu álbum :)
echo =====================================================
echo.
echo Vamos fazer-te algumas perguntas. Podes mudar tudo depois.
echo.
echo -----------------------------------------------------
set /p ALBUM_NAME="Título do álbum (ex.: Memórias do Martim): "
if "!ALBUM_NAME!"=="" set "ALBUM_NAME=Memórias"
echo -----------------------------------------------------
echo.
echo (OPCIONAL) Insere data de nascimento para mostrar a idade
echo            à data de cada foto visualizada.
echo            (Útil caso seja um bebé.)
echo   (Não insiras nada caso não queiras esta funcionalidade)
echo.
set /p BIRTHDATE="Data de nascimento (formato: AAAA-MM-DD): "
goto :write_ini


:ask_en
set "LANG=en"
cls
echo.
echo =====================================================
echo   Welcome to the initial album setup :)
echo =====================================================
echo.
echo We’ll ask you a few quick questions. You can change them later.
echo.
echo -----------------------------------------------------
set /p ALBUM_NAME="Album title (e.g., Memories of Emma): "
if "!ALBUM_NAME!"=="" set "ALBUM_NAME=Memories"
echo -----------------------------------------------------
echo.
echo (OPTIONAL) Enter date of birth to display the age
echo            as of the date of each viewed photo.
echo            (Useful if it’s a baby.)
echo   (Leave blank if you don’t want this feature)
echo.
set /p BIRTHDATE="Date of birth (format: YYYY-MM-DD): "
goto :write_ini


:write_ini
for /f "tokens=* delims=" %%A in ("!ALBUM_NAME!") do set "ALBUM_NAME=%%A"
for /f "tokens=* delims=" %%A in ("!BIRTHDATE!") do set "BIRTHDATE=%%A"

set "PAGE_TITLE=LOCALBUM - Offline Photo Album"
set "THEME=dark"
set "DONATE_URL=https://www.paypal.me/rubsil"
set "AUTHOR=Ruben Silva"
set "PROJECT=LOCALBUM - Offline Photo Album"

(
echo [album]
echo language=%LANG%
echo display_name=%ALBUM_NAME%
echo page_title=%PAGE_TITLE%
echo birthdate=%BIRTHDATE%
echo theme=%THEME%
echo donate_url=%DONATE_URL%
echo author=%AUTHOR%
echo project_name=%PROJECT%
)>"%INI%"

attrib +h "%INI%"
echo.
goto :after_questions


:after_questions
if not defined LANG set "LANG=pt"

echo.
if /I "!LANG!"=="en" (
  echo Reading photos from: "%ROOT%\Fotos"
  echo Generating HTML at:  "%ROOT%\album.html"
) else (
  echo Lendo fotos em: "%ROOT%\Fotos"
  echo Gerando HTML em:  "%ROOT%\album.html"
)
echo.

:: === chamar PowerShell ===
set "PWSH=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PWSH%" set "PWSH=powershell.exe"

"%PWSH%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
set "ERR=%ERRORLEVEL%"

echo.
if not "%ERR%"=="0" (
  echo ERRO: O PowerShell devolveu o codigo %ERR%.
) else (
  echo.
  echo LOCAlbum atualizado com sucesso.
)
echo.
pause

