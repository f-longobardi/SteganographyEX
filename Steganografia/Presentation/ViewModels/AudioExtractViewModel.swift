import Foundation
import Observation
import SwiftUI

@Observable
final class AudioExtractViewModel {
  private let container: DIContainer
  
  var source: RawAudio?
  var sourceEnvelope: WaveformEnvelope?
  var message: String?
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  func load(from url: URL) {
    do {
      let audio = try container.audioFiles.load(from: url)
      source = audio
      sourceEnvelope = audio.samples.envelope(buckets: Buckets.envelopeBuckets)
      message = nil
      status = nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func extract() {
    guard let source else { return }
    do {
      let payload = try container.audioSteganography.extract(from: source)
      message = payload
      errorMessage = nil
      status = "Messaggio recuperato (\(payload.utf8.count) byte)."
    } catch {
      message = nil
      errorMessage = error.localizedDescription
    }
  }
}
