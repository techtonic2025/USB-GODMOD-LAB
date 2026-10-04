#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
python3 -m venv .venv 2>/dev/null || true
.venv/bin/python -m pip install -r requirements.txt
export MODEL_ID="${MODEL_ID:-Qwen/Qwen2.5-1.5B-Instruct}"
echo "Starting local activation steering on http://127.0.0.1:8787"
.venv/bin/python server.py serve
