import AppKit
import SwiftUI
import UniformTypeIdentifiers

/// Output lossless
extension UTType {
    /// Formati immagine accettati in ingresso. L'output è sempre PNG
  static let importableImages: [UTType] = [.png, .jpeg, .tiff, .bmp, .heic]
  
    /// Formati audio accettati in ingresso. L'output è sempre WAV
  static let importableAudio: [UTType] = [.audio]
}

enum Multimedia: String, CaseIterable, Identifiable {
  case image
  case audio
  
  var id: String { rawValue }
  
  var label: String {
    switch self {
    case .image: "Immagine"
    case .audio: "Audio"
    }
  }
}

struct MediaImportButton: View {
  let title: String
  var allowed: [UTType] = UTType.importableImages
  let onLoad: (URL) -> Void
  
  @State private var isPresented = false
  
  var body: some View {
    Button(title) { isPresented = true }
      .fileImporter(isPresented: $isPresented, allowedContentTypes: allowed) { result in
        if case .success(let url) = result { onLoad(url) }
      }
  }
}

struct ImageWell: View {
  var image: RawImage?
  var caption: String
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(.quaternary)
      
      if let nsImage = image?.nsImage {
        Image(nsImage: nsImage)
          .resizable()
          .interpolation(.none)
          .aspectRatio(contentMode: .fit)
          .padding(6)
      } else {
        VStack(spacing: 6) {
          Image(systemName: "photo")
            .font(.largeTitle)
          Text(caption)
            .font(.caption)
        }
        .foregroundStyle(.secondary)
      }
    }
    .frame(minWidth: 220, minHeight: 220)
    .overlay(alignment: .bottom) {
      if image != nil {
        Text(caption)
          .font(.caption)
          .padding(.horizontal, 8)
          .padding(.vertical, 3)
          .background(.thinMaterial, in: Capsule())
          .padding(8)
      }
    }
  }
}

  /// Anteprima audio con visualizzatore
struct AudioWell: View {
  var audio: RawAudio?
  var envelope: WaveformEnvelope?
  var caption: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      ZStack {
        RoundedRectangle(cornerRadius: 10)
          .fill(.quaternary)
        
        if let envelope, !envelope.isEmpty {
          WaveformView(envelope: envelope)
            .padding(10)
        } else {
          VStack(spacing: 6) {
            Image(systemName: "waveform")
              .font(.largeTitle)
            Text(caption)
              .font(.caption)
          }
          .foregroundStyle(.secondary)
        }
      }
      .frame(minWidth: 260, minHeight: 120)
      .overlay(alignment: .bottom) {
        if audio != nil {
          Text(caption)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.thinMaterial, in: Capsule())
            .padding(8)
        }
      }
      
      if let audio {
        Text(Self.describe(audio.samples))
          .font(.caption)
          .foregroundStyle(.secondary)
          .monospacedDigit()
      }
    }
  }
  
  private static func describe(_ buffer: AudioBuffer) -> String {
    let channels = buffer.channelCount == 1 ? "mono" : "\(buffer.channelCount) canali"
    let totalSeconds = Int(buffer.duration.rounded())
    let duration = String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    return "\(channels) · \(Int(buffer.sampleRate)) Hz · 16 bit · \(duration)"
  }
}

  /// grazie StackOverflow
struct WaveformView: View {
  var envelope: WaveformEnvelope
  var color: Color = .accentColor
  
  var body: some View {
    Canvas { context, size in
      let count = envelope.minimums.count
      guard count > 0, size.width > 0, size.height > 0 else { return }
      
      let middle = size.height / 2
      let amplitude = middle * 0.95
      let step = size.width / CGFloat(count)
      
      var axis = Path()
      axis.move(to: CGPoint(x: 0, y: middle))
      axis.addLine(to: CGPoint(x: size.width, y: middle))
      context.stroke(axis, with: .color(color.opacity(0.25)), lineWidth: 1)
      
      var path = Path()
      for index in 0..<count {
        let x = (CGFloat(index) + 0.5) * step
        let top = middle - CGFloat(envelope.maximums[index]) * amplitude
        let bottom = middle - CGFloat(envelope.minimums[index]) * amplitude
        path.move(to: CGPoint(x: x, y: top))
        path.addLine(to: CGPoint(x: x, y: max(bottom, top + 0.5)))
      }
      context.stroke(path, with: .color(color), lineWidth: max(step * 0.8, 0.5))
    }
  }
}

struct MetricTile: View {
  var title: String
  var value: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.title3.monospacedDigit())
        .textSelection(.enabled)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(10)
    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
  }
}

struct FeatureRow: View {
  var label: String
  var value: Double
  
  var body: some View {
    LabeledContent(label) {
      Text(String(format: "%.4f", value))
        .monospacedDigit()
        .textSelection(.enabled)
    }
  }
}

  // Salva file
enum FilePanels {
  static func savePNG(suggestedName: String) -> URL? {
    save(suggestedName: suggestedName, type: .png)
  }
  
  static func saveWAV(suggestedName: String) -> URL? {
    save(suggestedName: suggestedName, type: .wav)
  }
  
  static func chooseFolder(prompt: String) -> URL? {
    let panel = NSOpenPanel()
    panel.canChooseFiles = false
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = false
    panel.prompt = prompt
    return panel.runModal() == .OK ? panel.url : nil
  }
  
  private static func save(suggestedName: String, type: UTType) -> URL? {
    let panel = NSSavePanel()
    panel.allowedContentTypes = [type]
    panel.nameFieldStringValue = suggestedName
    panel.canCreateDirectories = true
    return panel.runModal() == .OK ? panel.url : nil
  }
}
