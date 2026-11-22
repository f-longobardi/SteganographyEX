import Foundation


  // Classificatore
struct SteganographyClassifier {
  var threshold: Double
  var chiSquareWeight: Double
  var balanceWeight: Double
  var entropyWeight: Double
  
  // pesi scelti arbitrariamente
  init(threshold: Double = 0.5,
       chiSquareWeight: Double = 0.7,
       balanceWeight: Double = 0.15,
       entropyWeight: Double = 0.15) {
    self.threshold = threshold
    self.chiSquareWeight = chiSquareWeight
    self.balanceWeight = balanceWeight
    self.entropyWeight = entropyWeight
  }
  
  func classify(_ buffer: PixelBuffer) -> DetectionResult {
    classify(FeatureExtractor().extract(from: buffer))
  }
  
  func classify(_ features: FeatureVector) -> DetectionResult {
    let score = decisionScore(features).clampedToUnit
    let isAltered = score >= threshold
    return DetectionResult(
      classification: isAltered ? .altered : .clean,
      probability: isAltered ? score : 1 - score,
      score: score,
      features: features
    )
  }
  
  func decisionScore(_ features: FeatureVector) -> Double {
    chiSquareWeight * features.chiSquarePValue
    + balanceWeight * features.lsbBalance
    + entropyWeight * features.lsbEntropy
  }
}
