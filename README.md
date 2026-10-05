# USB GODMOD LAB

An experimental portable interface for comparing AI models through OpenRouter, Ollama, and a local activation-steering service.

![USB GODMOD interface](assets/homepage.png)

> This project is intended for research, comparison, and evaluation. Steering does not guarantee that safeguards or refusals disappear. Excessive steering strength can reduce accuracy, coherence, or output quality.

## Features

- Compare up to four OpenRouter models in parallel.
- Refresh the OpenRouter model catalogue from the application.
- `NORMAL / RAW`, `GODMODE`, and `ULTRAPLINIAN LITE` modes.
- Steering Lab controls for Godmode Prompt, Contrastive, Persona/Behavior, Refusal-direction emulation, Multi-vector, and Adaptive prompting.
- Per-technique strength controls from 0 to 100.
- A/B comparison of RAW versus STEERED output.
- OpenRouter, Ollama, and local Activation Steering backends.
- Response time, token usage, available/estimated cost, and heuristic refusal detection.
- Importable and exportable configuration.
- No application telemetry.

## Backends

### OpenRouter

OpenRouter does not require local models. Steering Lab settings are sent as system instructions, so this is **prompt steering**, not access to internal model activations.

### Ollama

Ollama runs an installed local model through its local API. The interface still applies Steering Lab settings at prompt level.

Example:

```bash
ollama pull llama3.2:3b
ollama serve
```

### Local Activation Steering

The `local-steering` module uses Python, PyTorch, and Transformers to access transformer blocks in a local Hugging Face model. It supports:

- Activation Addition using a NumPy vector.
- CAA, Contrastive Activation Addition, vector generation and application.
- Layer selection and adjustable steering strength.
- RAW versus STEERED comparison from the interface.

SAE steering, PID steering, and function vectors are not implemented. They are not simulated or labelled as real activation-steering methods.

## Portable use

For OpenRouter-only use, copy the repository to a USB drive and launch:

- `start.bat` on Windows;
- `start.command` on macOS;
- `start.sh` on Linux.

## Full Windows setup

The recommended setup is mixed:

- Keep the interface and source files on a USB drive if desired.
- Store Python, the virtual environment, Hugging Face cache, model, and steering vectors on the PC in `%LOCALAPPDATA%\USB-GODMODE-Lab`.

At least 10 GB of free disk space and 16 GB of RAM are recommended.

1. Run `INSTALLA-STEERING-WINDOWS.bat`.
2. Confirm the installation and download.
3. The script installs Python 3.11 when possible, then PyTorch and Transformers.
4. It downloads `Qwen/Qwen2.5-1.5B-Instruct`.
5. It creates the demonstration CAA vector `directness-caa.npy`.
6. Use `AVVIA-STEERING-WINDOWS.bat` for later launches.
7. In the interface select **Local Activation Steering** and enable **A/B: RAW vs STEERED**.

The local service runs on `127.0.0.1:8787`; the interface runs on `127.0.0.1:8765`.

## Hardware guidance

| Configuration | Expected experience |
|---|---|
| 8 GB RAM, CPU only | Possible but slow; significant paging may occur |
| 16 GB RAM, recent CPU | Suitable for the 1.5B model |
| NVIDIA GPU with 4-6 GB VRAM | Recommended |
| 32 GB RAM / 8 GB GPU | More comfortable |

## Manual CAA vector creation

Prepare two text files with the same number of lines: positive and negative contrastive examples. Then run:

```bash
python local-steering/server.py make-caa \
  --positive local-steering/prompts_positive.txt \
  --negative local-steering/prompts_negative.txt \
  --output vectors/caa.npy \
  --layer -1
```

The vector is extracted from and applied to the same transformer block. Results depend strongly on the model, selected layer, prompt, and steering strength.

## Privacy

- The OpenRouter key is kept in the browser only when the user selects “Remember”.
- OpenRouter requests are sent to the selected provider.
- Ollama and the PyTorch service run locally.
- The application does not include telemetry.

## Project structure

```text
index.html                         Main interface
start.bat / start.sh              Portable launchers
INSTALLA-STEERING-WINDOWS.bat      Mixed local installation
AVVIA-STEERING-WINDOWS.bat         Full local launcher
local-steering/server.py           PyTorch activation-steering service
local-steering/requirements.txt    Python dependencies
local-steering/prompts_*.txt       Demonstration CAA prompt pairs
```

## Status

OpenRouter and prompt steering can be used directly. Ollama requires a local Ollama installation. Local Activation Steering is experimental and should be validated on the target hardware and model before general use.

## License

AGPL-3.0. See [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
