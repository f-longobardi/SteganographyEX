import CoreGraphics

/// An image held as raw pixels
struct RawImage: Sendable {
  var pixels: PixelBuffer
  var name: String
  
  var cgImage: CGImage? { pixels.cgImage() }
}
