import Foundation

// MARK: - Helper: Numerical Solver
extension Double {
  /// 简单的牛顿迭代法求解器
  /// 求解方程 f(x) = targetValue
  static func solveNewton(
    target: Double,
    initialGuess: Double = 1.0,
    maxIter: Int = 20,
    tolerance: Double = 1e-7,
    f: (Double) -> Double,
    df: (Double) -> Double
  ) -> Double {
    var x = initialGuess
    for _ in 0..<maxIter {
      let y = f(x)
      let dy = df(x)
      if abs(dy) < 1e-9 { break }  // 导数过小，防止除零
      let delta = (y - target) / dy
      x -= delta
      if abs(delta) < tolerance { return x }
    }
    return x
  }
}
