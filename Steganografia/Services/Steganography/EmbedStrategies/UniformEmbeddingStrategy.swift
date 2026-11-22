/// embed in tutti i bit disponibili
struct UniformEmbeddingStrategy: EmbeddingStrategy {
    let kind: EmbeddingStrategyKind = .uniform

    func eligiblePixels(in buffer: PixelBuffer) -> [Int] {
        guard buffer.pixelCount > LSBHeader.bitCount else { return [] }
        return Array(LSBHeader.bitCount..<buffer.pixelCount)
    }
}
