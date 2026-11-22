import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
  case embed
  case extract
  case analysis
  case detection
  case dataset
  //case experiments
  
  var id: String { rawValue }
  
  var title: String {
    switch self {
    case .embed: "Embed Message"
    case .extract: "Extract Message"
    case .analysis: "Quality Analysis"
    case .detection: "Steganalysis"
    case .dataset: "Dataset"
    //case .experiments: "Experiments"
    }
  }
  
  var systemImage: String {
    switch self {
    case .embed: "eye.slash"
    case .extract: "eye"
    case .analysis: "chart.bar.xaxis"
    case .detection: "magnifyingglass"
    case .dataset: "folder"
    //case .experiments: "flask"
    }
  }
  
  var subtitle: String {
    switch self {
    case .embed: "Occulta un messaggio in un'immagine"
    case .extract: "Recupera un messaggio nascosto"
    case .analysis: "PSNR, SSIM e BER fra originale e steganografata"
    case .detection: "Classifica l'immagine come CLEAN o ALTERED"
    case .dataset: "Scarica un dataset reale e analizza PSNR/SSIM/BER"
    //case .experiments: "Capacità vs qualità, Uniform vs Edge Aware"
    }
  }
}

struct HomeView: View {
  @State private var selection: AppSection? = .embed
  
  var body: some View {
    NavigationSplitView {
      List(AppSection.allCases, selection: $selection) { section in
        Label(section.title, systemImage: section.systemImage)
          .tag(section)
      }
      .navigationTitle("SteganografiaLab")
      .frame(minWidth: 200)
    } detail: {
      detail
        .navigationTitle(selection?.title ?? "SteganografiaLab")
        .navigationSubtitle(selection?.subtitle ?? "")
        .frame(minWidth: 720, minHeight: 480)
    }
  }
  
  @ViewBuilder
  private var detail: some View {
    switch selection {
    case .embed:
      EmbedView()
    case .extract:
      ExtractView()
    case .analysis:
      AnalysisView()
    case .detection:
      DetectionView()
    case .dataset:
      DatasetView()
    //case .experiments: ExperimentView()
    case nil:
      ContentUnavailableView("Seleziona una sezione", systemImage: "sidebar.left")
    }
  }
}

#Preview {
  HomeView()
}
