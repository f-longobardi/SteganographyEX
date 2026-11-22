//    Steganografia


import CoreImage
import CoreImage.CIFilterBuiltins
import CoreGraphics
import Foundation

struct CIEdgesFilter: Sendable {
  
  let threshold: Int
  let intensity: Float
  
  init(
    threshold: Int = 128,
    intensity: Float = 1
  ) {
    self.threshold = threshold
    self.intensity = intensity
  }
  
  func edgePixelIndex(in buffer: PixelBuffer) -> [Int] {
    let w = buffer.width
    let h = buffer.height
    guard w > 0, h > 0 else { return [] }
    
    var stableBytes = buffer.bytes
    guard stableBytes.count >= w * h * 4 else { return [] }
    
    for i in stride(from: 0, to: w * h * 4, by: 4) {
      stableBytes[i]     &= 0xFE // R
      stableBytes[i + 1] &= 0xFE // G
      stableBytes[i + 2] &= 0xFE // B
      stableBytes[i + 3] = 255   // A
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let input = CIImage(
      bitmapData: Data(stableBytes),
      bytesPerRow: w * 4,
      size: CGSize(width: w, height: h),
      format: .RGBA8,
      colorSpace: colorSpace
    )
    
    guard let filter = CIFilter(name: "CIEdges") else { return [] }
    filter.setValue(input, forKey: kCIInputImageKey)
    filter.setValue(intensity, forKey: kCIInputIntensityKey)
    
    guard let output = filter.outputImage else { return [] }
    
    let bounds = CGRect(x: 0, y: 0, width: w, height: h)
    let context = CIContext()
    
    guard
      let cgImage = context.createCGImage(output, from: bounds),
      let edgeBuffer = PixelBuffer(cgImage: cgImage)
        else {
      return []
    }
    
    var result: [Int] = []
    result.reserveCapacity(w * h / 8)
    
    for y in 0..<h {
      for x in 0..<w {
        let index = y * w + x
        if edgeBuffer.stableLuminance(at: index) >= threshold {
          result.append(index)
        }
      }
    }
    
    return result
  }
  
  func cannyEdgeIndex(from image: CGImage, intensity: Float = 1) -> [Int] {
    
    let ciImage = CIImage(cgImage: image)
    
    let filter = CIFilter.edges()
    filter.inputImage = ciImage
    filter.intensity = intensity
    
    guard let output = filter.outputImage,
          let cgImage = CIContext().createCGImage(output, from: output.extent) else {
      return []
    }
    
    return edgePixelIndices(from: cgImage)
  }
  
  private func edgePixelIndices(from image: CGImage,
                                threshold: UInt8 = 128) -> [Int] {
    let cgImage = image
    
    let width = cgImage.width
    let height = cgImage.height
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
    
    guard let context = CGContext(
      data: &pixels,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: bytesPerRow,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
      return []
    }
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    var indices: [Int] = []
    for y in 0..<height {
      for x in 0..<width {
        let offset = y * bytesPerRow + x * bytesPerPixel
        let red = pixels[offset]
        let green = pixels[offset + 1]
        let blue = pixels[offset + 2]
        
        if red >= threshold && green >= threshold && blue >= threshold {
          indices.append(y * width + x)
        }
      }
    }
    
    return indices
  }
}
