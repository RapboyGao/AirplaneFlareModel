import Accelerate
import Foundation

/// 表示线性函数 y = kx + b
///
/// - 内部使用 SIMD2<Double> 存储 [k, b]
/// - 所有初始化若条件非法 → k,b = NaN
/// - x(fromY:) 若 k = 0 → NaN
/// - fromIntegral 使用一元二次方程求解
///
/// 支持 4 种初始化：
///   1. init(k:b:)
///   2. init(point0:point1:)
///   3. init(b:x1:integralH:)
///   4. init(b:y1:integralH:)
///
public struct LinearFunction: Hashable, Codable, Sendable,
    CustomStringConvertible
{
    /// coeff[0] = k
    /// coeff[1] = b
    public var coeff: SIMD2<Double>

    public var k: Double { coeff[0] }
    public var b: Double { coeff[1] }

    public var description: String {
        "LinearFunction(k: \(k), b: \(b))"
    }

    // ============================================================
    // MARK: 1. Init — direct (k, b)
    // ============================================================

    public init(k: Double, b: Double) {
        self.coeff = SIMD2(k, b)
    }

    // ============================================================
    // MARK: 2. Init — from two points
    // ============================================================

    /// 两点 (x0,y0), (x1,y1)
    /// 若 x 坐标相同 → 非线性函数 → NaN
    public init(point0 p0: SIMD2<Double>, point1 p1: SIMD2<Double>) {
        let dx = p1.x - p0.x
        guard dx != 0 else {
            coeff = SIMD2(.nan, .nan)
            return
        }
        let k = (p1.y - p0.y) / dx
        let b = p0.y - k * p0.x

        coeff = SIMD2(k, b)
    }

    // ============================================================
    // MARK: 3. Init — known b, x1, integral
    // ============================================================

    /// 已知 b, x1, H = ∫0→x1 (kx + b) dx
    ///
    /// H = (k/2)x1² + b x1
    /// k = 2(H - b x1) / x1²
    public init(b: Double, x1: Double, integralH H: Double) {
        guard x1 != 0 else {
            coeff = SIMD2(.nan, .nan)
            return
        }

        let denom = x1 * x1
        guard denom != 0 else {
            coeff = SIMD2(.nan, .nan)
            return
        }

        let k = 2 * (H - b * x1) / denom
        coeff = SIMD2(k, b)
    }

    // ============================================================
    // MARK: 4. Init — known b, y1, integral
    // ============================================================

    /// 已知 b, y1, H = ∫0→x1 y dx
    ///
    /// k = (y1² - b²) / (2H)
    public init(b: Double, y1: Double, integralH H: Double) {

        guard H != 0 else {
            coeff = SIMD2(.nan, .nan)
            return
        }

        let numerator = y1 * y1 - b * b
        let denom = 2 * H

        let k = numerator / denom

        guard k.isFinite, k != 0 else {
            coeff = SIMD2(.nan, .nan)
            return
        }

        coeff = SIMD2(k, b)
    }

    // ============================================================
    // MARK: y(x)
    // ============================================================

    public func y(at x: Double) -> Double {
        k * x + b
    }

    // ============================================================
    // MARK: x(y)
    // ============================================================

    /// x = (y - b)/k
    /// 若 k = 0 → NaN
    @inline(__always)
    public func x(fromY y: Double) -> Double {
        if k == 0 || k.isNaN { return .nan }
        return (y - b) / k
    }

    // ============================================================
    // MARK: x from integral
    // ============================================================

    /// ∫ (kx + b) dx = H → (k/2)x² + b x - H = 0
    public func x(fromIntegral H: Double) -> Double {

        // 特殊情况：k = 0 → 积分 = b x
        if k == 0 {
            if b == 0 { return .nan }
            return H / b
        }

        let A = k / 2
        let B = b
        let C = -H

        // D = B² - 4AC
        let D = B * B - 4 * A * C
        if D < 0 { return .nan }

        let sqrtD = sqrt(D)
        let denom = 2 * A
        if denom == 0 { return .nan }

        let r1 = (-B + sqrtD) / denom
        let r2 = (-B - sqrtD) / denom

        // 返回正根优先
        if r1 >= 0 && r2 >= 0 { return max(r1, r2) }
        if r1 >= 0 { return r1 }
        if r2 >= 0 { return r2 }
        return max(r1, r2)
    }

    // ============================================================
    // MARK: (x,y) from integral
    // ============================================================

    public func xy(fromIntegral H: Double) -> SIMD2<Double> {
        let xVal = x(fromIntegral: H)
        if xVal.isNaN { return SIMD2(.nan, .nan) }
        return SIMD2(xVal, y(at: xVal))
    }
}
