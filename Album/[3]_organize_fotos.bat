@echo off
chcp 65001 >nul
title LOCAlbum - Organizar Fotos Automaticamente
echo.
echo =====================================================
echo        LOCAlbum - Organizar Fotos Automaticamente
echo =====================================================
echo.

:: Caminho completo do script PowerShell (deve estar na mesma pasta)
set "PS_SCRIPT=%~dp0z3.ps1"

:: Verifica se existe
if not exist "%PS_SCRIPT%" (
    echo ❌ O ficheiro PowerShell nao foi encontrado:
    echo    %PS_SCRIPT%
    echo.
    echo Certifica-te de que o ficheiro [3].ps1 esta na mesma pasta.
    pause
    exit /b
)

:: Executa o script PowerShell numa nova janela e mantem aberta
echo 🚀 A iniciar o PowerShell...
echo.
start powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" & exit

echo.
echo (A janela do PowerShell foi aberta. Segue as instrucoes la.)
echo.
pause
