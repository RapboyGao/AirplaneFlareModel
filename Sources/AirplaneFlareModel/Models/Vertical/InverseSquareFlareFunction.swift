import Foundation

// MARK: - 4. Inverse Square (逆平方函数)
/// 逆平方函数: y(x) = c - a / (x + b)^2
/// 唯一具有完美解析解的“倒数类”模型，无需牛顿迭代
public struct InverseSquareFlareFunction: TimedFlareFunctionBaseProtocol {
  public var y0, y1, h1, x1: Double

  // 内部参数
  private var a: Double = .nan
  private var b: Double = .nan
  private var c: Double = .nan

  // 几何约束
  public var minX1: Double { return (2 * h1) / (y0 + y1) }
  public var maxX1: Double { return h1 / y1 }

  public init(y0: Double, y1: Double, x1: Double, h1: Double) {
    self.y0 = y0
    self.y1 = y1
    self.x1 = x1
    self.h1 = h1

    // 1. 安全检查: 必须符合上凸函数的几何面积限制
    guard x1 > 0, y1 > y0, y1 < 0, x1 >= minX1, x1 <= maxX1 else {
      // 参数保持 NaN，表示无解
      return
    }

    // 2. 解析解推导
    // K 代表“平均变化量”相对于“总变化量”的一个几何比率因子
    let numeratorK = h1 - y0 * x1
    let denominatorK = y1 - y0
    if abs(denominatorK) < 1e-9 { return }  // 防止除零

    let K = numeratorK / denominatorK

    // 核心公式: 直接算出 b
    // 推导来源: 联立积分方程和两点方程消元得到
    let bNumerator = x1 * (x1 - K)
    let bDenominator = 2 * K - x1

    if abs(bDenominator) < 1e-9 { return }
    let calculatedB = bNumerator / bDenominator

    // b 必须为正数，否则函数在 x>0 处会有奇点
    if calculatedB > 0 {
      self.b = calculatedB

      // 算出 b 后，a 和 c 就很简单了
      let term1 = 1.0 / (calculatedB * calculatedB)
      let term2 = 1.0 / ((x1 + calculatedB) * (x1 + calculatedB))

      self.a = (y1 - y0) / (term1 - term2)
      self.c = y0 + self.a * term1
    }
  }

  public func y(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    let denom = x + b
    return c - a / (denom * denom)
  }

  public func integral(atX x: Double) -> Double {
    if a.isNaN { return Double.nan }
    // 积分公式: cx + a(1/(x+b) - 1/b)
    return c * x + a * (1.0 / (x + b) - 1.0 / b)
  }
}
