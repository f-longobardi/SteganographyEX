import Foundation

protocol EmbeddingStrategy {
  var kind: EmbeddingStrategyKind { get }
  func eligiblePixels(in buffer: PixelBuffer) -> [Int]
}

enum EmbeddingStrategyKind: String, CaseIterable, Identifiable, Codable {
  case uniform
  case edgeAware
  
  var id: String { rawValue }
  
  var label: String {
    switch self {
    case .uniform: "Uniform"
    case .edgeAware: "Edge Aware"
    }
  }
  
  var strategy: EmbeddingStrategy {
    switch self {
    case .uniform: UniformEmbeddingStrategy()
    case .edgeAware: EdgeAwareEmbeddingStrategy()
    }
  }
  
    /// un solo byte salvato nell'header per poter decodificare
  var idByte: UInt8 {
    switch self {
    case .uniform: 0
    case .edgeAware: 1
    }
  }
  
  init?(idByte: UInt8) {
    switch idByte {
    case 0:
      self = .uniform
    case 1:
      self = .edgeAware
    default:
      return nil
    }
  }
}
