import Foundation

  /// Audio trasformato in Data
struct AudioBuffer {
  let sampleRate: Double
  let channelCount: Int

  var samples: [Int16]
  
  var frameCount: Int {
    channelCount > 0 ? samples.count / channelCount : 0
  }
  var duration: TimeInterval {
    sampleRate > 0 ? Double(frameCount) / sampleRate : 0
  }
  
  @inline(__always)
  func lsb(at index: Int) -> Int {
    Int(samples[index] & 1)
  }
  
  @inline(__always)
  mutating func setLSB(at index: Int, bit: Int) {
    samples[index] = (samples[index] & ~1) | Int16(bit & 1)
  }
  
  var payloadCapacityBytes: Int {
    max(0, samples.count - LSBHeader.bitCount) / 8
  }
}

  /// visualizzatore.
struct WaveformEnvelope {
  var minimums: [Float]
  var maximums: [Float]
  
  var isEmpty: Bool { minimums.isEmpty }
}

extension AudioBuffer {
    /// Visualizzatore
  func envelope(buckets: Int) -> WaveformEnvelope {
    guard buckets > 0, channelCount > 0, frameCount > 0 else {
      return WaveformEnvelope(minimums: [], maximums: [])
    }
    
    let frames = frameCount
    let channels = Float(channelCount)
    var minimums = [Float](repeating: 0, count: buckets)
    var maximums = [Float](repeating: 0, count: buckets)
    
    for bucket in 0..<buckets {
      let start = bucket * frames / buckets
      guard start < frames else { continue }
      let end = min(max((bucket + 1) * frames / buckets, start + 1), frames)
      
      var low = Float.greatestFiniteMagnitude
      var high = -Float.greatestFiniteMagnitude
      
      for frame in start..<end {
        let base = frame * channelCount
        var sum: Float = 0
        for channel in 0..<channelCount {
          sum += Float(samples[base + channel])
        }
        let value = sum / channels / 32768
        low = min(low, value)
        high = max(high, value)
      }
      
      minimums[bucket] = low
      maximums[bucket] = high
    }
    
    return WaveformEnvelope(minimums: minimums, maximums: maximums)
  }
}
