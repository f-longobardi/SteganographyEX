import Foundation

struct ExperimentRunner {
  private let files: ImageFileSource
  private let repository: SteganographyRepository
  private let psnr = PSNRCalculator()
  private let ssim = SSIMCalculator()
  private let ber = BERCalculator()
  private let classifier: SteganographyClassifier
  private let evaluator = ClassifierEvaluator()
  
  static let payloadSizes = [100, 500, 1024, 5120, 10240]
  
  init(files: ImageFileSource = LocalImageFileSource(),
       repository: SteganographyRepository = SteganographyRepositoryImpl(),
       classifier: SteganographyClassifier = SteganographyClassifier()) {
    self.files = files
    self.repository = repository
    self.classifier = classifier
  }
  
  struct Row: Identifiable {
    let id = UUID()
    var experiment: String
    var payloadBytes: Int?
    var strategy: EmbeddingStrategyKind
    var psnr: Double
    var ssim: Double
    var ber: Double
    var note: String = ""
  }
  
  func payloadExperiment(image: RawImage) -> [Row] {
    Self.payloadSizes.map { size in
      let message = Self.message(ofBytes: size)
      return measure(message: message, image: image, strategy: .uniform, experiment: "Payload \(size) B")
    }
  }
  
  func strategyComparison(image: RawImage, payloadBytes: Int) -> [Row] {
    let message = Self.message(ofBytes: payloadBytes)
    return EmbeddingStrategyKind.allCases.map { kind in
      measure(message: message, image: image, strategy: kind, experiment: kind.label)
    }
  }
  
  
  private func measure(
    message: String,
    image: RawImage,
    strategy: EmbeddingStrategyKind,
    experiment: String
  ) -> Row {
    do {
      let altered = try repository.embed(payload: message, into: image, strategy: strategy)
      let recovered = try repository.extract(from: altered)
      return Row(
        experiment: experiment,
        payloadBytes: message.utf8.count,
        strategy: strategy,
        psnr: psnr.psnr(original: image.pixels, modified: altered.pixels),
        ssim: ssim.ssim(original: image.pixels, modified: altered.pixels),
        ber: ber.ber(reference: message, recovered: recovered) ?? .nan
      )
    } catch {
      return Row(
        experiment: experiment,
        payloadBytes: message.utf8.count,
        strategy: strategy,
        psnr: .nan,
        ssim: .nan,
        ber: .nan,
        note: error.localizedDescription
      )
    }
  }
  
  static func message(ofBytes size: Int) -> String {
    guard size > 0 else { return "" }
    let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ")
    return String((0..<size).map { alphabet[$0 % alphabet.count] })
  }
}
