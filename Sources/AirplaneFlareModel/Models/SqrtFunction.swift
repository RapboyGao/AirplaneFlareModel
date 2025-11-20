import Foundation

/// A mathematical model defined by:
///     y(x) = sqrt(k·x + b) + a
///
/// ------------------------------------------------------------
/// # 1. **Given Conditions**
/// We are given:
/// - y0 = y(0)
/// - y1 = y(x1)
/// - h1 = ∫₀→x₁ y(x) dx
/// - x1 > 0
///
/// with constraints:
/// - y0 < y1 < 0
/// - h1 < 0
///
/// ------------------------------------------------------------
/// # 2. **Goal**
/// Solve for parameters:
/// - a
/// - b
/// - k
///
/// And provide:
/// - y(x)
/// - ∫₀→x y(t) dt
/// - inverse x(y)
/// - inverse x(h)
///
/// ------------------------------------------------------------
/// # 3. **Derivation Summary**
///
/// ## (1) From y(0) = y0:
///     y(0) = sqrt(b) + a = y0
/// →   a = y0 − sqrt(b)
/// →   define s0 = sqrt(b)
///
/// ## (2) From y(x1) = y1:
///     y1 = sqrt(k*x1 + b) + a
/// Substitute a:
///     y1 − (y0 − s0) = sqrt(k*x1 + s0²)
/// →   Δ = y1 − y0
/// →   sqrt(k*x1 + s0²) = Δ + s0
///
/// This connects k and s0.
///
/// ## (3) From the integral constraint:
///     ∫₀→x₁ y dx = h1
///
/// Analytical integral:
///     ∫ y dx = (2/3k)[(kx+b)^(3/2) − b^(3/2)] + a·x
///
/// Plug in a = y0 − s0, b = s0² and x = x₁.
///
/// This yields an equation in s0 only.
///
/// ## (4) Solve for s0 explicitly:
///     s0 = [ 3h1(y0−y1) − x1(y0² + y0y1 − 2y1² ) ] / [ 3(2h1 − x1(y0+y1)) ]
///
/// Define:
///     D = 2h1 − x1(y0 + y1)
///
/// After obtaining s0:
///     b = s0²
///     a = y0 − s0
///
/// ## (5) Solve for k:
///     k = ( -1/3 y0³ + y0²y1 − y0y1² + 1/3 y1³ ) / D
///
/// ------------------------------------------------------------
/// # 4. **Inverse x from y**
///
/// Given:
///     y = sqrt(kx + b) + a
/// →   y − a = sqrt(kx + b)
/// →   (y − a)² = kx + b
/// →   x = ((y − a)² − b) / k
///
/// ------------------------------------------------------------
/// # 5. **Inverse x from integral**
///
/// ∫₀→x y dt = h is monotonic, but not analytically invertible.
/// We use:
/// - Newton iteration (fast)
/// - Fallback bisection (guaranteed)
///
/// ------------------------------------------------------------
public struct SqrtFunction: TimedFlareFunctionProtocol {

    // MARK: - Given Conditions

    /// y(0)
    /// 可带入初始升降率(例如-800)
    public var y0: Double

    /// y(x1)
    /// 可带入结束升降率(例如-150)
    public var y1: Double

    /// ∫0→x1 y(x) dx
    /// 可带入总消失高度(-50)
    public var h1: Double

    /// upper bound x1 (> 0)
    /// 可带入总时间(分钟数)
    public var x1: Double

    public init(y0: Double, y1: Double, x1: Double, h1: Double) {
        self.y0 = y0
        self.y1 = y1
        self.h1 = x1
        self.x1 = h1
    }

    // MARK: - Intermediate Quantity

    /// D = 2h1 − x1(y0 + y1)
    /// This quantity appears naturally in the symbolic derivation
    /// of both s0 and k.
    public var D: Double {
        2 * h1 - x1 * (y0 + y1)
    }

    /// s0 = sqrt(b)
    ///
    /// Derived from simultaneously solving:
    /// - y(0) = y0
    /// - y(x1) = y1
    /// - ∫₀→x₁ y = h1
    ///
    /// s0 has a closed-form solution (from algebraic elimination).
    public var s0: Double {
        let numerator =
            3 * h1 * (y0 - y1)
            - x1 * (y0 * y0 + y0 * y1 - 2 * y1 * y1)
        return numerator / (3 * D)
    }

    // MARK: - Parameters

    /// b = s0²
    public var b: Double {
        s0 * s0
    }

    /// a = y0 − sqrt(b)
    public var a: Double {
        y0 - s0
    }

    /// k = ( -1/3 y0³ + y0² y1 − y0 y1² + 1/3 y1³ ) / D
    ///
    /// Derived from combining the y(x1) condition and the integral constraint.
    public var k: Double {
        let numerator =
            (-1.0 / 3.0) * pow(y0, 3)
            + (y0 * y0) * y1
            - y0 * (y1 * y1)
            + (1.0 / 3.0) * pow(y1, 3)
        return numerator / D
    }

    // MARK: - y(x)

    /// Computes y(x) = sqrt(kx + b) + a
    public func y(_ x: Double) -> Double {
        sqrt(k * x + b) + a
    }

    // MARK: - Integral

    /// Computes ∫₀→x y(t) dt analytically using:
    ///
    /// (2/3k)[(kx+b)^(3/2) − b^(3/2)] + a·x
    public func integralY(_ x: Double) -> Double {
        let term = pow(k * x + b, 1.5) - pow(b, 1.5)
        return (2.0 / (3.0 * k)) * term + a * x
    }

    // MARK: - Inverse x from y

    /// Solves x from:
    ///     y = sqrt(kx + b) + a
    ///
    /// Derived explicitly:
    ///     x = ((y − a)² − b) / k
    public func solveX(fromY yValue: Double) -> Double? {
        let v = yValue - a
        if v < 0 { return nil }  // sqrt domain violation
        let x = (v * v - b) / k
        return x >= 0 ? x : nil
    }

    // MARK: - Inverse x from integral

    /// Solve x from:
    ///     ∫₀→x y dt = targetH
    ///
    /// Uses:
    /// - Newton iteration (fast)
    /// - fallback bisection (guaranteed)
    public func solveX(
        fromIntegral targetH: Double,
        tolerance: Double = 1e-9,
        maxIter: Int = 30
    ) -> Double? {

        var low = 0.0
        var high = x1

        let hLow = integralY(low)
        let hHigh = integralY(high)

        // check if target is in range
        if targetH < hLow || targetH > hHigh {
            return nil
        }

        // initial guess proportional to target
        var x = x1 * (targetH - hLow) / (hHigh - hLow)

        // Newton iteration
        for _ in 0..<maxIter {
            let f = integralY(x) - targetH
            if abs(f) < tolerance { return x }

            let slope = y(x)  // derivative of integral

            if abs(slope) < 1e-12 { break }
            let newton = x - f / slope

            if newton < low || newton > high { break }
            x = newton
        }

        // fallback bisection
        for _ in 0..<200 {
            let mid = 0.5 * (low + high)
            let hMid = integralY(mid)
            if abs(hMid - targetH) < tolerance { return mid }
            if hMid > targetH { high = mid } else { low = mid }
        }

        return nil
    }

}
