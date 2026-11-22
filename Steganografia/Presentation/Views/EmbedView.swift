import SwiftUI

  // Load embed save
struct EmbedView: View {
  @State private var medium: Multimedia = .image
  @State private var imageModel = EmbedViewModel()
  @State private var audioModel = AudioEmbedViewModel()
  
  var body: some View {
    VStack(spacing: 0) {
      Picker("Tipo di file", selection: $medium) {
        ForEach(Multimedia.allCases) { Text($0.label).tag($0) }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .frame(maxWidth: 280)
      .padding([.horizontal, .top])
      
      switch medium {
      case .image: ImageEmbedPane(model: imageModel)
      case .audio: AudioEmbedView(model: audioModel)
      }
    }
  }
}

private struct ImageEmbedPane: View {
  @Bindable var model: EmbedViewModel
  
  var body: some View {
    HSplitView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Immagine originale", systemImage: "photo")
            .font(.headline)
          MediaImportButton(title: "Seleziona immagine…") { model.load(from: $0) }
          ImageWell(image: model.sourceImage, caption: "Originale")
          
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
          
          Picker("Embedding Strategy", selection: $model.strategy) {
            ForEach(EmbeddingStrategyKind.allCases) { kind in
              Text(kind.label).tag(kind)
            }
          }
          .pickerStyle(.segmented)
        }
        .padding()
      }
      .frame(minWidth: 320, idealWidth: 380)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Label("Immagine alterata", systemImage: "eye.slash")
            .font(.headline)
          ImageWell(
            image: model.stegImage,
            caption: "Alterata"
          )
          
          HStack {
            Button("Genera immagine modificata") { model.embed() }
              .keyboardShortcut(.defaultAction)
              .disabled(model.sourceImage == nil)
            Button("Salva PNG…") { model.saveStegImage() }
              .disabled(model.stegImage == nil)
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
          
          if model.strategy == .edgeAware {
            Text("Edge Aware con Sobel: la capacità di bit disponibili limitata")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
        .padding()
      }
      .frame(minWidth: 320)
    }
  }
}

#Preview {
  EmbedView()
}
