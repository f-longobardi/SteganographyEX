import Foundation

/// entropia di Shannon dei canali RGB.
struct EntropyResult {
  var red: Double
  var green: Double
  var blue: Double
  
  var mean: Double { (red + green + blue) / 3 }
}

struct EntropyCalculator {
  
  func entropy(_ buffer: PixelBuffer) -> EntropyResult {
    var histograms = [[Int]](repeating: [Int](repeating: 0, count: 256), count: 3)
    for pixel in 0..<buffer.pixelCount {
      for channel in 0..<3 {
        histograms[channel][Int(buffer.channel(channel, at: pixel))] += 1
      }
    }
    let total = buffer.pixelCount
    return EntropyResult(
      red: Self.shannon(histograms[0], total: total),
      green: Self.shannon(histograms[1], total: total),
      blue: Self.shannon(histograms[2], total: total)
    )
  }
  
  static func shannon(_ histogram: [Int], total: Int) -> Double {
    guard total > 0 else { return 0 }
    var entropy = 0.0
    for count in histogram where count > 0 {
      let p = Double(count) / Double(total)
      entropy -= p * log2(p)
    }
    return entropy
  }
}
