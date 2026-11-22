import Foundation
import Observation

@Observable
final class ExperimentViewModel {
  private let container: DIContainer
  
  var image: RawImage?
  var payloadBytes = 500
  var rows: [ExperimentRunner.Row] = []
  var errorMessage: String?
  
  init(container: DIContainer? = nil) {
    self.container = container ?? .shared
  }
  
  func load(from url: URL) {
    do {
      image = try container.imageFiles.load(from: url)
      rows = []
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
  
  func runPayloadExperiment() {
    guard let image else { return }
    rows = container.experiments.payloadExperiment(image: image)
  }
  
  func runStrategyComparison() {
    guard let image else { return }
    rows = container.experiments.strategyComparison(image: image, payloadBytes: payloadBytes)
  }
}
