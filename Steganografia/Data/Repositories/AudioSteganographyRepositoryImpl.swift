import Foundation

struct AudioSteganographyRepositoryImpl: AudioSteganographyRepository {
  private let encoder = AudioLSBEncoder()
  private let decoder = AudioLSBDecoder()
  
  func embed(payload: Payload, into audio: RawAudio) throws -> RawAudio {
    let modified = try encoder.embed(payload, into: audio.samples)
    let base = (audio.name as NSString).deletingPathExtension
    return RawAudio(samples: modified, name: "\(base)_steg.wav")
  }
  
  func extract(from audio: RawAudio) throws -> Payload {
    try decoder.extract(from: audio.samples)
  }
}
