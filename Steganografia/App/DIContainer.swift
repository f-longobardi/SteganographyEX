import Foundation

  /// dependency injection container
final class DIContainer: Sendable {
  static let shared = DIContainer()
  
  let imageFiles: ImageFileSource = LocalImageFileSource()
  let steganography: SteganographyRepository = SteganographyRepositoryImpl()
  let audioFiles: AudioFileSource = LocalAudioFileSource()
  let audioSteganography: AudioSteganographyRepository = AudioSteganographyRepositoryImpl()
  let remoteDataset = RemoteDatasetSource()
  let batchEncoder = BatchEncoder()
  let qualityAnalyzer = QualityAnalyzer()
  let classifier = SteganographyClassifier()
  let evaluator = ClassifierEvaluator()
  let experiments = ExperimentRunner()
  
  private init() {}
}
