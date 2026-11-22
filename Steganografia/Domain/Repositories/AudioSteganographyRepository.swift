import Foundation

protocol AudioSteganographyRepository {
  func embed(payload: Payload, into audio: RawAudio) throws -> RawAudio
  func extract(from audio: RawAudio) throws -> Payload
}
