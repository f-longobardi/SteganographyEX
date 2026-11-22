import Foundation

  /// BER 
struct BERCalculator {
  
  func ber(reference: Data, recovered: Data) -> Double? {
    guard !reference.isEmpty,
          reference.count == recovered.count
            else {
      return nil
    }
    
    var errorBits = 0
    
    for i in 0..<reference.count {
      let referenceIndex = reference.index(reference.startIndex, offsetBy: i)
      let recoveredIndex = recovered.index(recovered.startIndex, offsetBy: i)
      
        //xor
      errorBits += (reference[referenceIndex] ^ recovered[recoveredIndex])
        .nonzeroBitCount
    }
    
    return Double(errorBits) / (Double(reference.count) * 8.0)
  }
  
  func ber(reference: Payload, recovered: Payload) -> Double? {
    ber(reference: Data(reference.utf8), recovered: Data(recovered.utf8))
  }
}
