# Steganografia 

App macOS (SwiftUI) per studiare steganografia **LSB** e steganalisi su immagini e audio.
Nessuna dipendenza esterna: solo SwiftUI, AppKit, Core Graphics.

## Requisiti

- macOS 14 o superiore
- Xcode 16 o superiore

## Build e run

```bash
open Steganografia.xcodeproj          # poi ⌘R
```

oppure da riga di comando:

```bash
xcodebuild -project Steganografia.xcodeproj -scheme Steganografia \
  -configuration Debug -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  CONFIGURATION_BUILD_DIR="$PWD/build/Debug" \
  build
```
in alternativa è disponibile l'app già buildata per X86_&4 e ARM64 dalla pagina [Release](https://github.com/f-longobardi/SteganographyEX/releases)

## Scelte di progetto

**Il messaggio nascosto sta nel canale blu è una sostituzione del LSB per ogni pixel**

**Header di 8 byte**: `"SL" | versione | strategia | lunghezza UInt32` sui primi
64 pixel in ordine di scansione. L'estrazione non chiede nulla all'utente.

## Immagini
**L'output è sempre PNG per le immagini.** 

## Dataset di immagini
- Usa il dataset da HuggingFace [pk3388/watches](https://huggingface.co/datasets/pk3388/watches)
- Per l’elaborazione di batch di immagini utilizziamo un background thread, tornando su **Main Actor** solo per gli aggiornamenti di UI
- Di default scrive su tutti i byte disponibili oppure un messaggio scritto dall'utente.

**Strategia:** 
- Scrittura su file di Immagini o file Audio supportati da AVFoundation (i formati più comuni)
- Possibile scrittura uniforme o solo sui bordi di un immagine tramite edge detection.
- Edge Detection disponibili nel codice Canny Edge, Sobel con soglia, e altri metodi.
- per i file di immagini ho scelto di scrivere solo nel canale del blu. Ho scelto il canale blu perché è quello che ha meno impatto sulla luminanza: 0,299R + 0,587G + 0,114B in modo da mantenere la distorsione visiva al minimo.
- **BER** (bit error rate): bit diversi fra payload inserito e recuperato. Richiede il messaggio originale noto e vale **0 per costruzione** con PNG/WAV lossless. È mostrato come `n/d` quando non è definito o payload non estraibile
- PSNR: picco segnale/rumore espresso in decibel, calcolato su R, G e B (alpha escluso), misura la qualità del segnale.
- **SSIM**: indice di somiglianza strutturale. La definizione standard lavora sulla luminanza che pesa il blu solo 0,114: poiché l'embedding modifica solo quel canale, l'SSIM standard resta schiacciato vicino a 1 e non distingue una immagine alterata. Il progetto usa quindi una **variante non standard calcolata sul solo canale blu** (`SSIMCalculator.ssim(original:modified:)`), che misura la distorsione dove viene effettivamente introdotta; la versione classica su luminanza resta disponibile come `ssimAllChannels(original:modified:)` per confronto. I blocchi sono 8×8 non sovrapposti.
- **Classificatore con Chi-quadrato**: un p-value alto significa coppie equalizzate, cioè si può sospettare la scrittura nell'LSB. È calcolato **solo sul canale blu** perché solo quel canale viene modificato: aggregando R, G e B i canali intatti mantengono le coppie sbilanciate e schiacciano p a 0.

## Audio

In *Embed Message* e *Extract Message* è possibile selezionare **Immagine / Audio** per cambiare il supporto. L'audio usa esattamente lo stesso header di 8 byte e la stessa logica LSB, un bit per campione PCM.

**L'uscita è sempre WAV.** Un formato compresso (MP3, AAC) distruggerebbe i bit nascosti, come il JPEG per le immagini.

## Disclaimer uso AI

- E' stata usata Claude opus per creare un'applicazione di steganalisi in python per validare i risultati ottenuti in questa app, alcuni spunti per la steganalisi sono stati presa di lì, come utilizzare anche il bilanciamento e l'entropia, e che è quasi impossibile rilevare un messaggio che è scritto in un solo canale se si analizzano tutti e 3.
- Filtro di Sobel con finestra mobile ottimizzato da Deepseek
- E' stato fatto un double-check con Deepseek a fine progetto per controllare che il progetto rispettasse le specifiche iniziali
- Alcuni messaggi di commit sono stati suggeriti in automatico da GitHub Copilot.

Appicon from [Flaticon](https://www.flaticon.com/free-icon/hide_9412796?term=hide+photo&page=1&position=7&origin=search&related_id=9412796)
