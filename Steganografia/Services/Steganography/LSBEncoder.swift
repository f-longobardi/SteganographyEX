import Foundation

  /// codifica messaggio UTF-8 nei bit meno significativi del canale blu
struct LSBEncoder {
  
  func embed(_ payload: Payload, into buffer: PixelBuffer, strategy: EmbeddingStrategy) throws -> PixelBuffer {
    guard buffer.pixelCount >= LSBHeader.bitCount else {
      throw StegError.insufficientCapacity(available: 0, required: 1)
    }
    
    let message = Data(payload.utf8)
    let payloadPixels = strategy.eligiblePixels(in: buffer)
    
    guard payloadPixels.count >= message.count * 8 else {
      throw StegError.insufficientCapacity(
        available: payloadPixels.count / 8,
        required: message.count
      )
    }
    
    return embed(message, into: buffer, pixels: payloadPixels, strategy: strategy.kind)
  }
  
    /// usa tutti i pixel disponibili return (buffer, payload)
  func embedFilled(_ buffer: PixelBuffer,
                   strategy: EmbeddingStrategy) throws -> (buffer: PixelBuffer, payload: Data) {
    guard buffer.pixelCount >= LSBHeader.bitCount else {
      throw StegError.insufficientCapacity(available: 0, required: 1)
    }
    
    let payloadPixels = strategy.eligiblePixels(in: buffer)
    let payload = Self.randomFiller(bytes: payloadPixels.count / 8)
    let output = embed(payload, into: buffer, pixels: payloadPixels, strategy: strategy.kind)
    return (output, payload)
  }
  
    /// Byte casuali con seed
  private static func randomFiller(bytes: Int) -> Data {
    guard bytes > 0 else { return Data() }
    var rng = SeededGenerator(state: fillerSeed &+ UInt64(bytes))
    var data = Data(capacity: bytes)
    for _ in 0..<bytes {
      data.append(UInt8.random(in: 0...255, using: &rng))
    }
    return data
  }
  
  private func embed(_ message: Data,
                     into buffer: PixelBuffer,
                     pixels: [Int],
                     strategy: EmbeddingStrategyKind) -> PixelBuffer {
    var output = buffer
    
      // scrive nell'header la strategia e la durata del messaggio
    write(LSBHeader.write(strategy: strategy, length: message.count),
          into: &output,
          pixels: Array(0..<LSBHeader.bitCount))
    write(message, into: &output, pixels: pixels)
    return output
  }
  
  
    // seed statico per il random
  static let fillerSeed: UInt64 = 0x5EED_5EED_0000_0001
  
  private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    
    mutating func next() -> UInt64 {
      state &+= 0x9E37_79B9_7F4A_7C15
      var z = state
      z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
      z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
      return z ^ (z >> 31)
    }
  }
  
  private func write(_ data: Data, into buffer: inout PixelBuffer, pixels: [Int]) {
    var bitIndex = 0
    for byte in data {
      for shift in stride(from: 7, through: 0, by: -1) {
        buffer.setLSBOfBlue(at: pixels[bitIndex], bit: Int((byte >> UInt8(shift)) & 1))
        bitIndex += 1
      }
    }
  }
}
