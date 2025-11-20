import Testing

@testable import AirplaneFlareModel

// MARK: - Test Parameters
/// Test parameters: y0 = -800, y1 = -150, x1 = 0.133, h1 = -50
/// These represent realistic airplane flare model parameters
let testY0: Double = -800
let testY1: Double = -150
let testX1: Double = 0.133
let testH1: Double = -50

// MARK: - PiecewiseLinearPlateauFunction Tests

@Test("PiecewiseLinearPlateauFunction - Parameter Calculation")
func testPiecewiseLinearPlateauParameters() async throws {
    let function = PiecewiseLinearPlateauFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    // Test that parameters are calculated correctly
    #expect(!function.a.isNaN, "Transition point 'a' should be valid")
    #expect(
        function.a > 0 && function.a < testX1,
        "Transition point 'a' should be within domain (0, x1)")
    #expect(!function.k.isNaN, "Slope 'k' should be valid")

    // Verify continuity at transition point: k·a + y0 = y1
    let continuityCheck = function.k * function.a + testY0
    #expect(
        abs(continuityCheck - testY1) < 1e-10,
        "Continuity condition violated at transition point")
}

@Test("PiecewiseLinearPlateauFunction - Function Values")
func testPiecewiseLinearPlateauFunctionValues() async throws {
    let function = PiecewiseLinearPlateauFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    let a = function.a

    // Test ramp region (x ≤ a)
    let yAt0 = function.y(at: 0.0)
    #expect(abs(yAt0 - testY0) < 1e-10, "y(0) should equal y0")

    let yAtA = function.y(at: a)
    #expect(abs(yAtA - testY1) < 1e-10, "y(a) should equal y1 (continuity)")

    // Test plateau region (x > a)
    let yAtX1 = function.y(at: testX1)
    #expect(
        abs(yAtX1 - testY1) < 1e-10, "y(x1) should equal y1 in plateau region")

    let yInPlateau = function.y(at: a + 0.01)
    #expect(
        abs(yInPlateau - testY1) < 1e-10,
        "Function should maintain plateau value")

}

@Test("PiecewiseLinearPlateauFunction - Integral Calculation")
func testPiecewiseLinearPlateauIntegral() async throws {
    let function = PiecewiseLinearPlateauFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    // Test integral at boundaries
    let integralAt0 = function.integral(at: 0.0)
    #expect(abs(integralAt0) < 1e-10, "Integral at x=0 should be 0")

    let integralAtX1 = function.integral(at: testX1)
    #expect(
        abs(integralAtX1 - testH1) < 1e-8, "Integral at x=x1 should equal h1")

    // Test integral at transition point
    let integralAtA = function.integral(at: function.a)
    #expect(!integralAtA.isNaN, "Integral at transition point should be valid")
    #expect(
        integralAtA < 0, "Integral should be negative (descending function)")
}

// MARK: - SqrtFunction Tests

@Test("SqrtFunction - Parameter Calculation")
func testSqrtFunctionParameters() async throws {
    let function = SqrtFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    // Test that parameters are calculated correctly
    #expect(!function.a.isNaN, "Parameter 'a' should be valid")
    #expect(!function.b.isNaN, "Parameter 'b' should be valid")
    #expect(!function.k.isNaN, "Parameter 'k' should be valid")
    #expect(
        function.b >= 0,
        "Parameter 'b' should be non-negative for sqrt function")

    // Verify constraints: y0 < y1 < 0 and h1 < 0
    #expect(testY0 < testY1, "Constraint y0 < y1 should be satisfied")
    #expect(testY1 < 0, "Constraint y1 < 0 should be satisfied")
    #expect(testH1 < 0, "Constraint h1 < 0 should be satisfied")
}

@Test("SqrtFunction - Function Values")
func testSqrtFunctionValues() async throws {
    let function = SqrtFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    // Test function at boundaries
    let yAt0 = function.y(0.0)
    #expect(abs(yAt0 - testY0) < 1e-10, "y(0) should equal y0")

    let yAtX1 = function.y(testX1)
    #expect(abs(yAtX1 - testY1) < 1e-8, "y(x1) should equal y1")

    // Test function monotonicity (should be increasing since it's less negative)
    let yMid = function.y(testX1 / 2.0)
    #expect(
        yAt0 < yMid && yMid < yAtX1,
        "Function should be monotonically increasing (less negative)")
}

@Test("SqrtFunction - Integral Calculation")
func testSqrtFunctionIntegral() async throws {
    let function = SqrtFunction(
        y0: testY0,
        y1: testY1,
        x1: testX1,
        h1: testH1
    )

    // Test integral monotonicity (should be decreasing since function is negative)
    let integralAt0 = function.integralY(0.0)
    #expect(abs(integralAt0) < 1e-10, "Integral at x=0 should be 0")

    let integralAtX1 = function.integralY(testX1)
    #expect(
        abs(integralAtX1 - testH1) < 1e-8, "Integral at x=x1 should equal h1")

    let integralMid = function.integralY(testX1 / 2.0)
    #expect(
        integralAt0 > integralMid && integralMid > integralAtX1,
        "Integral should be monotonically decreasing (function is negative)")
}

// MARK: - Edge Case Tests

@Test("Edge Cases - Invalid Parameters")
func testInvalidParameters() async throws {
    // Test with y0 = y1 (should fail for PiecewiseLinearPlateauFunction)
    let invalidPiecewise = PiecewiseLinearPlateauFunction(
        y0: -500,
        y1: -500,
        x1: 0.1,
        h1: -20
    )
    #expect(invalidPiecewise.a.isNaN, "Should fail when y0 = y1")

    // Test with invalid h1 (positive value for descending function)
    let invalidH1 = PiecewiseLinearPlateauFunction(
        y0: -800,
        y1: -150,
        x1: 0.133,
        h1: 50  // Positive h1 is invalid for descending function
    )
    #expect(
        invalidH1.a.isNaN || invalidH1.a <= 0 || invalidH1.a > 0.133,
        "Should fail with invalid h1")
}
