import SwiftUI
import UniformTypeIdentifiers

  /// view audio di "Embed Message": carica un audio, inserisci il testo, genera l'audio modificato
struct AudioEmbedView: View {
  @Bindable var model: AudioEmbedViewModel
  
  var body: some View {
    HSplitView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Audio originale", systemImage: "waveform")
            .font(.headline)
          MediaImportButton(title: "Seleziona audio…", allowed: UTType.importableAudio) {
            model.load(from: $0)
          }
          AudioWell(audio: model.source, envelope: model.sourceEnvelope, caption: "Originale")
          
          Divider()
          
          Text("Messaggio da occultare")
            .font(.headline)
          TextEditor(text: $model.message)
            .font(.body.monospaced())
            .frame(minHeight: 120)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
          
          Text("\(model.payloadBytes) byte · capacità \(model.capacityBytes) byte")
            .font(.caption)
            .foregroundStyle(model.fits ? Color.secondary : Color.red)
            .monospacedDigit()
        }
        .padding()
      }
      .frame(minWidth: 340, idealWidth: 400)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Audio modificato", systemImage: "waveform.path.ecg")
            .font(.headline)
          AudioWell(
            audio: model.steg,
            envelope: model.stegEnvelope,
            caption: "Alterata"
          )
          
          HStack {
            Button("Genera audio modificato") { model.embed() }
              .keyboardShortcut(.defaultAction)
              .disabled(model.source == nil)
            Button("Salva WAV…") { model.saveAlteredAudio() }
              .disabled(model.steg == nil)
          }
          
          if let status = model.status {
            Label(status, systemImage: "checkmark.circle")
              .foregroundStyle(.green)
              .font(.callout)
          }
          if let error = model.errorMessage {
            Label(error, systemImage: "exclamationmark.triangle")
              .foregroundStyle(.red)
              .font(.callout)
          }
          
          Text("OUTPUT in WAV PCM: un formato compresso distruggerebbe i bit nascosti, come il JPEG per le immagini.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
      }
      .frame(minWidth: 320)
    }
  }
}
