import Foundation

/// Rapporto Segnale - Rumore per immagini
struct PSNRCalculator {
  
  func psnr(original: PixelBuffer, modified: PixelBuffer) -> Double {
    guard original.width == modified.width,
          original.height == modified.height,
          original.bytes.count == modified.bytes.count
            else { return .nan }
    
    var sum = 0.0
    var samples = 0
    
    for i in stride(from: 0, to: original.bytes.count, by: 4) {
      for channel in 0..<3 {

        let delta = Double(original.bytes[i + channel]) - Double(modified.bytes[i + channel])
        sum += delta * delta
        samples += 1
      }
    }
    guard samples > 0 else { return .infinity }
    
    // errore quadratico medio
    let mse = sum / Double(samples)
    guard mse > 0 else { return .infinity }
    return 10 * log10((255.0 * 255.0) / mse)
  }
}
