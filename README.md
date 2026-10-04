# USB GODMOD LAB

Interfaccia portatile per confrontare modelli AI tramite OpenRouter, Ollama e un backend sperimentale di activation steering locale.

![Interfaccia USB GODMOD](assets/homepage.png)

> Progetto destinato a ricerca e valutazione. Lo steering non garantisce l'eliminazione dei rifiuti e un'intensità elevata può ridurre precisione e coerenza.

## Funzioni

- confronto parallelo di massimo quattro modelli OpenRouter;
- catalogo OpenRouter aggiornabile dall'app;
- modalità NORMAL/RAW, GODMODE e ULTRAPLINIAN LITE;
- Steering Lab: Godmode Prompt, Contrastive, Persona/Behavior, Refusal-direction emulation, Multi-vector e Adaptive;
- intensità 0–100 e confronto A/B RAW contro STEERED;
- backend OpenRouter, Ollama e Activation Steering locale;
- durata, token, costo disponibile e rilevamento euristico dei rifiuti;
- configurazione esportabile/importabile e nessuna telemetria applicativa.

## Tre modalità di esecuzione

### OpenRouter

Non richiede modelli sul computer. Le tecniche Steering Lab sono direttive di sistema: prompt steering, non modifiche ai layer interni.

### Ollama

Esegue un modello locale tramite l'API Ollama. Anche qui lo Steering Lab opera a livello di prompt.

```bash
ollama pull llama3.2:3b
ollama serve
```

### Activation Steering locale

Usa Python, PyTorch e Transformers per accedere ai transformer block. Implementa Activation Addition tramite vettore NumPy, creazione/applicazione di un vettore CAA, selezione del layer, intensità e confronto RAW/STEERED.

SAE steering, PID steering e function vectors non sono ancora implementati e non vengono simulati.

## Avvio portatile

Per OpenRouter, copiare il progetto sulla chiavetta e avviare:

- `start.bat` su Windows;
- `start.command` su macOS;
- `start.sh` su Linux.

## Installazione completa Windows

La configurazione consigliata è mista: interfaccia e sorgenti possono restare sulla chiavetta; Python, ambiente, cache, modello e vettori vengono salvati sul PC in `%LOCALAPPDATA%\USB-GODMODE-Lab`.

Sono consigliati almeno 10 GB liberi e 16 GB di RAM.

1. Avviare `INSTALLA-STEERING-WINDOWS.bat`.
2. Confermare installazione e download.
3. Il programma installa Python 3.11 quando possibile, PyTorch e Transformers.
4. Scarica `Qwen/Qwen2.5-1.5B-Instruct`.
5. Crea il vettore CAA dimostrativo `directness-caa.npy`.
6. Per gli avvii successivi usare `AVVIA-STEERING-WINDOWS.bat`.
7. Nell'interfaccia scegliere **Activation Steering locale** e **A/B: RAW vs STEERED**.

Il servizio ascolta su `127.0.0.1:8787`; l'interfaccia su `127.0.0.1:8765`.

## Requisiti indicativi

| Configurazione | Esperienza prevista |
|---|---|
| 8 GB RAM, solo CPU | Possibile ma lenta; può usare molta memoria virtuale |
| 16 GB RAM, CPU recente | Adeguata per il modello 1,5B |
| GPU NVIDIA con 4–6 GB VRAM | Consigliata |
| 32 GB RAM / GPU 8 GB | Esperienza più comoda |

## Vettore CAA manuale

Preparare due file con lo stesso numero di righe e avviare:

```bash
python local-steering/server.py make-caa \
  --positive local-steering/prompts_positive.txt \
  --negative local-steering/prompts_negative.txt \
  --output vectors/caa.npy \
  --layer -1
```

Il vettore viene estratto e applicato allo stesso transformer block. Modello, layer e intensità influenzano fortemente il risultato.

## Privacy

- La chiave OpenRouter resta nel browser solo selezionando “Ricorda”.
- Le richieste OpenRouter vanno al provider selezionato.
- Ollama e PyTorch operano localmente.
- Non è presente telemetria applicativa.

## Struttura

```text
index.html                         interfaccia completa
start.bat / start.sh              avvio portatile
INSTALLA-STEERING-WINDOWS.bat      installazione mista
AVVIA-STEERING-WINDOWS.bat         avvio completo
local-steering/server.py           servizio PyTorch
local-steering/requirements.txt    dipendenze Python
local-steering/prompts_*.txt       coppie dimostrative CAA
```

## Stato

OpenRouter e prompt steering sono utilizzabili direttamente. Ollama richiede un'installazione locale. Activation Steering è sperimentale e va validato sull'hardware e sul modello scelti.

## Licenza

AGPL-3.0. Vedere `LICENSE` e `THIRD_PARTY_NOTICES.md`.
