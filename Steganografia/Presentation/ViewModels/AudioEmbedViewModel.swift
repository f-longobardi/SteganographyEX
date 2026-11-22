import Foundation
import Observation
import SwiftUI

@Observable
final class AudioEmbedViewModel {
  private let container: DIContainer
  
  var source: RawAudio?
  var sourceEnvelope: WaveformEnvelope?
  var message = ""
  var steg: RawAudio?
  var stegEnvelope: WaveformEnvelope?
  var status: String?
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  var capacityBytes: Int { source?.samples.payloadCapacityBytes ?? 0 }
  var payloadBytes: Int { message.utf8.count }
  var fits: Bool { payloadBytes <= capacityBytes }
  
  func load(from url: URL) {
    do {
      let audio = try container.audioFiles.load(from: url)
      source = audio
      sourceEnvelope = audio.samples.envelope(buckets: Buckets.envelopeBuckets)
      steg = nil
      stegEnvelope = nil
      status = nil
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func embed() {
    guard let source else { return }
    do {
      let result = try container.audioSteganography.embed(payload: message, into: source)
      steg = result
      stegEnvelope = result.samples.envelope(buckets: Buckets.envelopeBuckets)
      errorMessage = nil
      status = ""
    } catch {
      steg = nil
      stegEnvelope = nil
      errorMessage = error.localizedDescription
    }
  }
  
  func saveAlteredAudio() {
    guard let steg, let url = FilePanels.saveWAV(suggestedName: steg.name) else { return }
    do {
      try container.audioFiles.saveWAV(steg.samples, to: url)
      status = "Salvato: \(url.lastPathComponent)"
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
