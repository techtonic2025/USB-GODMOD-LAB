@echo off
setlocal EnableExtensions
title USB GODMODE Lab - Installazione locale
cd /d "%~dp0"
set "LAB_DATA=%LOCALAPPDATA%\USB-GODMODE-Lab"
set "LAB_VENV=%LAB_DATA%\venv"
set "HF_HOME=%LAB_DATA%\huggingface"
set "MODEL_ID=Qwen/Qwen2.5-1.5B-Instruct"

echo.
echo USB GODMODE LAB - INSTALLAZIONE MISTA
echo Interfaccia: %CD%
echo Runtime e modelli: %LAB_DATA%
echo Spazio libero consigliato: almeno 10 GB.
echo.
choice /C SN /M "Continuare con installazione e download"
if errorlevel 2 exit /b 0

where python.exe >nul 2>nul
if errorlevel 1 goto install_python
python -c "import sys; exit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
if not errorlevel 1 goto python_ready

:install_python
where winget.exe >nul 2>nul
if errorlevel 1 goto no_python
echo Installazione Python 3.11 tramite winget...
winget install --id Python.Python.3.11 -e --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto failed
set "PATH=%LocalAppData%\Programs\Python\Python311;%LocalAppData%\Programs\Python\Python311\Scripts;%PATH%"

:python_ready
if not exist "%LAB_DATA%" mkdir "%LAB_DATA%"
if not exist "%LAB_VENV%\Scripts\python.exe" python -m venv "%LAB_VENV%"
if not exist "%LAB_VENV%\Scripts\python.exe" goto failed
echo Installazione PyTorch e Transformers...
"%LAB_VENV%\Scripts\python.exe" -m pip install --upgrade pip
"%LAB_VENV%\Scripts\python.exe" -m pip install -r "%~dp0local-steering\requirements.txt"
if errorlevel 1 goto failed
echo Verifica e download del modello %MODEL_ID%...
"%LAB_VENV%\Scripts\python.exe" -c "from transformers import AutoTokenizer,AutoModelForCausalLM; m=r'%MODEL_ID%'; AutoTokenizer.from_pretrained(m); AutoModelForCausalLM.from_pretrained(m,torch_dtype='auto')"
if errorlevel 1 goto failed
echo Creazione del vettore CAA dimostrativo...
if not exist "%LAB_DATA%\vectors" mkdir "%LAB_DATA%\vectors"
"%LAB_VENV%\Scripts\python.exe" "%~dp0local-steering\server.py" make-caa --positive "%~dp0local-steering\prompts_positive.txt" --negative "%~dp0local-steering\prompts_negative.txt" --output "%LAB_DATA%\vectors\directness-caa.npy" --layer -1
if errorlevel 1 goto failed
echo.
echo Installazione completata.
echo Usa AVVIA-STEERING-WINDOWS.bat per aprire servizio e interfaccia.
pause
exit /b 0

:no_python
echo Python non trovato e winget non disponibile.
echo Installa Python 3.11 da python.org selezionando Add Python to PATH, poi ripeti.
pause
exit /b 1

:failed
echo Installazione non completata. Controlla connessione, spazio libero e messaggi sopra.
pause
exit /b 1
