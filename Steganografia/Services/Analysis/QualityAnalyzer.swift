import Foundation

  /// PSNR, SSIM e BER per ogni coppia di immagini di un dataset.
struct QualityAnalyzer: Sendable {
  private let files: ImageFileSource
  private let repository: SteganographyRepository
  private let psnr = PSNRCalculator()
  private let ssim = SSIMCalculator()
  private let ber = BERCalculator()
  
  init(
    files: ImageFileSource = LocalImageFileSource(),
    repository: SteganographyRepository = SteganographyRepositoryImpl()
  ) {
    self.files = files
    self.repository = repository
  }
  
  func analyze(
    entries: [BatchEntry],
    onProgress: (
      @Sendable (Int, Int) -> Void
    )? = nil
  ) async -> [AnalysisResult] {
    var results: [AnalysisResult] = []
    
    for (index, entry) in entries.enumerated() {
      await Task.yield()
      do {
        let clean = try files.load(from: entry.clean)
        let altered = try files.load(from: entry.altered)
        let recovered = try repository.extractData(from: altered)
        
        results.append(AnalysisResult(
          payloadSizeBytes: entry.payload.count,
          psnr: psnr.psnr(original: clean.pixels, modified: altered.pixels),
          ssim: ssim.ssim(original: clean.pixels, modified: altered.pixels),
          ber: ber.ber(reference: entry.payload, recovered: recovered)
        ))
      } catch {
        print(StegError.unreadableImage(""))
      }
      onProgress?(index + 1, entries.count)
    }
    
    return results
  }
}
