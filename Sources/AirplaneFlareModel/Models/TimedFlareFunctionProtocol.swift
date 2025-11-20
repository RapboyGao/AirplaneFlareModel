import Foundation

public protocol TimedFlareFunctionProtocol: Codable, Sendable, Hashable {
    // MARK: - Given Conditions

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

    init(y0: Double, y1: Double, x1: Double, h1: Double)
}
