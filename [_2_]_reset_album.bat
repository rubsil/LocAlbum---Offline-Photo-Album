@echo off
chcp 65001 >nul
title LOCAlbum - Reset

echo ---------------------------------------------
echo       LOCAlbum - Reset / Repor o Álbum
echo ---------------------------------------------
echo.

echo 🌍 Escolhe o idioma / Choose language:
echo [P] PT  → Português
echo [E] EN  → English
echo.

choice /c PE /m "Seleciona uma opção:"

:: 🚀 Detetar idioma e saltar diretamente
if %errorlevel%==1 goto :PORTUGUES
if %errorlevel%==2 goto :ENGLISH


:PORTUGUES
cls
echo 🧹 A repor o álbum LOCALBUM...
echo.
echo Este processo irá:
echo  - Apagar ficheiros de configuração (config.ini, Album.ini)
echo  - Apagar o ficheiro "Ver album.html" 
echo  - Manter todas as tuas fotos e vídeos intocados
echo.
choice /c SN /m "Queres continuar?"
if errorlevel 2 (
    echo.
    echo ❌ Operação cancelada.
    timeout /t 3 >nul
    exit
)

echo.
echo 🔧 A eliminar ficheiros antigos...
attrib -h -s "config.ini" >nul 2>&1
attrib -h -s "album.ini" >nul 2>&1
attrib -h -s "..\config.ini" >nul 2>&1
attrib -h -s "..\album.ini" >nul 2>&1

del /f /q "config.ini" >nul 2>&1
del /f /q "album.ini" >nul 2>&1
del /f /q "..\config.ini" >nul 2>&1
del /f /q "..\album.ini" >nul 2>&1
del /f /q "..\Ver album.html" >nul 2>&1
del /f /q "..\View album.html" >nul 2>&1

echo.
echo ✨ Reset concluído com sucesso!
echo 📸 Todas as tuas fotos permanecem intactas.
echo ---------------------------------------------
echo.
set /p choice=Queres criar um novo álbum agora? (S/N): 
if /i "%choice%"=="S" (
    echo.
    echo 🚀 A criar novo álbum...
    start "" cmd /c "[_1_]_update_album.bat"
    exit
) else (
    echo.
    echo ℹ️ Podes correr o [_1_]_update_album.bat manualmente quando quiseres.
    echo Obrigado por usares o LOCAlbum.
    timeout /t 5 >nul
    exit
)



:ENGLISH
cls
echo 🧹 Resetting LOCALBUM...
echo.
echo This process will:
echo  - Delete configuration files (config.ini, Album.ini)
echo  - Delete the "View album.html" file
echo  - Keep all your photos and videos safe
echo.
choice /c YN /m "Do you want to continue?"
if errorlevel 2 (
    echo.
    echo ❌ Operation cancelled.
    timeout /t 3 >nul
    exit
)

echo.
echo 🔧 Removing old files...
attrib -h -s "config.ini" >nul 2>&1
attrib -h -s "album.ini" >nul 2>&1
attrib -h -s "..\config.ini" >nul 2>&1
attrib -h -s "..\album.ini" >nul 2>&1

del /f /q "config.ini" >nul 2>&1
del /f /q "album.ini" >nul 2>&1
del /f /q "..\config.ini" >nul 2>&1
del /f /q "..\album.ini" >nul 2>&1
del /f /q "..\Ver album.html" >nul 2>&1
del /f /q "..\View album.html" >nul 2>&1

echo.
echo ✨ Reset completed successfully!
echo 📸 All your photos and videos are safe.
echo ---------------------------------------------
echo.
set /p choice=Do you want to create a new album now? (Y/N): 
if /i "%choice%"=="Y" (
    echo.
    echo 🚀 Creating new album...
    start "" cmd /c "[_1_]_update_album.bat"
    exit
) else (
    echo.
    echo ℹ️ You can run [_1_]_update_album.bat manually later.
    echo Thank you for using LOCAlbum.
    timeout /t 5 >nul
    exit
)
