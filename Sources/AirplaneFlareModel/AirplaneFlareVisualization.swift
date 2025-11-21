import Charts
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AirplaneFlareVisualization: View {
    @State private var computer = AirplaneFlareComputer.example
    @State private var selectedModel: AirplaneFlareModel = .sqrtFunction

    // Constants for slider ranges
    private let initialVerticalSpeedRange = -1000.0...(-500.0)
    private let touchDownVerticalSpeedRange = -400.0...(-20.0)
    private let desiredTouchdownPointRange = 800.0...4500.0
    private let heightOfFlareRange = 10.0...50.0
    private let speedRange = 110.0...190.0

    private var keyPoints: [AirplaneFlarePointData] {
        computer.keyPoints(using: selectedModel)
    }

    private var numberFormat0: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    private var numberFormat1: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(1))
    }

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Model Selection
                modelSelectionSection

                // Chart Section
                chartSection

                // Parameter Controls
                parameterControls

                // Statistics
                statisticsSection
            }
            .padding()
        }
        .navigationTitle("Airplane Flare Model")
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flight Profile")
                .font(.headline)
                .padding(.horizontal)

            Chart(keyPoints) { p in
                LineMark(
                    x: .value("Distance (ft)", p.lateralPositionInFeet),
                    y: .value(
                        "Height (ft)",
                        computer.heightOfFlareInFeet + p.heightDescended
                    ),
                    series: .value("Height", "Height")
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
                LineMark(
                    x: .value(
                        "Distance (ft)", p.lateralPositionInFeet),
                    y: .value(
                        "Verical Speed (knots)",
                        p.verticalSpeedInFeetPerMinute / 18)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .chartXAxis {
                let distances = keyPoints.map {
                    $0.lateralPositionInFeet
                }
                AxisMarks(values: distances) { x in
                    AxisGridLine()
                    AxisTick()
                    if let x = x.as(Double.self) {
                        AxisValueLabel {
                            Text("\(x, format: numberFormat0) ft")
                        }
                    }
                }
                AxisMarks(position: .top, values: distances) { x in
                    if let x = x.as(Double.self) {
                        let thisPoint = keyPoints.first {
                            $0.lateralPositionInFeet == x
                        }
                        if let thisPoint = thisPoint {
                            AxisValueLabel {
                                Text(
                                    "\(thisPoint.timeInMinutes * 60, format: numberFormat1) sec"
                                )
                            }
                        }
                    }
                }
            }
            .chartXAxisLabel("Distance")
            .chartYAxis {
                let heights = keyPoints.map {
                    computer.heightOfFlareInFeet + $0.heightDescended
                }
                AxisMarks(values: heights) { y in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let y = y.as(Double.self) {
                            Text("\(y , format: numberFormat1) ft")
                        }
                    }
                }
                let scaledVS = keyPoints.map {
                    $0.verticalSpeedInFeetPerMinute / 18
                }
                AxisMarks(values: scaledVS) { y in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let y = y.as(Double.self) {
                            Text("\(y * 18, format: numberFormat0) ft/min")
                        }
                    }
                }
            }
            .frame(height: 500)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

        }
    }

    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flare Model")
                .font(.headline)

            Picker("Model", selection: $selectedModel) {
                Text("Square Root Function").tag(
                    AirplaneFlareModel.sqrtFunction)
                Text("Piecewise Linear Profile").tag(
                    AirplaneFlareModel.piecewiseLinearProfile)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)
    }

    private var parameterControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Parameters")
                .font(.headline)
                .padding(.horizontal)

            // Vertical Speed Parameters
            parameterSlider(
                title: "Initial Vertical Speed",
                value: computer.initialVerticalSpeedInFeetPerMinute,
                range: initialVerticalSpeedRange,
                unit: "ft/min",
                step: 10
            ) { newValue in
                var newComputer = computer
                newComputer.initialVerticalSpeedInFeetPerMinute = newValue
                computer = newComputer
            }

            parameterSlider(
                title: "Touchdown Vertical Speed",
                value: computer.touchDownVerticalSpeedInFeetPerMinute,
                range: touchDownVerticalSpeedRange,
                unit: "ft/min",
                step: 5
            ) { newValue in
                var newComputer = computer
                newComputer.touchDownVerticalSpeedInFeetPerMinute = newValue
                computer = newComputer
            }

            // Distance Parameters
            parameterSlider(
                title: "Desired Touchdown Distance",
                value: computer.desiredTouchdownPointFromFlareInFeet,
                range: desiredTouchdownPointRange,
                unit: "ft",
                step: 50
            ) { newValue in
                var newComputer = computer
                newComputer.desiredTouchdownPointFromFlareInFeet = newValue
                computer = newComputer
            }

            parameterSlider(
                title: "Flare Height",
                value: computer.heightOfFlareInFeet,
                range: heightOfFlareRange,
                unit: "ft",
                step: 1
            ) { newValue in
                var newComputer = computer
                newComputer.heightOfFlareInFeet = newValue
                computer = newComputer
            }

            // Speed Parameters
            parameterSlider(
                title: "Initial Speed",
                value: computer.initialSpeedInKnots,
                range: speedRange,
                unit: "knots",
                step: 1
            ) { newValue in
                var newComputer = computer
                newComputer.initialSpeedInKnots = newValue
                computer = newComputer
            }

            parameterSlider(
                title: "Touchdown Speed",
                value: computer.touchDownSpeedInKnots,
                range: speedRange,
                unit: "knots",
                step: 1
            ) { newValue in
                var newComputer = computer
                newComputer.touchDownSpeedInKnots = newValue
                computer = newComputer
            }
        }
    }

    private func parameterSlider(
        title: String,
        value: Double,
        range: ClosedRange<Double>,
        unit: String,
        step: Double,
        onChange: @escaping (Double) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Slider(
                value: Binding(
                    get: { value },
                    set: { newValue in
                        onChange(newValue)
                    }
                ), in: range, step: step
            ) {
                Text(title)
            }
        }
        .padding(.horizontal)
    }

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flight Statistics")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 12
            ) {
                statisticCard(
                    title: "Initial FPA",
                    value: String(
                        format: "%.1f°", computer.initialFPAInDegrees),
                    color: .blue
                )

                statisticCard(
                    title: "Min Flare Time",
                    value: String(
                        format: "%.2f sec",
                        computer.minimumTimeOfFlareInMinutes * 60
                    ),
                    color: .green
                )

                statisticCard(
                    title: "Max Flare Time",
                    value: String(
                        format: "%.2f sec",
                        computer.maximumTimeOfFlareInMinutes * 60
                    ),
                    color: .orange
                )
            }
            .padding(.horizontal)
        }
    }

    private func statisticCard(title: String, value: String, color: Color)
        -> some View
    {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AirplaneFlareVisualization_Previews: PreviewProvider {
    public static var previews: some View {
        NavigationStack {
            AirplaneFlareVisualization()
        }
    }
}
