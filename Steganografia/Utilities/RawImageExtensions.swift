  //    Steganografia

import AppKit

extension RawImage {
    /// https://developer.apple.com/documentation/appkit/nsimage
  var nsImage: NSImage? {
    guard let cgImage else { return nil }
    return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
  }
}
