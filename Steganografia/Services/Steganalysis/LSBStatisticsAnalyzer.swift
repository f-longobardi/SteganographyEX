import Foundation

/// bit meno significativi.
struct LSBStatistics {
    /// Frazione di LSB a 1 per canale R, G, B.
  var onesRatio: [Double]
  var zerosRatio: [Double]
  var overallOnesRatio: Double
  
    /// 1 quando R, G e B hanno LSB perfettamente bilanciati
  var balance: Double {
    max(0, 1 - 2 * abs(overallOnesRatio - 0.5))
  }
  
  var entropy: Double {
    guard overallOnesRatio > 0, overallOnesRatio < 1 else { return 0 }
    let p = overallOnesRatio
    return -(p * log2(p) + (1 - p) * log2(1 - p))
  }
}

struct LSBStatisticsAnalyzer {
  
  func analyze(_ buffer: PixelBuffer) -> LSBStatistics {
    var ones = [0, 0, 0]
    let pixels = buffer.pixelCount
    
    for pixel in 0..<pixels {
      for channel in 0..<3 {
        ones[channel] += Int(buffer.channel(channel, at: pixel) & 1)
      }
    }
    
    let total = max(pixels, 1)
    let onesRatio = ones.map { Double($0) / Double(total) }
    let overall = Double(ones.reduce(0, +)) / Double(total * 3)
    
    return LSBStatistics(
      onesRatio: onesRatio,
      zerosRatio: onesRatio.map { 1 - $0 },
      overallOnesRatio: overall
    )
  }
}
