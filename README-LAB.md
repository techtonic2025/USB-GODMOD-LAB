# USB-GODMODE-Lab

Versione sperimentale di USB-GODMOD Uncens con pannello **STEERING LAB**.

## Cosa fa

- Con OpenRouter mantiene il confronto tra modelli e aggiunge steering a livello di prompt: Godmode, contrastive, persona/behavior, refusal-direction emulation, multi-vector e adaptive.
- Con il selettore **A/B: RAW vs STEERED** invia lo stesso prompt in due varianti e mostra le risposte affiancate.
- Con **Ollama locale** interroga un modello installato sul computer senza costi per richiesta. Il campo modello predefinito è `llama3.2:3b`.

Queste tecniche non cambiano le attivazioni interne del modello e non garantiscono risposte senza filtri. Activation Addition, CAA, SAE steering e tecniche simili richiedono accesso ai layer tramite un runtime Python/PyTorch separato; non sono disponibili attraverso OpenRouter e non sono esposte dall'API chat standard di Ollama.

## Ollama

Installare Ollama, poi in un terminale:

```bash
ollama serve
ollama pull llama3.2:3b
```

Avviare l'app tramite un piccolo server HTTP locale (consigliato invece di `file://`) e, se il browser blocca la richiesta, configurare CORS per l'origine del server. Su Windows, ad esempio, impostare `OLLAMA_ORIGINS=http://localhost:8088` prima di avviare Ollama. Il pulsante **Verifica Ollama** controlla `/api/tags`.

Il browser non scarica automaticamente modelli: il download resta esplicito e controllabile dall'utente.

## Installazione Activation Steering su Windows

La configurazione consigliata è mista: interfaccia e sorgenti possono restare sulla chiavetta, mentre ambiente Python, cache, modello e vettori vengono salvati in `%LOCALAPPDATA%\USB-GODMODE-Lab` sul PC.

1. Avviare `INSTALLA-STEERING-WINDOWS.bat`.
2. Confermare installazione e download. Sono consigliati almeno 10 GB liberi.
3. Al termine usare `AVVIA-STEERING-WINDOWS.bat`.
4. Nell'interfaccia scegliere `Activation Steering locale`, attivare `A/B` e selezionare una o più intensità.

Il programma usa `Qwen/Qwen2.5-1.5B-Instruct` e crea un vettore CAA dimostrativo orientato a risposte più dirette, precise e verificabili. Il risultato è sperimentale e dipende dal modello e dall'intensità.

## Limiti e privacy

La chiave OpenRouter resta nel browser solo se si seleziona l'opzione “Ricorda”. Non viene inviata a questo progetto. Le richieste OpenRouter vanno al provider scelto; le richieste Ollama restano locali.
