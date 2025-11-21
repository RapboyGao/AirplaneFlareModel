import Foundation

public struct AirplaneFlarePointData: Codable, Sendable, Hashable, Identifiable,
  CustomStringConvertible
{
  /// 唯一标识符
  public var id: UUID

  /// 时间(分钟数)
  public var timeInMinutes: Double
  /// 水平位置(英尺)
  public var lateralPositionInFeet: Double
  /// 垂直位置(英尺)
  public var heightDescended: Double
  /// 水平速度(英尺/分钟)
  public var lateralSpeedInFeetPerMinute: Double
  /// 垂直速度(英尺/分钟)
  public var verticalSpeedInFeetPerMinute: Double

  public var height: Double

  /// 飞行路径角度(度)
  public var fPAInDegrees: Double {
    get {
      atan(verticalSpeedInFeetPerMinute / lateralSpeedInFeetPerMinute)
        * 180 / .pi
    }
    set {
      verticalSpeedInFeetPerMinute =
        sin(newValue * .pi / 180) * lateralSpeedInFeetPerMinute
      lateralSpeedInFeetPerMinute =
        cos(newValue * .pi / 180) * lateralSpeedInFeetPerMinute
    }
  }

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

  public var description: String {
    """
    时间(秒): \(timeInSeconds)
    水平速度(节): \(lateralSpeedInKnots)
    水平位置(英尺): \(lateralPositionInFeet)
    垂直位置(英尺): \(heightDescended)
    垂直速度(英尺/分钟): \(verticalSpeedInFeetPerMinute)
    飞行路径角度(度): \(fPAInDegrees)
    \n\n
    """
  }

  public init(
    timeInMinutes: Double,
    lateralPositionInFeet: Double,
    heightDescended: Double,
    lateralSpeedInFeetPerMinute: Double,
    verticalSpeedInFeetPerMinute: Double,
    height: Double
  ) {
    self.id = UUID()
    self.timeInMinutes = timeInMinutes
    self.lateralPositionInFeet = lateralPositionInFeet
    self.heightDescended = heightDescended
    self.lateralSpeedInFeetPerMinute = lateralSpeedInFeetPerMinute
    self.verticalSpeedInFeetPerMinute = verticalSpeedInFeetPerMinute
    self.height = height
  }
}
