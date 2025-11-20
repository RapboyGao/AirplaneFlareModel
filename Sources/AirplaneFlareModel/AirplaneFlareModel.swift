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

  public var initialSpeedInKnots: Double {
    get { initialLateralSpeedInFeetPerMinute * 101.26855914 }
    set { initialLateralSpeedInFeetPerMinute = newValue / 101.26855914 }
  }
  public var touchDownSpeedInKnots: Double {
    get { touchDownLateralSpeedInFeetPerMinute * 101.26855914 }
    set { touchDownLateralSpeedInFeetPerMinute = newValue / 101.26855914 }
  }
}
