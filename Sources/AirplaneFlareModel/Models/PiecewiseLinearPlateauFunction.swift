import Foundation

/// A piecewise linear function with plateau defined by:
///     y(x) = { k·x + y0   if x ≤ a
///            { y1         if x > a
///
/// where the function consists of a linear ramp followed by a horizontal plateau.
///
/// ------------------------------------------------------------
/// # 1. **Given Conditions**
/// We are given:
/// - y0 = y(0)           (initial value)
/// - y1 = plateau value  (final constant value)
/// - h1 = ∫₀→x₁ y(x) dx  (total integral over domain)
/// - x1 > 0              (upper bound of domain)
///
/// with constraints:
/// - y0 ≠ y1             (for non-trivial solution)
/// - 0 < a < x1          (ramp must be within domain)
///
/// ------------------------------------------------------------
/// # 2. **Goal**
/// Solve for parameters:
/// - a (transition point from ramp to plateau)
/// - k (slope of the linear ramp)
///
/// And provide:
/// - y(x)
/// - ∫₀→x y(t) dt
/// - inverse x(h) (analytical solution)
///
/// ------------------------------------------------------------
/// # 3. **Derivation Summary**
///
/// ## (1) From the piecewise definition:
///     y(x) = k·x + y0  for x ≤ a
///     y(x) = y1        for x > a
///
/// At x = a, continuity requires:
///     k·a + y0 = y1
/// →   k = (y1 - y0)/a
///
/// ## (2) From the integral constraint:
///     ∫₀→x₁ y dx = h1
///
/// The integral consists of two parts:
/// - Ramp region (0 to a): ∫₀→a (k·x + y0) dx = (k/2)a² + y0·a
/// - Plateau region (a to x1): ∫ₐ→x₁ y1 dx = y1(x1 - a)
///
/// Total integral:
///     h1 = (k/2)a² + y0·a + y1(x1 - a)
///
/// ## (3) Solve for a:
/// Substitute k = (y1 - y0)/a:
///     h1 = (y1 - y0)a/2 + y0·a + y1(x1 - a)
///     h1 = a(y1 - y0 + 2y0)/2 + y1(x1 - a)
///     h1 = a(y1 + y0)/2 + y1·x1 - y1·a
///     h1 - y1·x1 = a(y0 - y1)/2
/// →   a = 2(h1 - y1·x1)/(y0 - y1)
///
/// ------------------------------------------------------------
/// # 4. **Inverse x from integral**
///
/// Given H(x) = ∫₀→x y(t) dt = targetH, solve for x:
///
/// Case 1: targetH ≤ H(a) (in ramp region)
///     H(x) = (k/2)x² + y0·x = targetH
/// →   (k/2)x² + y0·x - targetH = 0
/// Solve quadratic equation for x ∈ [0, a]
///
/// Case 2: targetH > H(a) (in plateau region)
///     H(x) = H(a) + y1(x - a) = targetH
/// →   x = a + (targetH - H(a))/y1
///
/// ------------------------------------------------------------
public struct PiecewiseLinearPlateauFunction: TimedFlareFunctionProtocol {

    // MARK: - Given Conditions

    /// y(0) = initial value at x = 0
    public var y0: Double

    /// Plateau value (constant value for x > a)
    public var y1: Double

    /// Upper bound of domain (x1 > 0)
    public var x1: Double

    /// Total integral ∫₀→x₁ y(x) dx
    public var h1: Double

    public init(y0: Double, y1: Double, x1: Double, h1: Double) {
        self.y0 = y0
        self.y1 = y1
        self.x1 = x1
        self.h1 = h1
    }

    // MARK: - Intermediate Quantities

    /// Denominator for a calculation: y0 - y1
    /// Must be non-zero for valid solution
    var den: Double { y0 - y1 }

    /// Numerator for a calculation: 2(h1 - y1·x1)
    var num: Double { 2.0 * (h1 - y1 * x1) }

    /// Transition point from ramp to plateau
    /// a = 2(h1 - y1·x1) / (y0 - y1)
    ///
    /// Constraints:
    /// - 0 < a < x1 (must be within domain)
    /// - den ≠ 0 (y0 ≠ y1)
    var a: Double {
        if den == 0 { return .nan }
        let aa = num / den
        if aa <= 0 || aa > x1 { return .nan }
        return aa
    }

    /// Initial value (same as y0)
    /// Kept for consistency with other function models
    var b: Double { y0 }

    /// Slope of the linear ramp
    /// k = (y1 - y0)/a
    /// Derived from continuity condition at x = a
    var k: Double {
        let aa = a
        if aa.isNaN { return .nan }
        return (y1 - y0) / aa
    }

    // MARK: - y(x)

    /// Computes y(x) = { k·x + y0   if x ≤ a
    ///                   { y1         if x > a
    public func y(at x: Double) -> Double {
        guard !a.isNaN else { return .nan }
        return x <= a ? (k * x + y0) : y1
    }

    // MARK: - Integral H(x)

    /// Computes ∫₀→x y(t) dt
    ///
    /// For x ≤ a: ∫₀→x (k·t + y0) dt = (k/2)x² + y0·x
    /// For x > a: ∫₀→x y(t) dt = ∫₀→a (k·t + y0) dt + ∫ₐ→x y1 dt
    ///                           = (k/2)a² + y0·a + y1(x - a)
    public func integral(at x: Double) -> Double {
        guard !a.isNaN else { return .nan }
        if x <= a {
            return 0.5 * k * x * x + y0 * x
        } else {
            let Ha = 0.5 * k * a * a + y0 * a
            return Ha + y1 * (x - a)
        }
    }

    // MARK: - Inverse x from integral

    /// Solve x from H(x) = ∫₀→x y(t) dt = targetH
    ///
    /// Uses analytical solution based on piecewise nature:
    /// - Case 1: targetH ≤ H(a) → solve quadratic in ramp region
    /// - Case 2: targetH > H(a) → solve linear in plateau region
    ///
    /// Trapezoid + rectangle geometry → direct analytical solution
    public func solveX(fromIntegral targetH: Double) -> Double {

        guard !a.isNaN else { return .nan }

        // Calculate H(a) = integral at transition point
        let Ha = 0.5 * k * a * a + y0 * a

        // Case 1: targetH ≤ H(a) → in ramp region (trapezoid)
        if targetH <= Ha {

            // Solve: H(x) = (k/2)x² + y0·x = targetH
            // Quadratic: (k/2)x² + y0·x - targetH = 0
            let A = 0.5 * k
            let B = y0
            let C = -targetH

            let discriminant = B * B - 4 * A * C
            if discriminant < 0 { return .nan }

            let sqrtDisc = sqrt(discriminant)
            let root1 = (-B + sqrtDisc) / (2 * A)
            let root2 = (-B - sqrtDisc) / (2 * A)

            // Solution must be in range [0, a]
            let validSolutions = [root1, root2].filter { $0 >= 0 && $0 <= a }

            return validSolutions.first ?? .nan
        }

        // Case 2: targetH > H(a) → in plateau region (rectangle)
        //
        // H(x) = H(a) + y1(x - a) = targetH
        // → y1(x - a) = targetH - H(a)
        // → x = a + (targetH - H(a))/y1
        //
        let x = a + (targetH - Ha) / y1
        return x >= a ? x : .nan
    }
}
