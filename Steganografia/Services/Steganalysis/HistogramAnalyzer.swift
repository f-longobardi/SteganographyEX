import Foundation

/// istogrammi RGB e relative feature colore.
struct HistogramFeatures {
    /// Istogrammi normalizzati, un array da 256 valori per canale R, G, B.
    var channels: [[Double]]
    /// Varianza 
    var variance: [Double]

    var meanVariance: Double {
        variance.isEmpty ? 0 : variance.reduce(0, +) / Double(variance.count)
    }
}

struct HistogramAnalyzer {
  
  func analyze(_ buffer: PixelBuffer) -> HistogramFeatures {
    var counts = [[Int]](repeating: [Int](repeating: 0, count: 256), count: 3)
    for pixel in 0..<buffer.pixelCount {
      for channel in 0..<3 {
        counts[channel][Int(buffer.channel(channel, at: pixel))] += 1
      }
    }
    
    let total = Double(max(buffer.pixelCount, 1))
    var normalized = [[Double]](repeating: [Double](repeating: 0, count: 256), count: 3)
    var variances: [Double] = []
    
    for channel in 0..<3 {
      let probabilities = counts[channel].map { Double($0) / total }
      normalized[channel] = probabilities
      let mean = probabilities.reduce(0, +) / 256
      let variance = probabilities.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / 256
      variances.append(variance)
    }
    
    return HistogramFeatures(channels: normalized, variance: variances)
  }
}
