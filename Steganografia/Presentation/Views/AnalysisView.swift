import SwiftUI

  /// risultato analisi
struct AnalysisView: View {
  @State private var model = AnalysisViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top, spacing: 16) {
          VStack(alignment: .leading, spacing: 8) {
            MediaImportButton(title: "Immagine originale…") { model.loadOriginal(from: $0) }
            ImageWell(image: model.original, caption: "Originale")
          }
          VStack(alignment: .leading, spacing: 8) {
            MediaImportButton(title: "Immagine alterata…") { model.loadAltered(from: $0) }
            ImageWell(image: model.altered, caption: "Alterata")
          }
        }
        
        VStack(alignment: .leading, spacing: 6) {
          Text("Optional: Messaggio se noto, serve per calcolare il BER.")
            .font(.headline)
          TextField("Testo inserito nell'immagine alterata", text: $model.expectedMessage)
            .textFieldStyle(.roundedBorder)
        }
        
        Button("Calcola metriche") { model.analyze() }
          .keyboardShortcut(.defaultAction)
          .disabled(model.original == nil || model.altered == nil)
        
        if let result = model.result {
          HStack(spacing: 12) {
            MetricTile(title: "Payload Size", value: result.payloadSizeText)
            MetricTile(title: "PSNR", value: result.psnrText)
            MetricTile(title: "SSIM", value: result.ssimText)
            MetricTile(title: "BER", value: result.berText)
          }
          if let message = model.extractedMessage {
            GroupBox("Payload estratto dall'immagine alterata") {
              Text(message)
                .font(.body.monospaced())
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(6)
            }
          }
        }
        
        if let status = model.status {
          Label(status, systemImage: "info.circle")
            .foregroundStyle(.secondary)
            .font(.callout)
        }
      }
      .padding()
    }
  }
}

#Preview {
  AnalysisView()
}
