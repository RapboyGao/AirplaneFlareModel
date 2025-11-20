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

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Chart Section
                chartSection

                // Model Selection
                modelSelectionSection

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

            // Height vs Distance Chart
            let keyPoints = computer.keyPoints(using: selectedModel)

            Chart(keyPoints, id: \.id) { point in
                LineMark(
                    x: .value("Distance (ft)", point.lateralPositionInFeet),
                    y: .value("Height (ft)", -point.heightDescended)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Distance (ft)", point.lateralPositionInFeet),
                    y: .value("Height (ft)", -point.heightDescended)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            }
            .frame(height: 300)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // Speed vs Distance Chart
            Chart(keyPoints, id: \.id) { point in
                LineMark(
                    x: .value("Distance (ft)", point.lateralPositionInFeet),
                    y: .value("Speed (knots)", point.lateralSpeedInKnots)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 200)
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
                        format: "%.1f min", computer.minimumTimeOfFlareInMinutes
                    ),
                    color: .green
                )

                statisticCard(
                    title: "Max Flare Time",
                    value: String(
                        format: "%.1f min", computer.maximumTimeOfFlareInMinutes
                    ),
                    color: .orange
                )

                let keyPoints = computer.keyPoints(using: selectedModel)
                statisticCard(
                    title: "Total Points",
                    value: "\(keyPoints.count)",
                    color: .purple
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
        NavigationView {
            AirplaneFlareVisualization()
        }
    }
}
