@echo off
setlocal EnableExtensions
cd /d "%~dp0"
set "LAB_DATA=%LOCALAPPDATA%\USB-GODMODE-Lab"
set "LAB_VENV=%LAB_DATA%\venv"
set "HF_HOME=%LAB_DATA%\huggingface"
set "MODEL_ID=Qwen/Qwen2.5-1.5B-Instruct"
set "STEERING_VECTOR=%LAB_DATA%\vectors\directness-caa.npy"
if not exist "%LAB_VENV%\Scripts\python.exe" (
  echo Installazione non trovata. Avvio INSTALLA-STEERING-WINDOWS.bat...
  call "%~dp0INSTALLA-STEERING-WINDOWS.bat"
)
if not exist "%LAB_VENV%\Scripts\python.exe" exit /b 1
start "GODMODE Activation Service" /min "%LAB_VENV%\Scripts\python.exe" "%~dp0local-steering\server.py" serve
timeout /t 4 /nobreak >nul
start "GODMODE Web" "%LAB_VENV%\Scripts\python.exe" -m http.server 8765 --bind 127.0.0.1 --directory "%~dp0"
start "" http://127.0.0.1:8765/
echo Servizio activation steering: http://127.0.0.1:8787
echo Interfaccia: http://127.0.0.1:8765
echo Chiudendo questa finestra si arresta solo il server web.
