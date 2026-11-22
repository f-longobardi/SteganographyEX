import Foundation
import Observation
import SwiftUI

@Observable
final class EmbedViewModel {
  private let container: DIContainer
  
  var sourceImage: RawImage?
  var message = ""
  var strategy: EmbeddingStrategyKind = .uniform
  var stegImage: RawImage?
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
    /// Byte disponibili con la strategia corrente.
  var capacityBytes: Int {
    guard let sourceImage else { return 0 }
    return strategy.strategy.eligiblePixels(in: sourceImage.pixels).count / 8
  }
  
  var payloadBytes: Int { message.utf8.count }
  
  var fits: Bool { payloadBytes <= capacityBytes }
  
  func load(from url: URL) {
    do {
      sourceImage = try container.imageFiles.load(from: url)
      stegImage = nil
      status = nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func embed() {
    guard let sourceImage else { return }
    do {
      stegImage = try container.steganography.embed(payload: message, into: sourceImage, strategy: strategy)
      errorMessage = nil
      status = "Messaggio occultato. Salva l'immagine modificata in PNG."
    } catch {
      stegImage = nil
      errorMessage = error.localizedDescription
    }
  }
  
  func saveStegImage() {
    guard let stegImage, let url = FilePanels.savePNG(suggestedName: stegImage.name) else { return }
    do {
      try container.imageFiles.savePNG(stegImage.pixels, to: url)
      status = "Salvato: \(url.lastPathComponent)"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
