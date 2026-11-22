  //    Steganografia

import Foundation

/// Scrittura HEADER
///
///     tokenAuth "SL" (2) | version (1) | strategy (1) | payload length UInt32 BE (4)
///     8 byte
enum LSBHeader {
  static let tokenAuth: [UInt8] = [0x53, 0x4C]
  static let version: UInt8 = 1
  static let byteCount = 8
  static let bitCount = byteCount * 8
  
  static func write(strategy: EmbeddingStrategyKind, length: Int) -> Data {
    let n = UInt32(length)
    var data = Data(tokenAuth)
    data.append(version)
    data.append(strategy.idByte)
    data.append(UInt8((n >> 24) & 0xFF))
    data.append(UInt8((n >> 16) & 0xFF))
    data.append(UInt8((n >> 8) & 0xFF))
    data.append(UInt8(n & 0xFF))
    return data
  }
  
  static func extract(_ data: Data) -> (strategy: EmbeddingStrategyKind, length: Int)? {
    guard data.count == byteCount,
          Array(data.prefix(2)) == tokenAuth,
          data[2] == version,
          let strategy = EmbeddingStrategyKind(idByte: data[3])
            else { return nil }
    
    let b0 = Int(data[4]) << 24
    let b1 = Int(data[5]) << 16
    let b2 = Int(data[6]) << 8
    let b3 = Int(data[7])
    return (strategy, b0 | b1 | b2 | b3)
  }
}
