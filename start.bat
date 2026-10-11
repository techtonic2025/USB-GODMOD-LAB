@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if not exist "index.html" (
  echo ERRORE: index.html non e' presente nella stessa cartella di start.bat.
  echo Copia l'intera cartella del progetto sulla chiavetta, non soltanto questo file.
  pause
  exit /b 1
)

set "PORT="
for %%P in (8877 8878 8879 8880) do (
  powershell -NoProfile -Command "if (Get-NetTCPConnection -LocalPort %%P -State Listen -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }" >nul 2>nul
  if not errorlevel 1 (
    set "PORT=%%P"
    goto :port_found
  )
)
echo ERRORE: le porte da 8877 a 8880 sono gia' utilizzate.
echo Chiudi il vecchio server GODMOD e riprova.
pause
exit /b 1

:port_found
echo G0DM0D3 Portable Compare
echo Cartella: %CD%
echo Avvio su http://127.0.0.1:%PORT%/

py -3 -c "import sys" >nul 2>nul
if not errorlevel 1 goto :run_py
python -c "import sys" >nul 2>nul
if not errorlevel 1 goto :run_python

echo Python non trovato: apro index.html direttamente.
echo Per evitare limiti del browser, installa Python e riapri start.bat.
start "" "%~dp0index.html"
exit /b 0

:run_py
start "" powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Milliseconds 700; Start-Process 'http://127.0.0.1:%PORT%/index.html?usb=%RANDOM%'"
py -3 -m http.server %PORT% --bind 127.0.0.1 --directory "%~dp0"
goto :eof

:run_python
start "" powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep -Milliseconds 700; Start-Process 'http://127.0.0.1:%PORT%/index.html?usb=%RANDOM%'"
python -m http.server %PORT% --bind 127.0.0.1 --directory "%~dp0"
goto :eof
