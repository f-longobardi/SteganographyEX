# Steganografia 

App macOS (SwiftUI) per studiare steganografia **LSB** e steganalisi su immagini e audio.
Nessuna dipendenza esterna: solo SwiftUI, AppKit, Core Graphics.

## Requisiti

- macOS 14+ (deployment target `MACOSX_DEPLOYMENT_TARGET = 14.0`)
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

## Scelte di progetto

**Il bit nascosto sta nel canale blu**. Un bit per pixel.

**Header di 8 byte**: `"SL" | versione | strategia | lunghezza UInt32` sui primi
64 pixel in ordine di scansione. L'estrazione non chiede nulla all'utente.

## Immagini
**L'output è sempre PNG per le immagini.** 

## Dataset di immagini
- Usa il dataset da HuggingFace [pk3388/watches](https://huggingface.co/datasets/pk3388/watches)
- Per l’elaborazione di batch di immagini utilizziamo un background thread, tornando su **Main Actor** solo per gli aggiornamenti di UI
- Di default scrive su tutti i byte disponibili oppure un messaggio stringa

**Strategia:** 
- Scrittura su file di Immagini o file Audio supportati da AVFoundation (i formati più comuni)
- Possibile scrittura uniforme o solo sui bordi di un immagine tramite edge detection.
- Edge Detection con: Sobel con soglia a 128, altri metodi di Edge detection sono stati testati e ancora nel codice, come Canny Edge
- per i file di immagini ho scelto di scrivere solo nel canale del blu. Ho scelto il canale blu perché è quello che ha meno impatto sulla luminanza: 0,299R + 0,587G + 0,114B in modo da mantenere la distorsione visiva al minimo.
- **BER** (bit error rate): bit diversi fra payload inserito e recuperato. Richiede il messaggio originale noto e vale **0 per costruzione** con PNG/WAV lossless. È mostrato come `n/d` quando non è definito o payload non estraibile
- PSNR: picco segnale/rumore espresso in decibel, calcolato su R, G e B (alpha escluso), misura la qualità del segnale.
- **SSIM**: indice di somiglianza strutturale. La definizione standard lavora sulla luminanza che pesa il blu solo 0,114: poiché l'embedding modifica solo quel canale, l'SSIM standard resta schiacciato vicino a 1 e non distingue una immagine alterata. Il progetto usa quindi una **variante non standard calcolata sul solo canale blu** (`SSIMCalculator.ssim(original:modified:)`), che misura la distorsione dove viene effettivamente introdotta; la versione classica su luminanza resta disponibile come `ssimAllChannels(original:modified:)` per confronto. I blocchi sono 8×8 non sovrapposti.
- Per messaggi che non riempiono buona parte dei bit disponibili la somiglianza tende ad essere alta, quindi di difficile rilevazione.

## Audio

In *Embed Message* e *Extract Message* è possibile selezionare **Immagine / Audio** per cambiare il supporto. L'audio usa esattamente lo stesso header di 8 byte e la stessa logica LSB, un bit per campione PCM.

**L'uscita è sempre WAV.** Un formato compresso (MP3, AAC) distruggerebbe i bit nascosti, come il JPEG per le immagini.

Appicon from [Flaticon](https://www.flaticon.com/free-icon/hide_9412796?term=hide+photo&page=1&position=7&origin=search&related_id=9412796)
