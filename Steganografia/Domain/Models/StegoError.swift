import Foundation

enum StegError: LocalizedError {
  case unreadableImage(String)
  case unreadableAudio(String)
  case insufficientCapacity(available: Int, required: Int)
  case noPayloadFound
  case encodingFailed
  case datasetDownloadFailed
  case stringEncodingFailed
  
  var errorDescription: String? {
    switch self {
    case .unreadableImage(let name):
      "Impossibile leggere l'immagine «\(name)»."
    case .unreadableAudio(let name):
      "Impossibile leggere l'audio «\(name)». Serve un formato decodificabile (WAV, AIFF, M4A, MP3)."
    case .insufficientCapacity(let available, let required):
      "Capienza insufficiente: servono \(required) byte, disponibili \(available)."
    case .noPayloadFound:
      "Nessun messaggio nascosto trovato nel file."
    case .encodingFailed:
      "Esportazione del file non riuscita."
    case .datasetDownloadFailed:
      "Download o estrazione del dataset non riusciti."
    case .stringEncodingFailed:
      "Impossibile estrarre una stringa utf8 dai Dati presenti nell'immagine"
    }
  }
}
