import Foundation
import Observation

  /// analisi recupera payload, PSNR, SSIM, BER.
@Observable
final class AnalysisViewModel {
  private let container: DIContainer
  
  var original: RawImage?
  var altered: RawImage?
    /// Optional: Messaggio se noto, serve per calcolare il BER.
  var expectedMessage = ""
  
  var result: AnalysisResult?
  var extractedMessage: String?
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  func loadOriginal(from url: URL) { original = try? container.imageFiles.load(from: url); reset() }
  func loadAltered(from url: URL) { altered = try? container.imageFiles.load(from: url); reset() }
  
  func analyze() {
    guard let original, let altered else { return }
    
    let psnr = PSNRCalculator().psnr(original: original.pixels, modified: altered.pixels)
    let ssim = SSIMCalculator().ssim(original: original.pixels, modified: altered.pixels)
    
    var payloadBytes = 0
    var ber = 0.0
    extractedMessage = nil
    
    if let payload = try? container.steganography.extract(from: altered) {
      extractedMessage = payload
      payloadBytes = payload.utf8.count
      if !expectedMessage.isEmpty {
        ber = BERCalculator().ber(reference: expectedMessage, recovered: payload)
      }
      status = "Payload rilevato nell'immagine alterata."
    } else {
      status = "Nessun payload nell'immagine alterata: BER non calcolabile."
    }
    
    result = AnalysisResult(payloadSizeBytes: payloadBytes, psnr: psnr, ssim: ssim, ber: ber)
    errorMessage = nil
  }
  
  private func reset() {
    result = nil
    extractedMessage = nil
    status = nil
    errorMessage = nil
  }
}
