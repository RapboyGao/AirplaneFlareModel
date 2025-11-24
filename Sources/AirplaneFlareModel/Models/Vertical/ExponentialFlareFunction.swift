import Foundation

// MARK: - 1. Shifted Exponential (负指数偏移函数)
/// 公式: y(x) = c - a * exp(-b * x)
/// 特性: 最经典的饱和增长模型，无限逼近 asymptote
public struct ExponentialFlareFunction: TimedFlareFunctionBaseProtocol {
  public var y0, y1, h1, x1: Double
  // 内部参数
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

    // 基础校验
    guard x1 > 0, y1 > y0, y1 < 0, x1 >= minX1, x1 <= maxX1 else { return }

    // 求解常数 K，用于构建关于 b 的方程
    // 推导: h1 - y0*x1 = (y1 - y0) * [ x1 / (1 - e^(-b*x1)) - 1/b ]
    let K = (h1 - y0 * x1) / (y1 - y0)

    // 使用牛顿法求 b
    self.b = Double.solveNewton(
      target: K, initialGuess: 1.0 / x1,
      f: { bVal in
        let E = exp(-bVal * x1)
        return (x1 / (1.0 - E)) - (1.0 / bVal)
      },
      df: { bVal in
        let E = exp(-bVal * x1)
        let denom = (1.0 - E) * (1.0 - E)
        let term1 = -(x1 * x1 * E) / denom
        let term2 = 1.0 / (bVal * bVal)
        return term1 + term2
      })

    // 反求 a, c
    if !self.b.isNaN {
      self.a = (y1 - y0) / (1.0 - exp(-self.b * x1))
      self.c = y0 + self.a
    }
  }

  public func y(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    return c - a * exp(-b * x)
  }

  public func integral(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    return c * x + (a / b) * (exp(-b * x) - 1)
  }
}
