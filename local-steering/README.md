# Local Activation Steering

Modulo sperimentale per eseguire un modello Hugging Face localmente e applicare **Activation Addition (ActAdd)** oppure un vettore **CAA** (Contrastive Activation Addition). È separato dall'app HTML perché queste tecniche richiedono accesso ai layer interni del modello.

## Avvio rapido

1. Installare Python 3.10+.
2. Eseguire `start.bat` su Windows oppure `./start.sh` su Linux/macOS.
3. La prima esecuzione installa le dipendenze in `.venv` e scarica il modello indicato da `MODEL_ID` (default: `Qwen/Qwen2.5-1.5B-Instruct`).
4. Il servizio espone `POST http://127.0.0.1:8787/generate`.

Esempio:

```json
{"prompt":"Spiega la fotosintesi in modo semplice","strength":0.8,"layer":-1}
```

Per ActAdd occorre fornire un vettore NumPy `.npy` tramite `STEERING_VECTOR`. Per creare un vettore CAA da coppie contrastive:

```bash
python server.py make-caa --positive prompts_positive.txt --negative prompts_negative.txt --output vectors/caa.npy --layer -1
```

I file devono avere una frase per riga e lo stesso numero di righe. Il vettore è la media delle attivazioni positive meno la media delle attivazioni negative. Non è un bypass garantito dei rifiuti: l'effetto dipende dal modello, dal layer e dalla scala.

## Limiti

Non tutte le architetture espongono i layer con lo stesso nome. Il modulo individua automaticamente i blocchi comuni (`model.layers`, `transformer.h`, `gpt_neox.layers`). Se non li trova, si interrompe senza modificare il modello. SAE steering e PID steering richiedono un encoder/decoder SAE e un controller dedicati: non vengono simulati spacciandoli per reali.
