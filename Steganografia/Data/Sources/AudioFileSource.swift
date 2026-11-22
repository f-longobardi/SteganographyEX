import AVFoundation
import Foundation

/// Apertura / esportazione di audio PCM da disco.
protocol AudioFileSource {
  func load(from url: URL) throws -> RawAudio
  func saveWAV(_ samples: AudioBuffer, to url: URL) throws
}

struct LocalAudioFileSource: AudioFileSource {
  
    /// Legge un formato decodificabile di default av foundation dovrebbe supportare (WAV, AIFF, M4A, MP3, OGG) converte in PCM a 16 bit:
  func load(from url: URL) throws -> RawAudio {
    let file: AVAudioFile
    do {
      file = try AVAudioFile(forReading: url, commonFormat: .pcmFormatInt16, interleaved: false)
    } catch {
      throw StegError.unreadableAudio(url.lastPathComponent)
    }
    
    let format = file.processingFormat
    let channelCount = Int(format.channelCount)
    let capacity = AVAudioFrameCount(file.length)
    guard channelCount > 0, capacity > 0,
          let pcm = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity)
            else { throw StegError.unreadableAudio(url.lastPathComponent) }
    
    try file.read(into: pcm)
    guard let channels = pcm.int16ChannelData else {
      throw StegError.unreadableAudio(url.lastPathComponent)
    }
    
    let frames = Int(pcm.frameLength)
    var samples = [Int16](repeating: 0, count: frames * channelCount)
    for channel in 0..<channelCount {
      let source = channels[channel]
      for frame in 0..<frames {
        samples[frame * channelCount + channel] = source[frame]
      }
    }
    
    return RawAudio(
      samples: AudioBuffer(sampleRate: format.sampleRate, channelCount: channelCount, samples: samples),
      name: url.lastPathComponent
    )
  }
  
  func saveWAV(_ audio: AudioBuffer, to url: URL) throws {
    let settings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: audio.sampleRate,
      AVNumberOfChannelsKey: audio.channelCount,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
      AVLinearPCMIsNonInterleaved: false,
    ]
    
    let file: AVAudioFile
    do {
      file = try AVAudioFile(forWriting: url, settings: settings,
                             commonFormat: .pcmFormatInt16, interleaved: false)
    } catch {
      throw StegError.encodingFailed
    }
    
    let format = file.processingFormat
    let channelCount = Int(format.channelCount)
    let frames = audio.frameCount
    guard channelCount == audio.channelCount,
          let pcm = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frames)),
          let channels = pcm.int16ChannelData
            else { throw StegError.encodingFailed }
    
    for channel in 0..<channelCount {
      let destination = channels[channel]
      for frame in 0..<frames {
        destination[frame] = audio.samples[frame * channelCount + channel]
      }
    }
    
    pcm.frameLength = AVAudioFrameCount(frames)
    do {
      try file.write(from: pcm)
    } catch {
      throw StegError.encodingFailed
    }
  }
}
