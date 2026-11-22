  //    Steganografia

  /// Sobel
struct SobelFilter {
  
  let threshold: Int
  
  init(threshold: Int = 128) {
    self.threshold = threshold
  }
  
  func edgePixelIndex(in buffer: PixelBuffer) -> [Int] {
    let w = buffer.width
    let h = buffer.height
    guard w > 2, h > 2 else { return [] }
    
    let limit = threshold * threshold
    var result: [Int] = []
    
    for y in 1..<(h - 1) {
      for x in 1..<(w - 1) {
        let topLeft = lum(buffer, x - 1, y - 1)
        let top = lum(buffer, x, y - 1)
        let topRight = lum(buffer, x + 1, y - 1)
        let left = lum(buffer, x - 1, y)
        let right = lum(buffer, x + 1, y)
        let bottomLeft = lum(buffer, x - 1, y + 1)
        let bottom = lum(buffer, x, y + 1)
        let bottomRight = lum(buffer, x + 1, y + 1)
        
        let gx = -topLeft - 2 * left - bottomLeft + topRight + 2 * right + bottomRight
        let gy = -topLeft - 2 * top - topRight + bottomLeft + 2 * bottom + bottomRight
        
        if gx * gx + gy * gy > limit {
          result.append(y * w + x)
        }
      }
    }
    return result
  }
  
  private func lum(_ buffer: PixelBuffer, _ x: Int, _ y: Int) -> Int {
    buffer.stableLuminance(at: y * buffer.width + x)
  }
}
