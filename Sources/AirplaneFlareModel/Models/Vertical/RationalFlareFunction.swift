import Foundation

// MARK: - 2. Rational Hyperbola (反比例偏移函数)
/// 公式: y(x) = c - a / (x + b)
/// 特性: 变化率随时间迅速衰减，较“硬”的拉平曲线
public struct RationalFlareFunction: TimedFlareFunctionBaseProtocol {
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

    let K = (h1 - y0 * x1) / (y1 - y0)

    // 方程: K = (x1 + b) * [ 1 - (b/x1) * ln(1 + x1/b) ]
    self.b = Double.solveNewton(
      target: K, initialGuess: x1,
      f: { bVal in
        let ratio = x1 / bVal
        return (x1 + bVal) * (1.0 - (1.0 / ratio) * log(1.0 + ratio))
      },
      df: { bVal in
        // 这里的导数较为复杂，使用数值微分代替解析微分以简化代码
        let delta = 1e-6
        let x = bVal
        let f_x = (x1 + x) * (1.0 - (x / x1) * log(1.0 + x1 / x))
        let x_d = x + delta
        let f_xd = (x1 + x_d) * (1.0 - (x_d / x1) * log(1.0 + x1 / x_d))
        return (f_xd - f_x) / delta
      })

    if !self.b.isNaN {
      self.a = (y1 - y0) * self.b * (x1 + self.b) / x1
      self.c = y0 + self.a / self.b
    }
  }

  public func y(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    return c - a / (x + b)
  }

  public func integral(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    return c * x - a * (log(x + b) - log(b))
  }
}
