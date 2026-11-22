import Foundation

protocol SteganographyRepository: Sendable {
    func embed(payload: Payload, into image: RawImage, strategy: EmbeddingStrategyKind) throws -> RawImage
    /// Riempie tutti i bit disponibili
    func embedFilled(into image: RawImage, strategy: EmbeddingStrategyKind) throws -> (image: RawImage, payload: Data)
    func extract(from image: RawImage) throws -> Payload
    /// Estrazione binaria senza decodifica in stringa UTF-8
    func extractData(from image: RawImage) throws -> Data
}
