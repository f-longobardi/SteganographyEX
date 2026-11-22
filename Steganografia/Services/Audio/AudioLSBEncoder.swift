import Foundation

  /// Nasconde un messaggio UTF-8 nei bit meno significativi, header è sempre uniform
struct AudioLSBEncoder {
  
  func embed(_ payload: Payload, into audio: AudioBuffer) throws -> AudioBuffer {
    guard audio.samples.count >= LSBHeader.bitCount else {
      throw StegError.insufficientCapacity(available: 0, required: 1)
    }
    
    let message = Data(payload.utf8)
    let available = audio.payloadCapacityBytes
    guard message.count <= available else {
      throw StegError.insufficientCapacity(available: available, required: message.count)
    }
    
    var output = audio
    write(LSBHeader.write(strategy: .uniform, length: message.count), into: &output, start: 0)
    write(message, into: &output, start: LSBHeader.bitCount)
    return output
  }
  
  private func write(_ data: Data, into audio: inout AudioBuffer, start: Int) {
    var index = start
    for byte in data {
      for shift in stride(from: 7, through: 0, by: -1) {
        audio.setLSB(at: index, bit: Int((byte >> UInt8(shift)) & 1))
        index += 1
      }
    }
  }
}
