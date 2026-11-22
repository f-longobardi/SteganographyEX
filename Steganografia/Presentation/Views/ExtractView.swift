import SwiftUI

  // estrazione da immagine o audio
struct ExtractView: View {
  @State private var medium: Multimedia = .image
  @State private var imageModel = ExtractViewModel()
  @State private var audioModel = AudioExtractViewModel()
  
  var body: some View {
    VStack(spacing: 0) {
      Picker("Supporto", selection: $medium) {
        ForEach(Multimedia.allCases) { Text($0.label).tag($0) }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .frame(maxWidth: 280)
      .padding([.horizontal, .top])
      
      switch medium {
      case .image: ImageExtractPane(model: imageModel)
      case .audio: AudioExtractView(model: audioModel)
      }
    }
  }
}

private struct ImageExtractPane: View {
  @Bindable var model: ExtractViewModel
  
  var body: some View {
    HSplitView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Immagine modificata", systemImage: "photo")
            .font(.headline)
          MediaImportButton(title: "Seleziona immagine modificata…") { model.load(from: $0) }
          ImageWell(
            image: model.sourceImage,
            caption: "alterata"
          )
        }
        .padding()
      }
      .frame(minWidth: 320, idealWidth: 380)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Messaggio recuperato", systemImage: "text.bubble")
            .font(.headline)
          
          Button("Estrai messaggio") { model.extract() }
            .keyboardShortcut(.defaultAction)
            .disabled(model.sourceImage == nil)
          
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

#Preview {
  ExtractView()
}
