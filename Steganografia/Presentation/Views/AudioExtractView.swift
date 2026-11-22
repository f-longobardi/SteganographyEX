import SwiftUI
import UniformTypeIdentifiers

/// view audio di "Extract Message."
struct AudioExtractView: View {
  @Bindable var model: AudioExtractViewModel
  
  var body: some View {
    HSplitView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Audio modificato", systemImage: "waveform")
            .font(.headline)
          MediaImportButton(title: "Seleziona audio alterato…", allowed: UTType.importableAudio) {
            model.load(from: $0)
          }
          AudioWell(
            audio: model.source,
            envelope: model.sourceEnvelope,
            caption: "Alterata"
          )
        }
        .padding()
      }
      .frame(minWidth: 340, idealWidth: 400)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Messaggio recuperato", systemImage: "text.bubble")
            .font(.headline)
          
          Button("Estrai messaggio") { model.extract() }
            .keyboardShortcut(.defaultAction)
            .disabled(model.source == nil)
          
          if let message = model.message {
            TextEditor(text: .constant(message))
              .font(.body.monospaced())
              .frame(minHeight: 180)
              .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
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
        }
        .padding()
      }
      .frame(minWidth: 320)
    }
  }
}
