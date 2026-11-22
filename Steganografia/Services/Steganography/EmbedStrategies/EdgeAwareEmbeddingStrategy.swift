  /// steganografia nei pixel di bordo.
struct EdgeAwareEmbeddingStrategy: EmbeddingStrategy {
  let kind: EmbeddingStrategyKind = .edgeAware
  private let sobel: SobelFilter
  private let kCIEdgesFilter: CIEdgesFilter
  
  init() {
    self.sobel = SobelFilter()
    self.kCIEdgesFilter = CIEdgesFilter()
  }
  
  // 3 alternative di edge detection
  func eligiblePixels(in buffer: PixelBuffer) -> [Int] {
    sobel.edgePixelIndex(in: buffer)
    //kCIEdgesFilter.edgePixelIndex(in: buffer)
    //kCIEdgesFilter.cannyEdgeIndex(from: buffer.cgImage()!)
  }
}
