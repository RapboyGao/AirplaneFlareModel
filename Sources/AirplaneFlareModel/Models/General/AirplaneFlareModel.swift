import Foundation

public enum AirplaneFlareModel: Codable, Sendable, Hashable, CaseIterable, Identifiable {
  // 1. 负指数偏移函数 - 最经典的饱和增长模型，无限逼近 asymptote
  case exponentialFlareFunction

  // 2. 反比例偏移函数 - 变化率随时间迅速衰减，较"硬"的拉平曲线
  case rationalFlareFunction

  // 3. 逆平方根函数 - 介于反比例和指数之间
  case inverseSqrtFlareFunction

  // 4. 逆平方函数 - 唯一具有完美解析解的"倒数类"模型，无需牛顿迭代
  case inverseSquareFlareFunction

  // 5. 分段线性平台函数 - 包含线性上升段和平坦段
  case piecewiseLinearPlateauFunction

  public var id: Self {
    self
  }

  // 获取模型的描述
  public var description: String {
    switch self {
    case .exponentialFlareFunction:
      return "负指数偏移函数"
    case .rationalFlareFunction:
      return "反比例偏移函数"
    case .inverseSqrtFlareFunction:
      return "逆平方根函数"
    case .inverseSquareFlareFunction:
      return "逆平方函数"
    case .piecewiseLinearPlateauFunction:
      return "分段线性平台函数"
    }
  }
}
