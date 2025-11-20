import Foundation

public struct PiecewiseLinearPlateauFunction: TimedFlareFunctionProtocol {

    // MARK: - Inputs
    public var y0: Double
    public var y1: Double
    public var x1: Double
    public var h1: Double

    public init(y0: Double, y1: Double, x1: Double, h1: Double) {
        self.y0 = y0
        self.y1 = y1
        self.x1 = x1
        self.h1 = h1
    }

    // MARK: - Derived values

    var den: Double { y0 - y1 }
    var num: Double { 2.0 * (h1 - y1 * x1) }

    /// a = 2(h1 – y1 x1) / (y0 – y1)
    var a: Double {
        if den == 0 { return .nan }
        let aa = num / den
        if aa <= 0 || aa > x1 { return .nan }
        return aa
    }

    /// b = y0
    var b: Double { y0 }

    /// k = (y1 - y0)/a
    var k: Double {
        let aa = a
        if aa.isNaN { return .nan }
        return (y1 - y0) / aa
    }

    // MARK: - y(x)
    func y(at x: Double) -> Double {
        guard !a.isNaN else { return .nan }
        return x <= a ? (k * x + y0) : y1
    }

    // MARK: - Integral H(x)
    func integral(at x: Double) -> Double {
        guard !a.isNaN else { return .nan }
        if x <= a {
            return 0.5 * k * x * x + y0 * x
        } else {
            let Ha = 0.5 * k * a * a + y0 * a
            return Ha + y1 * (x - a)
        }
    }

    // MARK: - Solve H(x) = targetH (analytic)
    ///
    /// 梯形 + 矩形 图形 → 直接解析求解
    ///
    func solveX(fromIntegral targetH: Double) -> Double {

        guard !a.isNaN else { return .nan }

        // 1. 计算 H(a)
        let Ha = 0.5 * k * a * a + y0 * a

        // 若 targetH < H(a) → 落在梯形区域 → 解二次方程
        if targetH <= Ha {

            // H(x) = (k/2)x² + y0 x = targetH
            // (k/2)x² + y0 x - targetH = 0
            let A = 0.5 * k
            let B = y0
            let C = -targetH

            let disc = B * B - 4 * A * C
            if disc < 0 { return .nan }

            let sqrtDisc = sqrt(disc)
            let x1 = (-B + sqrtDisc) / (2 * A)
            let x2 = (-B - sqrtDisc) / (2 * A)

            // 解必须在 0 ≤ x ≤ a
            let candidates = [x1, x2].filter { $0 >= 0 && $0 <= a }

            return candidates.first ?? .nan
        }

        // 2. 若 targetH ≥ Ha → 落在矩形区域 → 解一次方程
        //
        //   H(x) = Ha + y1(x - a) = targetH
        // → y1(x - a) = targetH - Ha
        // → x = a + (targetH - Ha)/y1
        //
        let x = a + (targetH - Ha) / y1
        return x >= a ? x : .nan
    }
}
