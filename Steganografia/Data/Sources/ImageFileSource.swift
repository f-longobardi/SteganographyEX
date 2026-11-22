import AppKit
import ImageIO
import UniformTypeIdentifiers

/// load di immagini PNG
protocol ImageFileSource: Sendable {
  func load(from url: URL) throws -> RawImage
  func savePNG(_ pixels: PixelBuffer, to url: URL) throws
}

struct LocalImageFileSource: ImageFileSource {
  
  func load(from url: URL) throws -> RawImage {
    guard let cgImage = Self.cgImage(at: url), let pixels = PixelBuffer(cgImage: cgImage) else {
      throw StegError.unreadableImage(url.lastPathComponent)
    }
    return RawImage(pixels: pixels, name: url.lastPathComponent)
  }
  
  func savePNG(_ pixels: PixelBuffer, to url: URL) throws {
    guard let cgImage = pixels.cgImage(),
          let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            UTType.png.identifier as CFString,
            1,
            nil
          )
    else { throw StegError.encodingFailed }
    
    CGImageDestinationAddImage(destination, cgImage, nil)
    guard CGImageDestinationFinalize(destination) else { throw StegError.encodingFailed }
  }
  
  private static func cgImage(at url: URL) -> CGImage? {
    guard let image = NSImage(contentsOf: url) else { return nil }
    return image.cgImage(forProposedRect: nil, context: nil, hints: nil)
  }
}
