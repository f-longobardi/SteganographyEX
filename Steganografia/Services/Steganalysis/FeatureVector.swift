import Foundation

/// vettore di caratteristiche per il classificatore.
struct FeatureVector {
  var lsbOnesRatio: Double
  var lsbBalance: Double
  var lsbEntropy: Double
  var rgbEntropy: Double
  var histogramVariance: Double
  var chiSquarePValue: Double
  
  var values: [Double] {
    [lsbOnesRatio, lsbBalance, lsbEntropy, rgbEntropy, histogramVariance, chiSquarePValue]
  }
  
  var labels: [String] {
    ["LSB ones ratio", "LSB balance", "LSB entropy", "RGB entropy", "Histogram", "Chi-square"]
  }
}

struct FeatureExtractor {
  private let lsbAnalyzer = LSBStatisticsAnalyzer()
  private let entropyCalculator = EntropyCalculator()
  private let histogramAnalyzer = HistogramAnalyzer()
  private let chiSquareAnalyzer = ChiSquareAnalyzer()
  
  func extract(from buffer: PixelBuffer) -> FeatureVector {
    let lsb = lsbAnalyzer.analyze(buffer)
    let entropy = entropyCalculator.entropy(buffer)
    let histogram = histogramAnalyzer.analyze(buffer)
    let chiSquare = chiSquareAnalyzer.analyze(buffer)
    
    return FeatureVector(
      lsbOnesRatio: lsb.overallOnesRatio,
      lsbBalance: lsb.balance,
      lsbEntropy: lsb.entropy,
      rgbEntropy: entropy.mean,
      histogramVariance: histogram.meanVariance,
      chiSquarePValue: chiSquare.pValue
    )
  }
}
