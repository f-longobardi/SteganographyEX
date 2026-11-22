import SwiftUI

  /// carica immagine, esegui la steganalisi con probabilità
struct DetectionView: View {
  @State private var model = DetectionViewModel()
  
  var body: some View {
    HSplitView {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          MediaImportButton(title: "Seleziona immagine…") { model.load(from: $0) }
          ImageWell(image: model.image, caption: "Immagine")
        }
        .padding()
      }
      .frame(minWidth: 300, idealWidth: 360)
      
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          Button("Esegui steganalisi") { model.detect() }
            .keyboardShortcut(.defaultAction)
            .disabled(model.image == nil)
          
          if let result = model.result {
            HStack(spacing: 12) {
              MetricTile(title: "Classification", value: result.classification.rawValue)
              MetricTile(title: "Probability", value: result.probabilityText)
              MetricTile(title: "Score", value: String(format: "%.3f", result.score))
            }
            .overlay(alignment: .topTrailing) {
              Circle()
                .fill(result.classification == .altered ? Color.orange : Color.green)
                .frame(width: 10, height: 10)
                .padding(8)
            }
            
            GroupBox("") {
              VStack(alignment: .leading, spacing: 4) {
                ForEach(
                  Array(
                    zip(result.features.labels, result.features.values)
                  ),
                  id: \.0
                ) { label, value in
                  FeatureRow(label: label, value: value)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Text("Il chi-square attack domina lo score perchè misura diretta dell'equalizzazione delle coppie di valori prodotta dall'LSB replacement.\nGli altri valori sono secondari e spesso usati nella steganalisi, ma non sono di certo gli unici!")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          
          if let error = model.errorMessage {
            Label(error, systemImage: "exclamationmark.triangle")
              .foregroundStyle(.red)
          }
        }
        .padding()
      }
      .frame(minWidth: 320)
    }
  }
}

#Preview {
  DetectionView()
}
