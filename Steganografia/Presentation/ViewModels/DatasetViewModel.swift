import Foundation
import Observation

  /// Dataset remoto (Hugging Face), download, generazione alterati, analisi
@Observable
final class DatasetViewModel {
  private let container: DIContainer
  
  var images: [URL] = []
  var message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
  var strategy: EmbeddingStrategyKind = .uniform
  
  var fillCapacity = true
  
  var isDownloading = false
  var downloadLabel: String?
  
  var isGenerating = false
  var generateProgress: Double?
  var generateLabel: String?
  
  var isAnalyzing = false
  var analyzeProgress: Double?
  var analyzeLabel: String?
  
  var generated: BatchEncoder.Result?
  var results: [AnalysisResult] = []
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  var canGenerate: Bool { !images.isEmpty && !isDownloading && !isGenerating && !isAnalyzing }
  var canAnalyze: Bool { generated != nil && !isAnalyzing && !isGenerating }
  
  @MainActor
  func download() async {
    guard !isDownloading else { return }
    isDownloading = true
    downloadLabel = "Download di \(RemoteDatasetSource.approximateSize)…"
    images = []
    generated = nil
    results = []
    errorMessage = nil
    status = nil
    defer {
      isDownloading = false
      downloadLabel = nil
    }
    
    do {
      let urls = try await container.remoteDataset.download(to: Self.datasetDirectory)
      images = urls
      status = "\(urls.count) immagini pronte."
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  @MainActor
  func generate() async {
    guard !images.isEmpty, !isGenerating, !isAnalyzing else { return }
    isGenerating = true
    generateProgress = 0
    generateLabel = "Generazione dataset steganografato…"
    generated = nil
    results = []
    errorMessage = nil
    status = nil
    defer {
      isGenerating = false
      generateProgress = nil
      generateLabel = nil
    }
    
    let output = Self.outputDirectory
    try? FileManager.default.removeItem(at: output)
    
    let encoder = container.batchEncoder
    let urls = images
    let message = message
    let strategy = strategy
    let fillCapacity = fillCapacity
    
    let progress: @Sendable (Int, Int) -> Void = { [weak self] done, total in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.generateProgress = total > 0 ? Double(done) / Double(total) : 0
        self.generateLabel = "Codifica \(done)/\(total)"
      }
    }
    
    let result = await Task.detached(priority: .userInitiated) {
      await encoder.encode(
        urls: urls,
        message: message,
        strategy: strategy,
        outputDirectory: output,
        fillCapacity: fillCapacity,
        onProgress: progress
      )
    }.value
    
    generated = result
    status = """
        Classe A (clean): \(result.cleanCount) immagini
        Classe B (alterate): \(result.alteredCount) immagini
        """ + (fillCapacity ? "\nModalità: tutti i bit disponibili" : "")
    + (result.failures.isEmpty ? "" : "\nErrori: \(result.failures.count)")
    if !result.failures.isEmpty {
      errorMessage = result.failures.prefix(5).joined(separator: "\n")
    }
    
    if !result.entries.isEmpty {
      await analyze()
    }
  }
  
  @MainActor
  func analyze() async {
    guard let generated, !generated.entries.isEmpty, !isAnalyzing else { return }
    isAnalyzing = true
    analyzeProgress = 0
    analyzeLabel = "Analisi qualità…"
    errorMessage = nil
    status = nil
    defer {
      isAnalyzing = false
      analyzeProgress = nil
      analyzeLabel = nil
    }
    
    let entries = generated.entries
    let analyzer = container.qualityAnalyzer
    
    let progress: @Sendable (Int, Int) -> Void = { [weak self] done, total in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.analyzeProgress = total > 0 ? Double(done) / Double(total) : 0
        self.analyzeLabel = "Analisi \(done)/\(total)"
      }
    }
    
    let results = await Task.detached(priority: .userInitiated) {
      await analyzer.analyze(entries: entries, onProgress: progress)
    }.value
    
    self.results = results
    status = "Analisi completata: \(results.count) immagini (clean \(generated.cleanCount), alterate \(generated.alteredCount))."
  }
  
  private static var datasetDirectory: URL {
    let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
    ?? FileManager.default.temporaryDirectory
    return base.appendingPathComponent("SteganografiaLab/Dataset", isDirectory: true)
  }
  
  private static var outputDirectory: URL {
    let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    ?? FileManager.default.temporaryDirectory
    return base.appendingPathComponent("SteganografiaLab/GeneratedDataset", isDirectory: true)
  }
}
