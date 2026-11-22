import Foundation

  ///
  /// SSIM 
struct SSIMCalculator {
  let blockSize: Int

  private static let c1 = pow(0.01 * 255.0, 2)
  private static let c2 = pow(0.03 * 255.0, 2)

  init(blockSize: Int = 8) {
    self.blockSize = blockSize
  }

  /// misura nel canale modificato
  func ssim(original: PixelBuffer, modified: PixelBuffer) -> Double {
    guard original.width == modified.width,
          original.height == modified.height,
          original.width >= blockSize,
          original.height >= blockSize
            else { return .nan }

    return evaluate(Self.blueChannel(original),
                    Self.blueChannel(modified),
                    width: original.width,
                    height: original.height)
  }

  /// Controlla tutti i canali anche se quello modificato è solo il blu.
  func ssimAllChannels(original: PixelBuffer, modified: PixelBuffer) -> Double {
    guard original.width == modified.width,
          original.height == modified.height,
          original.width >= blockSize,
          original.height >= blockSize
            else { return .nan }

    return evaluate(Self.grayscale(original),
                    Self.grayscale(modified),
                    width: original.width,
                    height: original.height)
  }

  private func evaluate(
    _ a: [Double],
    _ b: [Double],
    width: Int,
    height: Int
  ) -> Double {
    var total = 0.0
    var blocks = 0
    for originY in stride(from: 0, to: height - blockSize + 1, by: blockSize) {
      for originX in stride(from: 0, to: width - blockSize + 1, by: blockSize) {
        var sumA = 0.0, sumB = 0.0, sumAA = 0.0, sumBB = 0.0, sumAB = 0.0
        for y in originY..<(originY + blockSize) {
          let row = y * width
          for x in originX..<(originX + blockSize) {
            let va = a[row + x]
            let vb = b[row + x]
            sumA += va
            sumB += vb
            sumAA += va * va
            sumBB += vb * vb
            sumAB += va * vb
          }
        }
        let n = Double(blockSize * blockSize)
        let meanA = sumA / n
        let meanB = sumB / n
        let varA = sumAA / n - meanA * meanA
        let varB = sumBB / n - meanB * meanB
        let covAB = sumAB / n - meanA * meanB
        
        let numerator = (2 * meanA * meanB + Self.c1) * (2 * covAB + Self.c2)
        let denominator = (meanA * meanA + meanB * meanB + Self.c1) * (varA + varB + Self.c2)
        total += numerator / denominator
        blocks += 1
      }
    }
    return blocks > 0 ? total / Double(blocks) : .nan
  }

  private static func blueChannel(_ buffer: PixelBuffer) -> [Double] {
    var result = [Double](repeating: 0, count: buffer.pixelCount)
    for pixel in 0..<buffer.pixelCount {
      result[pixel] = Double(buffer.bytes[pixel * 4 + 2])
    }
    return result
  }

  private static func grayscale(_ buffer: PixelBuffer) -> [Double] {
    var result = [Double](repeating: 0, count: buffer.pixelCount)
    for pixel in 0..<buffer.pixelCount {
      let i = pixel * 4
      let r = Double(buffer.bytes[i])
      let g = Double(buffer.bytes[i + 1])
      let b = Double(buffer.bytes[i + 2])
      result[pixel] = 0.299 * r + 0.587 * g + 0.114 * b
    }
    return result
  }
}
