import Foundation

  /// Recupera il messaggio dal file audio
struct AudioLSBDecoder {
  
  func extract(from audio: AudioBuffer) throws -> Payload {
    guard audio.samples.count >= LSBHeader.bitCount else { throw StegError.noPayloadFound }
    
    let header = read(from: audio, start: 0, byteCount: LSBHeader.byteCount)
    guard let parsed = LSBHeader.extract(header) else { throw StegError.noPayloadFound }
    
    let length = parsed.length
    guard length > 0 else { return "" }
    guard audio.payloadCapacityBytes >= length else { throw StegError.noPayloadFound }
    
    let payload = read(from: audio, start: LSBHeader.bitCount, byteCount: length)
    guard let text = String(data: payload, encoding: .utf8) else { throw StegError.stringEncodingFailed }
    return text
  }
  
  private func read(from audio: AudioBuffer, start: Int, byteCount: Int) -> Data {
    var data = Data(capacity: byteCount)
    var index = start
    for _ in 0..<byteCount {
      var byte: UInt8 = 0
      for _ in 0..<8 {
        byte = (byte << 1) | UInt8(audio.lsb(at: index))
        index += 1
      }
      data.append(byte)
    }
    return data
  }
}
