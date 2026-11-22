import Charts
import SwiftUI

/// Dataset remoto, generazione staganografia, quality analysis con grafici
struct DatasetView: View {
  @State private var model = DatasetViewModel()
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        downloadBox
        generateBox
        analyzeBox
        statusBox
        
        if !model.results.isEmpty {
          resultsSection
        }
      }
      .padding()
    }
  }
  
  private var downloadBox: some View {
    GroupBox("Dataset remoto (Hugging Face)") {
      VStack(alignment: .leading, spacing: 8) {
        Link("pk3388/watches", destination: RemoteDatasetSource.datasetURL)
          .font(.headline)
        
        Text("Verranno scaricati \(RemoteDatasetSource.approximateSize) di immagini.")
          .font(.callout)
          .foregroundStyle(.secondary)
        
        HStack {
          Button("Scarica dataset") {
            Task { await model.download() }
          }
          .disabled(model.isDownloading || model.isGenerating || model.isAnalyzing)
          
          Text("\(model.images.count) immagini pronte")
            .font(.callout.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        
        if model.isDownloading {
          ProgressView()
          Text(model.downloadLabel ?? "")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  
  private var generateBox: some View {
    GroupBox {
      VStack(alignment: .leading, spacing: 8) {
        TextField("Messaggio da occultare", text: $model.message, axis: .vertical)
          .textFieldStyle(.roundedBorder)
          .lineLimit(2...4)
          .disabled(model.fillCapacity)
        
        if model.fillCapacity {
          Text("Il messaggio viene ignorato: ogni immagine usa tutti i bit disponibili.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        
        Picker("Embedding Strategy", selection: $model.strategy) {
          ForEach(EmbeddingStrategyKind.allCases) { kind in
            Text(kind.label).tag(kind)
          }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 320)
        
        Button("Genera dataset modificato") {
          Task { await model.generate() }
        }
        .disabled(!model.canGenerate)
        
        if let progress = model.generateProgress, !model.isAnalyzing {
          ProgressView(value: progress)
          Text(model.generateLabel ?? "")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    } label: {
      HStack {
        Text("Generazione dataset modificato")
        Spacer()
        Toggle("Scrivi tutti i bit disponibili", isOn: $model.fillCapacity)
          .toggleStyle(.checkbox)
      }
    }
  }
  
  private var analyzeBox: some View {
    GroupBox("Quality analysis") {
      VStack(alignment: .leading, spacing: 8) {
        Text("PSNR, SSIM e BER calcolati per ogni immagine modificata")
          .font(.callout)
          .foregroundStyle(.secondary)
        
        Button("Analizza qualità") {
          Task { await model.analyze() }
        }
        .disabled(!model.canAnalyze)
        
        if let progress = model.analyzeProgress {
          ProgressView(value: progress)
          Text(model.analyzeLabel ?? "")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
  
  @ViewBuilder
  private var statusBox: some View {
    if let status = model.status {
      Label(status, systemImage: "checkmark.circle")
        .font(.callout)
    }
    if let error = model.errorMessage {
      Label(error, systemImage: "exclamationmark.triangle")
        .foregroundStyle(.orange)
        .font(.caption)
    }
  }
  
  private var resultsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Risultati dell'analisi")
        .font(.title3.bold())
      
      HStack(spacing: 12) {
        MetricTile(title: "Immagini", value: "\(model.results.count)")
        MetricTile(title: "PSNR medio", value: String(format: "%.3f dB", average(\.psnr)))
        MetricTile(title: "SSIM medio", value: String(format: "%.4f", average(\.ssim)))
        MetricTile(title: "BER medio", value: averageBER.map { String(format: "%.6f", $0) } ?? "n/d")
      }
      
      DistributionChart(
        title: "Distribuzione PSNR",
        values: model.results.map(\.psnr),
        format: { String(format: "%.3f", $0) }
      )
      DistributionChart(
        title: "Distribuzione SSIM",
        values: model.results.map(\.ssim),
        format: { String(format: "%.4f", $0) }
      )
      DistributionChart(
        title: "Distribuzione BER",
        values: model.results.compactMap(\.ber),
        format: { String(format: "%.6f", $0) }
      )
    }
  }
  
  private func average(_ keyPath: KeyPath<AnalysisResult, Double>) -> Double {
    let values = model.results.map { $0[keyPath: keyPath] }.filter { $0.isFinite }
    return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
  }
  
  private var averageBER: Double? {
    let values = model.results.compactMap(\.ber).filter(\.isFinite)
    return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
  }
}

private struct DistributionChart: View {
  let title: String
  let values: [Double]
  let format: (Double) -> String
  
  private var bins: [Bin] { makeBins(values) }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(title)
        .font(.headline)
      
      if bins.isEmpty {
        Text("Nessun dato")
          .font(.caption)
          .foregroundStyle(.secondary)
      } else {
        Chart(bins) { bin in
          BarMark(
            x: .value("Intervallo", bin.label),
            y: .value("Immagini", bin.count)
          )
          .foregroundStyle(Color.accentColor)
        }
        .frame(height: 160)
        .chartXAxis {
          AxisMarks(values: .automatic(desiredCount: 5))
        }
      }
    }
  }
  
  private struct Bin: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
  }
  
  private func makeBins(_ values: [Double]) -> [Bin] {
    let finite = values.filter { $0.isFinite }
    guard !finite.isEmpty else { return [] }
    let minValue = finite.min()!
    let maxValue = finite.max()!
    guard maxValue > minValue else {
      return [Bin(label: format(minValue), count: finite.count)]
    }
    
    let binCount = 10
    let width = (maxValue - minValue) / Double(binCount)
    var counts = [Int](repeating: 0, count: binCount)
    for value in finite {
      var index = Int((value - minValue) / width)
      if index >= binCount { index = binCount - 1 }
      counts[index] += 1
    }
    
    return (0..<binCount).map { index in
      let lower = minValue + Double(index) * width
      let upper = lower + width
      return Bin(label: "\(format(lower))–\(format(upper))", count: counts[index])
    }
  }
}

#Preview {
  DatasetView()
}
