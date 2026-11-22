  //    Steganografia

import CoreGraphics
import Foundation

  /// RGBA8 pixel buffer. from CGImage to [Data]
  ///
  /// Memory layout is rows R, G, B, Alpha
struct PixelBuffer: Sendable {
  let width: Int
  let height: Int
  var bytes: [UInt8]
  
  var pixelCount: Int { width * height }
  
  init?(cgImage: CGImage) {
    let w = cgImage.width
    let h = cgImage.height
    guard w > 0, h > 0 else { return nil }
    
      // empty array
    var data = [UInt8](repeating: 0, count: w * h * 4)
    let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
      .union(.byteOrder32Big)
    let ok: Bool = data.withUnsafeMutableBytes { raw in
      guard let context = CGContext(
        data: raw.baseAddress,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: w * 4,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: info.rawValue
      ) else { return false }
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
      return true
    }
    guard ok else { return nil }
    
      // alpha not used
    for i in stride(from: 3, to: data.count, by: 4) {
      data[i] = 255
    }
    
    self.width = w
    self.height = h
    self.bytes = data
  }
  
  init(width: Int, height: Int) {
    self.width = width
    self.height = height
    self.bytes = [UInt8](repeating: 0, count: width * height * 4)
  }
  
  func cgImage() -> CGImage? {
    let info = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
      .union(.byteOrder32Big)
    guard let provider = CGDataProvider(data: Data(bytes) as CFData) else { return nil }
    return CGImage(
      width: width,
      height: height,
      bitsPerComponent: 8,
      bitsPerPixel: 32,
      bytesPerRow: width * 4,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: info,
      provider: provider,
      decode: nil,
      shouldInterpolate: false,
      intent: .defaultIntent
    )
  }
  
    /// `channel`: 0 = red, 1 = green, 2 = blue.
  @inline(__always)
  func channel(_ channel: Int, at pixel: Int) -> UInt8 {
    bytes[pixel * 4 + channel]
  }
  
  @inline(__always)
  func readLSBOfBlue(at pixel: Int) -> Int {
    Int(bytes[pixel * 4 + 2] & 1)
  }
  
  @inline(__always)
  mutating func setLSBOfBlue(at pixel: Int, bit: Int) {
    bytes[pixel * 4 + 2] = (bytes[pixel * 4 + 2] & 0xFE) | UInt8(bit & 1)
  }
  
    /// for Edge detection
  @inline(__always)
  func stableLuminance(at pixel: Int) -> Int {
    let i = pixel * 4
    let r = Int(bytes[i] & 0xFE)
    let g = Int(bytes[i + 1] & 0xFE)
    let b = Int(bytes[i + 2] & 0xFE)
    return (r * 299 + g * 587 + b * 114) / 1000
  }
}
