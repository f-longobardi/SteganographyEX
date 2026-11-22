import Foundation

enum StegClass: String, CaseIterable, Identifiable {
  case clean = "CLEAN"
  case altered = "ALTERED"
  
  var id: String { rawValue }
}

struct DetectionResult {
  var classification: StegClass
  
  var probability: Double
  
  var score: Double
  
  var features: FeatureVector
  
  var probabilityText: String { String(format: "%.0f%%", probability * 100) }
}
