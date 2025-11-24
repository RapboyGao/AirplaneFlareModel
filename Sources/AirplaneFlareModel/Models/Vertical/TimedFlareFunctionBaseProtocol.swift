import Foundation

public protocol TimedFlareFunctionBaseProtocol: Codable, Sendable, Hashable {
  /// y(0)
  /// 可带入初始升降率(例如-800)
  var y0: Double { get set }

  /// y(x1)
  /// 可带入结束升降率(例如-150)
  var y1: Double { get set }

  /// ∫0→x1 y(x) dx
  /// 可带入总消失高度(-50)
  var h1: Double { get set }

  /// upper bound x1 (> 0)
  /// 可带入总时间(分钟数)
  var x1: Double { get set }

  var minX1: Double { get }

  /// x1可能的最大值
  var maxX1: Double { get }

  init(y0: Double, y1: Double, x1: Double, h1: Double)

  /// ∫0→x y(x) dx
  /// 可带入时间(分钟数)
  func integral(atX x: Double) -> Double

  /// y(x)
  /// 可带入时间(分钟数)
  func y(atX x: Double) -> Double
}

extension TimedFlareFunctionBaseProtocol {
  public var minX1: Double {
    2 * h1 / (y0 + y1)
  }

  public var maxX1: Double {
    2 * h1 / y1
  }
}
