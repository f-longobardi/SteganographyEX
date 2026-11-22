import Foundation

struct BatchEntry: Identifiable, Sendable {
  let id = UUID()
  let source: URL
  let clean: URL
  let altered: URL
  let payload: Data
}

struct BatchEncoder: Sendable {
  private let files: ImageFileSource
  private let repository: SteganographyRepository
  
  init(files: ImageFileSource = LocalImageFileSource(),
       repository: SteganographyRepository = SteganographyRepositoryImpl()) {
    self.files = files
    self.repository = repository
  }
  
  struct Result: Sendable {
    var entries: [BatchEntry]
    var failures: [String]
    
    var cleanCount: Int { entries.count }
    var alteredCount: Int { entries.count }
  }
  
  func encode(urls: [URL],
              message: String,
              strategy: EmbeddingStrategyKind,
              outputDirectory: URL,
              fillCapacity: Bool = false,
              onProgress: (@Sendable (Int, Int) -> Void)? = nil) async -> Result {
    let cleanDirectory = outputDirectory.appendingPathComponent("clean", isDirectory: true)
    let alteredDirectory = outputDirectory.appendingPathComponent("altered", isDirectory: true)
    
    var entries: [BatchEntry] = []
    var failures: [String] = []
    
    do {
      try FileManager.default.createDirectory(at: cleanDirectory, withIntermediateDirectories: true)
      try FileManager.default.createDirectory(at: alteredDirectory, withIntermediateDirectories: true)
    } catch {
      return Result(entries: [], failures: ["Impossibile creare la cartella di output: \(error.localizedDescription)"])
    }
    
    for (index, url) in urls.enumerated() {
      await Task.yield()
      onProgress?(index + 1, urls.count)
      do {
        let image = try files.load(from: url)
        let altered: RawImage
        let payload: Data
        if fillCapacity {
            // scrive bit random a capacità
          let filled = try repository.embedFilled(into: image, strategy: strategy)
          altered = filled.image
          payload = filled.payload
        } else {
            // scrive il messaggio come data
          altered = try repository.embed(payload: message, into: image, strategy: strategy)
          payload = Data(message.utf8)
        }
        
        let extensionName = url.pathExtension.isEmpty ? "jpg" : url.pathExtension.lowercased()
        let cleanName = String(format: "%04d", index) + "." + extensionName
        let stegName = String(format: "%04d.png", index)
        let cleanURL = cleanDirectory.appendingPathComponent(cleanName)
        let alteredURL = alteredDirectory.appendingPathComponent(stegName)
        
          // copia per l'elaborazione
        if FileManager.default.fileExists(atPath: cleanURL.path) {
          try? FileManager.default.removeItem(at: cleanURL)
        }
        try FileManager.default.copyItem(at: url, to: cleanURL)
        try files.savePNG(altered.pixels, to: alteredURL)
        
        entries.append(
          BatchEntry(
            source: url,
            clean: cleanURL,
            altered: alteredURL,
            payload: payload
          )
        )
      } catch {
        failures.append("\(url.lastPathComponent): \(error.localizedDescription)")
      }
    }
    
    return Result(entries: entries, failures: failures)
  }
}
