import Foundation

// MARK: - 3. Inverse Square Root (逆平方根函数)
/// 公式: y(x) = c - a / sqrt(x + b)
/// 特性: 介于反比例和指数之间
public struct InverseSqrtFlareFunction: TimedFlareFunctionBaseProtocol {
  public var y0, y1, h1, x1: Double
  public var a: Double = .nan
  public var b: Double = .nan
  public var c: Double = .nan

  public var minX1: Double { return (2 * h1) / (y0 + y1) }
  public var maxX1: Double { return h1 / y1 }

  public init(y0: Double, y1: Double, x1: Double, h1: Double) {
    self.y0 = y0
    self.y1 = y1
    self.x1 = x1
    self.h1 = h1
    guard x1 > 0, y1 > y0, y1 < 0, x1 >= minX1, x1 <= maxX1 else { return }

    // 方程推导极其复杂，同样使用数值求解
    let K = (h1 - y0 * x1) / (y1 - y0)

    self.b = Double.solveNewton(
      target: 0, initialGuess: x1,
      f: { bVal in
        // K_calc = numerator / denominator - K_target
        let sqrtB = sqrt(bVal)
        let sqrtXB = sqrt(x1 + bVal)

        let num = (x1 / sqrtB) - 2.0 * (sqrtXB - sqrtB)
        let den = (1.0 / sqrtB) - (1.0 / sqrtXB)
        return (num / den) - K
      },
      df: { bVal in
        // 数值微分
        let d = 1e-5
        let f1 = { (v: Double) -> Double in
          let sB = sqrt(v)
          let sXB = sqrt(x1 + v)
          return ((x1 / sB) - 2 * (sXB - sB)) / ((1 / sB) - (1 / sXB))
        }
        return (f1(bVal + d) - f1(bVal)) / d
      })

    if !self.b.isNaN {
      let term1 = 1.0 / sqrt(self.b)
      let term2 = 1.0 / sqrt(x1 + self.b)
      self.a = (y1 - y0) / (term1 - term2)
      self.c = y0 + self.a * term1
    }
  }

  public func y(atX x: Double) -> Double {
    return c - a / sqrt(x + b)
  }

  public func integral(atX x: Double) -> Double {
    // int(c - a(x+b)^-0.5) = cx - 2a(sqrt(x+b) - sqrt(b))
    return c * x - 2 * a * (sqrt(x + b) - sqrt(b))
  }
}
