import AppKit
import Foundation

protocol DatasetSource {
  func images(in folder: URL) -> [URL]
}

struct LocalDatasetSource: DatasetSource {
  static let supportedExtensions: Set<String> = ["png", "jpg", "jpeg", "tiff", "tif", "bmp", "heic"]
  
  func images(in folder: URL) -> [URL] {
    guard let enumerator = FileManager.default.enumerator(
      at: folder,
      includingPropertiesForKeys: [.isRegularFileKey],
      options: [.skipsHiddenFiles]
    ) else { return [] }
    
    var urls: [URL] = []
    for case let url as URL in enumerator {
      guard Self.supportedExtensions.contains(url.pathExtension.lowercased()) else { continue }
      let isFile = (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile ?? false
      guard isFile, Self.isLoadable(url) else { continue }
      urls.append(url)
    }
    return urls.sorted { $0.path < $1.path }
  }
  
  private static func isLoadable(_ url: URL) -> Bool {
    NSImage(contentsOf: url) != nil
  }
}

  /// Scarica il dataset pk3388/watches da HuggingFace in zip da 60 MB
struct RemoteDatasetSource: Sendable {
  static let datasetID = "pk3388/watches"
  static let datasetURL = URL(string: "https://huggingface.co/datasets/pk3388/watches")!
  static let archiveURL = URL(string: "https://huggingface.co/datasets/pk3388/watches/resolve/main/archive.zip")!
  static let approximateSize = "circa 65 MB"
  
  func download(to directory: URL) async throws -> [URL] {
    let fileManager = FileManager.default
    try? fileManager.removeItem(at: directory)
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 300
    configuration.timeoutIntervalForResource = 600
    let session = URLSession(configuration: configuration)
    defer { session.finishTasksAndInvalidate() }
    
    let (tempURL, response) = try await session.download(from: Self.archiveURL)
    guard let http = response as? HTTPURLResponse,
          (200..<300).contains(http.statusCode)
            else { throw URLError(.badServerResponse) }
    
    let zipURL = directory.appendingPathComponent("archive.zip")
    try? fileManager.removeItem(at: zipURL)
    try fileManager.moveItem(at: tempURL, to: zipURL)
    
    try unzip(zipURL, to: directory)
    try? fileManager.removeItem(at: zipURL)
    
    return LocalDatasetSource().images(in: directory)
  }
  
  private func unzip(_ archive: URL, to directory: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/ditto")
    process.arguments = ["-x", "-k", archive.path, directory.path]
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { throw StegError.datasetDownloadFailed }
  }
}
