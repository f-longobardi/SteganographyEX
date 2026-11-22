import Foundation

/// Recupero messaggio
struct LSBDecoder {
  
  func extract(from buffer: PixelBuffer) throws -> Payload {
    let payload = try extractData(from: buffer)
    guard let text = String(data: payload, encoding: .utf8) else { throw StegError.stringEncodingFailed }
    return text
  }
  
    //  recupera tutti i data - non in stringa
  func extractData(from buffer: PixelBuffer) throws -> Data {
    guard buffer.pixelCount >= LSBHeader.bitCount else { throw StegError.noPayloadFound }
    
    let headerPixels = Array(0..<LSBHeader.bitCount)
    let header = read(from: buffer, pixels: headerPixels, byteCount: LSBHeader.byteCount)
    
    guard let parsed = LSBHeader.extract(header) else { throw StegError.noPayloadFound }
    let kind = parsed.strategy
    let length = parsed.length
    guard length > 0 else { return Data() }
    
    let payloadPixels = kind.strategy.eligiblePixels(in: buffer)
    guard payloadPixels.count >= length * 8 else { throw StegError.noPayloadFound }
    
    return read(from: buffer, pixels: payloadPixels, byteCount: length)
  }
  
  private func read(from buffer: PixelBuffer, pixels: [Int], byteCount: Int) -> Data {
    var data = Data(capacity: byteCount)
    var bitIndex = 0
    for _ in 0..<byteCount {
      var byte: UInt8 = 0
      for _ in 0..<8 {
        byte = (byte << 1) | UInt8(buffer.readLSBOfBlue(at: pixels[bitIndex]))
        bitIndex += 1
      }
      data.append(byte)
    }
    return data
  }
}
