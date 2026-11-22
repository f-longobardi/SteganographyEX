import Foundation
import Observation

@Observable
final class DetectionViewModel {
  private let container: DIContainer
  
  var image: RawImage?
  var result: DetectionResult?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  func load(from url: URL) {
    do {
      image = try container.imageFiles.load(from: url)
      result = nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func detect() {
    guard let image else { return }
    result = container.classifier.classify(image.pixels)
  }
}
