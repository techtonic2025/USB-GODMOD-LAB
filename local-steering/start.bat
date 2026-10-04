@echo off
setlocal
cd /d "%~dp0"
if not exist .venv\Scripts\python.exe py -3 -m venv .venv
.venv\Scripts\python.exe -m pip install -r requirements.txt
if "%MODEL_ID%"=="" set MODEL_ID=Qwen/Qwen2.5-1.5B-Instruct
echo Starting local activation steering on http://127.0.0.1:8787
.venv\Scripts\python.exe server.py serve
pause
