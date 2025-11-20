import Foundation

public struct AirplaneFlarePointData: Codable, Sendable, Hashable, Identifiable {
  /// 唯一标识符
  public var id: UUID

  /// 时间(分钟数)
  public var timeInMinutes: Double
  /// 水平位置(英尺)
  public var lateralPositionInFeet: Double
  /// 垂直位置(英尺)
  public var verticalPositionInFeet: Double
  /// 水平速度(英尺/分钟)
  public var lateralSpeedInFeetPerMinute: Double
  /// 垂直速度(英尺/分钟)
  public var verticalSpeedInFeetPerMinute: Double

  /// 水平速度(海里/分钟)
  public var lateralSpeedInKnots: Double {
    get { lateralSpeedInFeetPerMinute / 101.26855914 }
    set { lateralSpeedInFeetPerMinute = newValue * 101.26855914 }
  }

  /// 时间(秒数)
  public var timeInSeconds: Double {
    get { timeInMinutes * 60 }
    set { timeInMinutes = newValue / 60 }
  }

  public init(
    timeInMinutes: Double,
    lateralPositionInFeet: Double,
    verticalPositionInFeet: Double,
    lateralSpeedInFeetPerMinute: Double,
    verticalSpeedInFeetPerMinute: Double
  ) {
    self.id = UUID()
    self.timeInMinutes = timeInMinutes
    self.lateralPositionInFeet = lateralPositionInFeet
    self.verticalPositionInFeet = verticalPositionInFeet
    self.lateralSpeedInFeetPerMinute = lateralSpeedInFeetPerMinute
    self.verticalSpeedInFeetPerMinute = verticalSpeedInFeetPerMinute
  }
}
