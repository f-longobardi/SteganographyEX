import Foundation


/// implementation of the SteganographyRepository
struct SteganographyRepositoryImpl: SteganographyRepository {
  private let encoder = LSBEncoder()
  private let decoder = LSBDecoder()
  
  func embed(payload: Payload, into image: RawImage, strategy: EmbeddingStrategyKind) throws -> RawImage {
    let modified = try encoder.embed(payload, into: image.pixels, strategy: strategy.strategy)
    return stego(from: modified, of: image)
  }
  
  func embedFilled(into image: RawImage,
                   strategy: EmbeddingStrategyKind) throws -> (image: RawImage, payload: Data) {
    let filled = try encoder.embedFilled(image.pixels, strategy: strategy.strategy)
    return (stego(from: filled.buffer, of: image), filled.payload)
  }
  
  private func stego(from pixels: PixelBuffer, of image: RawImage) -> RawImage {
    let base = (image.name as NSString).deletingPathExtension
    return RawImage(pixels: pixels, name: "\(base)_steg.png")
  }
  
  func extract(from image: RawImage) throws -> Payload {
    try decoder.extract(from: image.pixels)
  }
  
  func extractData(from image: RawImage) throws -> Data {
    try decoder.extractData(from: image.pixels)
  }
}
