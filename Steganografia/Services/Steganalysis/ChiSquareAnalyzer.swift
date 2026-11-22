import Foundation

struct ChiSquareResult {
  var statistic: Double
  var degreesOfFreedom: Int
  var pValue: Double
  var perChannel: [Double]
  
  var probabilityText: String { String(format: "%.3f", pValue) }
}

struct ChiSquareAnalyzer {

    /// Analizza solo il canale blu, l'unico che LSBEncoder modifica, per non schiacciare i valori a 0
  func analyze(_ buffer: PixelBuffer) -> ChiSquareResult {
    var histogram = [Int](repeating: 0, count: 256)
    for pixel in 0..<buffer.pixelCount {
      histogram[Int(buffer.channel(2, at: pixel))] += 1
    }
    
    let (chi, df) = Self.evaluate(histogram)
    let pValue = 1 - GammaMath.regularizedP(Double(df) / 2, chi / 2)
    
    return ChiSquareResult(
      statistic: chi,
      degreesOfFreedom: df,
      pValue: pValue.clampedToUnit,
      perChannel: [chi]
    )
  }


    // su tutti i canali, versione rpecedente
    //
    // func analyze(_ buffer: PixelBuffer) -> ChiSquareResult {
    //     var counts = [[Int]](repeating: [Int](repeating: 0, count: 256), count: 3)
    //     for pixel in 0..<buffer.pixelCount {
    //         for channel in 0..<3 {
    //             counts[channel][Int(buffer.channel(channel, at: pixel))] += 1
    //         }
    //     }
    //
    //     var statistics = [Double](repeating: 0, count: 3)
    //     var freedoms = [Int](repeating: 0, count: 3)
    //
    //     for channel in 0..<3 {
    //         let (chi, df) = Self.evaluate(counts[channel])
    //         statistics[channel] = chi
    //         freedoms[channel] = df
    //     }
    //
    //     let totalStatistic = statistics.reduce(0, +)
    //     let totalFreedom = max(freedoms.reduce(0, +), 0)
    //     let pValue: Double
    //     if totalFreedom > 0 {
    //         pValue = 1 - GammaMath.regularizedP(Double(totalFreedom) / 2, totalStatistic / 2)
    //     } else {
    //         pValue = 0
    //     }
    //
    //     return ChiSquareResult(
    //         statistic: totalStatistic,
    //         degreesOfFreedom: totalFreedom,
    //         pValue: pValue.clampedToUnit,
    //         perChannel: statistics
    //     )
    // }

  private static func evaluate(_ histogram: [Int]) -> (statistic: Double, freedom: Int) {
    var chi = 0.0
    var freedom = 0
    
    for pair in stride(from: 0, to: 256, by: 2) {
      let even = Double(histogram[pair])
      let odd = Double(histogram[pair + 1])
      let expected = (even + odd) / 2
      guard expected > 0 else { continue }
      chi += pow(even - expected, 2) / expected
      chi += pow(odd - expected, 2) / expected
      freedom += 1
    }
    
    return (chi, max(freedom - 1, 1))
  }
}

extension Double {
  var clampedToUnit: Double { min(max(self, 0), 1) }
}

enum GammaMath {
  
  static func regularizedP(_ a: Double, _ x: Double) -> Double {
    guard a > 0, x > 0 else { return 0 }
    if x < a + 1 {
      return series(a, x)
    }
    return 1 - continuedFraction(a, x)
  }
  
  private static func series(_ a: Double, _ x: Double) -> Double {
    let logScale = -x + a * log(x) - lgamma(a)
    var term = 1.0 / a
    var sum = term
    var ap = a
    for _ in 0..<500 {
      ap += 1
      term *= x / ap
      sum += term
      if abs(term) < abs(sum) * 1e-14 { break }
    }
    return sum * exp(logScale)
  }
  
  private static func continuedFraction(_ a: Double, _ x: Double) -> Double {
    let logScale = -x + a * log(x) - lgamma(a)
    let tiny = 1e-300
    var b = x + 1 - a
    var c = 1 / tiny
    var d = 1 / b
    var h = d
    for i in 1..<500 {
      let an = -Double(i) * (Double(i) - a)
      b += 2
      d = an * d + b
      if abs(d) < tiny { d = tiny }
      c = b + an / c
      if abs(c) < tiny { c = tiny }
      d = 1 / d
      let delta = d * c
      h *= delta
      if abs(delta - 1) < 1e-14 { break }
    }
    return exp(logScale) * h
  }
}
