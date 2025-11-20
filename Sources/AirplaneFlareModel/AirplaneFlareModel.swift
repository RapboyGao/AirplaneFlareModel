import Foundation

public struct AirplaneFlareModel: Codable, Sendable, Hashable {
  /// 初始水平速度(英尺/分钟)
  public var initialLateralSpeedInFeetPerMinute: Double
  ///  touchdown水平速度(英尺/分钟)
  public var touchDownLateralSpeedInFeetPerMinute: Double
  /// 初始垂直速度(英尺/分钟)
  public var initialVerticalSpeedInFeetPerMinute: Double
  /// touchdown垂直速度(英尺/分钟)
  public var touchDownVerticalSpeedInFeetPerMinute: Double
  /// 期望touchdown点(从flare开始)
  public var desiredTouchdownPointFromFlareInFeet: Double
  /// flare高度(英尺)
  public var heightOfFlareInFeet: Double

  /// 初始水平速度( knot )
  public var initialSpeedInKnots: Double {
    get { initialLateralSpeedInFeetPerMinute / 101.26855914 }
    set { initialLateralSpeedInFeetPerMinute = newValue * 101.26855914 }
  }

  /// touchdown水平速度( knot )
  public var touchDownSpeedInKnots: Double {
    get { touchDownLateralSpeedInFeetPerMinute / 101.26855914 }
    set { touchDownLateralSpeedInFeetPerMinute = newValue * 101.26855914 }
  }

  /// 初始飞行路径角度(度)
  public var initialFPAInDegrees: Double {
    get {
      atan(initialVerticalSpeedInFeetPerMinute / initialLateralSpeedInFeetPerMinute) * 180 / .pi
    }
    set {
      initialVerticalSpeedInFeetPerMinute =
        sin(newValue * .pi / 180) * initialLateralSpeedInFeetPerMinute
      initialLateralSpeedInFeetPerMinute =
        cos(newValue * .pi / 180) * initialLateralSpeedInFeetPerMinute
    }
  }

  public init(
    initialLateralSpeedInFeetPerMinute: Double,
    touchDownLateralSpeedInFeetPerMinute: Double,
    initialVerticalSpeedInFeetPerMinute: Double,
    touchDownVerticalSpeedInFeetPerMinute: Double,
    desiredTouchdownPointFromFlareInFeet: Double,
    heightOfFlareInFeet: Double
  ) {
    self.initialLateralSpeedInFeetPerMinute = initialLateralSpeedInFeetPerMinute
    self.touchDownLateralSpeedInFeetPerMinute = touchDownLateralSpeedInFeetPerMinute
    self.initialVerticalSpeedInFeetPerMinute = initialVerticalSpeedInFeetPerMinute
    self.touchDownVerticalSpeedInFeetPerMinute = touchDownVerticalSpeedInFeetPerMinute
    self.desiredTouchdownPointFromFlareInFeet = desiredTouchdownPointFromFlareInFeet
    self.heightOfFlareInFeet = heightOfFlareInFeet
  }

  public init(
    initialSpeedInKnots: Double,
    touchDownSpeedInKnots: Double,
    initialFPAInDegrees: Double,
    desiredTouchdownPointFromFlareInFeet: Double,
    heightOfFlareInFeet: Double
  ) {
    self.init(
      initialLateralSpeedInFeetPerMinute: initialSpeedInKnots * 101.26855914,
      touchDownLateralSpeedInFeetPerMinute: touchDownSpeedInKnots * 101.26855914,
      initialVerticalSpeedInFeetPerMinute: sin(initialFPAInDegrees * .pi / 180)
        * initialSpeedInKnots * 101.26855914,
      touchDownVerticalSpeedInFeetPerMinute: sin(initialFPAInDegrees * .pi / 180)
        * touchDownSpeedInKnots * 101.26855914,
      desiredTouchdownPointFromFlareInFeet: desiredTouchdownPointFromFlareInFeet,
      heightOfFlareInFeet: heightOfFlareInFeet
    )
  }
}
