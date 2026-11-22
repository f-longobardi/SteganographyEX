import Foundation


struct EvaluationReport {
  var truePositives: Int
  var falsePositives: Int
  var trueNegatives: Int
  var falseNegatives: Int
  
  var total: Int { truePositives + falsePositives + trueNegatives + falseNegatives }
  
  var accuracy: Double {
    total > 0 ? Double(truePositives + trueNegatives) / Double(total) : .nan
  }
  
  var precision: Double {
    let denominator = truePositives + falsePositives
    return denominator > 0 ? Double(truePositives) / Double(denominator) : .nan
  }
  
  var recall: Double {
    let denominator = truePositives + falseNegatives
    return denominator > 0 ? Double(truePositives) / Double(denominator) : .nan
  }
  
  var f1: Double {
    let denominator = precision + recall
    return denominator > 0 ? 2 * precision * recall / denominator : .nan
  }
  
  var summary: String {
        """
        Immagini: \(total)
        Accuracy:  \(Self.percent(accuracy))
        Precision: \(Self.percent(precision))
        Recall:    \(Self.percent(recall))
        F1:        \(Self.percent(f1))
        TP \(truePositives) · FP \(falsePositives) · TN \(trueNegatives) · FN \(falseNegatives)
        """
  }
  
  private static func percent(_ value: Double) -> String {
    value.isNaN ? "n/d" : String(format: "%.1f%%", value * 100)
  }
}

struct ClassifierEvaluator {
  
  func evaluate(_ samples: [(expected: StegClass, predicted: StegClass)]) -> EvaluationReport {
    var report = EvaluationReport(
      truePositives: 0,
      falsePositives: 0,
      trueNegatives: 0,
      falseNegatives: 0
    )
    for sample in samples {
      switch (sample.expected, sample.predicted) {
      case (.altered, .altered):
        report.truePositives += 1
      case (.clean, .altered):
        report.falsePositives += 1
      case (.clean, .clean):
        report.trueNegatives += 1
      case (.altered, .clean):
        report.falseNegatives += 1
      }
    }
    return report
  }
}
