import Foundation

public struct AirplaneFlareComputer: Codable, Sendable, Hashable {
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

    /// 在公式中用的h1参数
    private var h1: Double {
        get {
            -heightOfFlareInFeet
        }
        set {
            heightOfFlareInFeet = -newValue
        }
    }

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
            atan(
                initialVerticalSpeedInFeetPerMinute
                    / initialLateralSpeedInFeetPerMinute) * 180 / .pi
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
        self.initialLateralSpeedInFeetPerMinute =
            initialLateralSpeedInFeetPerMinute
        self.touchDownLateralSpeedInFeetPerMinute =
            touchDownLateralSpeedInFeetPerMinute
        self.initialVerticalSpeedInFeetPerMinute =
            initialVerticalSpeedInFeetPerMinute
        self.touchDownVerticalSpeedInFeetPerMinute =
            touchDownVerticalSpeedInFeetPerMinute
        self.desiredTouchdownPointFromFlareInFeet =
            desiredTouchdownPointFromFlareInFeet
        self.heightOfFlareInFeet = heightOfFlareInFeet
    }

    public init(
        initialSpeedInKnots: Double,
        touchDownSpeedInKnots: Double,
        initialFPAInDegrees: Double,
        touchDownVerticalSpeedInFeetPerMinute: Double,
        desiredTouchdownPointFromFlareInFeet: Double,
        heightOfFlareInFeet: Double
    ) {
        self.init(
            initialLateralSpeedInFeetPerMinute: initialSpeedInKnots
                * 101.26855914,
            touchDownLateralSpeedInFeetPerMinute: touchDownSpeedInKnots
                * 101.26855914,
            initialVerticalSpeedInFeetPerMinute: sin(
                initialFPAInDegrees * .pi / 180)
                * initialSpeedInKnots * 101.26855914,
            touchDownVerticalSpeedInFeetPerMinute:
                touchDownVerticalSpeedInFeetPerMinute,
            desiredTouchdownPointFromFlareInFeet:
                desiredTouchdownPointFromFlareInFeet,
            heightOfFlareInFeet: heightOfFlareInFeet
        )
    }

}

extension AirplaneFlareComputer {

    public static let example = AirplaneFlareComputer(
        initialSpeedInKnots: 150,
        touchDownSpeedInKnots: 145,
        initialFPAInDegrees: -3,
        touchDownVerticalSpeedInFeetPerMinute: -150,
        desiredTouchdownPointFromFlareInFeet: 2000,
        heightOfFlareInFeet: 50
    )

    /// 从 flare 开始到 touchdown 点的最小时间(分钟)
    /// 从initialLateralSpeedInFeetPerMinute 增加到touchDownLateralSpeedInFeetPerMinute
    /// x * (touchDownLateralSpeedInFeetPerMinute + initialLateralSpeedInFeetPerMinute) / 2 = h1
    /// 所以 x = 2 * h1 / (touchDownLateralSpeedInFeetPerMinute + initialLateralSpeedInFeetPerMinute)
    public var minimumTimeOfFlareInMinutes: Double {
        2 * h1
            / (touchDownVerticalSpeedInFeetPerMinute
                + initialVerticalSpeedInFeetPerMinute)
    }

    /// 从 flare 开始到 touchdown 点的最大时间(分钟)
    /// 从initialLateralSpeedInFeetPerMinute 增加到touchDownLateralSpeedInFeetPerMinute
    /// x * touchDownLateralSpeedInFeetPerMinute = h1
    /// 所以 x = h1 / touchDownLateralSpeedInFeetPerMinute
    public var maximumTimeOfFlareInMinutes: Double {
        h1 / touchDownVerticalSpeedInFeetPerMinute
    }

    public var lateralProfileFunction: LinearFunction {
        LinearFunction(
            b: initialLateralSpeedInFeetPerMinute,
            y1: touchDownLateralSpeedInFeetPerMinute,
            integralH: desiredTouchdownPointFromFlareInFeet)
    }

    public func keyPoints(using model: AirplaneFlareModel)
        -> [AirplaneFlarePointData]
    {
        switch model {
        case .sqrtFunction:
            return keyPoints(SqrtFunction.self)
        case .piecewiseLinearProfile:
            return keyPoints(PiecewiseLinearPlateauFunction.self)
        }
    }

    public func keyPoints<ThisFlareModel: TimedFlareFunctionBaseProtocol>(
        _ Model: ThisFlareModel.Type
    )
        -> [AirplaneFlarePointData]
    {
        var lProfile = self.lateralProfileFunction
        /// 计算 flare 总时间(分钟)
        let totalTimeOfFlare = lProfile.x(
            fromIntegral: desiredTouchdownPointFromFlareInFeet)
        /// 确保 flare 总时间在最小和最大时间之间
        //        totalTimeOfFlare = max(
        //            minimumTimeOfFlareInMinutes,
        //            min(maximumTimeOfFlareInMinutes, totalTimeOfFlare))
        //        /// 修正 flare 总时间(分钟)
        //        lProfile = LinearFunction(
        //            point0: SIMD2(0, initialLateralSpeedInFeetPerMinute),
        //            point1: SIMD2(
        //                totalTimeOfFlare, touchDownLateralSpeedInFeetPerMinute))

        let vProfile = ThisFlareModel(
            y0: initialVerticalSpeedInFeetPerMinute,
            y1: touchDownVerticalSpeedInFeetPerMinute,
            x1: totalTimeOfFlare,
            h1: h1
        )

        var desiredPoints: [Double] = [
            0, 500, 1000, 1312, 1500, 2000, 2500, 3000,
            lProfile.integral(atX: totalTimeOfFlare),
        ]
        if let vProfile = vProfile as? PiecewiseLinearPlateauFunction {
            desiredPoints.append(lProfile.integral(atX: vProfile.a))
        }
        desiredPoints.sort()

        let keyPoints = desiredPoints.map { distance in
            let x = lProfile.x(fromIntegral: distance)
            return AirplaneFlarePointData(
                timeInMinutes: x,
                lateralPositionInFeet: distance,
                heightDescended: vProfile.integral(atX: x),
                lateralSpeedInFeetPerMinute: lProfile.y(at: x),
                verticalSpeedInFeetPerMinute: vProfile.y(atX: x)
            )
        }
        return keyPoints.filter { $0.timeInMinutes <= totalTimeOfFlare }
    }
}
