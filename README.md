# Steganografia 

App macOS (SwiftUI) per studiare steganografia **LSB** e steganalisi su immagini.
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
  -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

## Scelte di progetto

**Il bit nascosto sta nel canale blu**. Un bit per pixel.

**Header di 8 byte**: `"SL" | versione | strategia | lunghezza UInt32` sui primi
64 pixel in ordine di scansione. L'estrazione non chiede nulla all'utente.

**L'output è sempre PNG.** 

## Audio

In *Embed Message* e *Extract Message* è possibile selezionare **Immagine / Audio** per cambiare
il supporto. L'audio usa esattamente lo stesso header di 8 byte e la stessa
logica LSB, un bit per campione PCM.

**L'uscita è sempre WAV.** Un formato compresso (MP3, AAC) distruggerebbe i bit nascosti, come il JPEG per le immagini.

## Dataset

- Soglia Sobel fissa a 128 (condivisa encoder/decoder, quindi non modificabile a
  runtime senza rompere la decodifica).
