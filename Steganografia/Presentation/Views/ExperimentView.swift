import SwiftUI

  /// esperimento di capacità vs qualità e Uniform vs Edge Aware.
struct ExperimentView: View {
  @State private var model = ExperimentViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top, spacing: 16) {
          VStack(alignment: .leading, spacing: 8) {
            MediaImportButton(title: "Immagine di prova…") { model.load(from: $0) }
            ImageWell(image: model.image, caption: "Originale")
          }
          VStack(alignment: .leading, spacing: 12) {
            Button("Esperimento payload (100 B → 10 KB)") { model.runPayloadExperiment() }
              .disabled(model.image == nil)
            
            HStack {
              Text("Payload confronto:")
              TextField("byte", value: $model.payloadBytes, format: .number)
                .frame(width: 80)
                .textFieldStyle(.roundedBorder)
              Text("byte")
            }
            Button("Uniform vs Edge Aware") { model.runStrategyComparison() }
              .disabled(model.image == nil)
            
            if let error = model.errorMessage {
              Label(error, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.red)
                .font(.callout)
            }
          }
        }
        
        if !model.rows.isEmpty {
          Table(model.rows) {
            TableColumn("Esperimento", value: \.experiment)
            TableColumn("Payload") { row in
              Text("\(row.payloadBytes ?? 0) B").monospacedDigit()
            }
            TableColumn("Strategia") { row in
              Text(row.strategy.label)
            }
            TableColumn("PSNR") { row in
              Text(row.psnr.isNaN ? "n/d" : String(format: "%.3f dB", row.psnr))
                .monospacedDigit()
            }
            TableColumn("SSIM") { row in
              Text(row.ssim.isNaN ? "n/d" : String(format: "%.4f", row.ssim))
                .monospacedDigit()
            }
            TableColumn("BER") { row in
              Text(row.ber.isNaN ? "n/d" : String(format: "%.6f", row.ber))
                .monospacedDigit()
            }
            TableColumn("Note", value: \.note)
          }
          .frame(minHeight: 220)
        }
        
        Text("Ipotesi da verificare: PSNR e SSIM diminuiscono all'aumentare del payload e l'embedding sui bordi degrada meno la percezione a parità di payload.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding()
    }
  }
}

#Preview {
  ExperimentView()
}
