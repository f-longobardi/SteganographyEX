import Foundation

struct AnalysisResult: Sendable {
  var payloadSizeBytes: Int
  var psnr: Double
  var ssim: Double
  var ber: Double
  
  var payloadSizeText: String {
    let formatter = ByteCountFormatter()
    formatter.allowedUnits = [.useBytes, .useKB]
    formatter.countStyle = .file
    return formatter.string(fromByteCount: Int64(payloadSizeBytes))
  }
  
  var psnrText: String { psnr.isInfinite ? "∞ dB" : String(format: "%.3f dB", psnr) }
  var ssimText: String { String(format: "%.4f", ssim) }
  var berText: String { String(format: "%.6f", ber) }
}
