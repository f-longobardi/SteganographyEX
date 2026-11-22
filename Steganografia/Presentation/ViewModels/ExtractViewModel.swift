import Foundation
import Observation

@Observable
final class ExtractViewModel {
  private let container: DIContainer
  
  var sourceImage: RawImage?
  var message: String?
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  func load(from url: URL) {
    do {
      sourceImage = try container.imageFiles.load(from: url)
      message = nil
      status = nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func extract() {
    guard let sourceImage else { return }
    do {
      let payload = try container.steganography.extract(from: sourceImage)
      message = payload
      errorMessage = nil
      status = "Messaggio recuperato (\(payload.utf8.count) byte)."
    } catch {
      message = nil
      errorMessage = error.localizedDescription
    }
  }
}
