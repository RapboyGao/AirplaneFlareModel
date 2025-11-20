# Airplane Flare Model Visualization

A comprehensive SwiftUI-based visualization tool for aircraft landing flare profiles, supporting iOS 16.0+, iPadOS 16.0+, macOS 13.0+, tvOS 16.0+, visionOS 1.0+, and watchOS 9.0+.

## Features

### 🎯 Interactive Visualization
- **Real-time Charts**: Visualize flight profiles using SwiftCharts
- **Dual Chart Display**: Height vs Distance and Speed vs Distance charts
- **Live Updates**: Charts update instantly as you adjust parameters

### 🎛️ Parameter Control
Adjustable parameters with precise slider controls:
- **Initial Vertical Speed**: -1000 to -500 ft/min
- **Touchdown Vertical Speed**: -400 to -20 ft/min  
- **Desired Touchdown Distance**: 800 to 4500 ft
- **Flare Height**: 10 to 50 ft
- **Initial Speed**: 110 to 190 knots
- **Touchdown Speed**: 110 to 190 knots

### 📊 Model Comparison
- **Multiple Models**: Support for sqrtFunction and piecewiseLinearProfile
- **Side-by-side Comparison**: Compare different configurations
- **Statistical Analysis**: Real-time flight statistics display

### 📱 Multi-Platform Support
- iOS 16.0+
- iPadOS 16.0+
- macOS 13.0+
- tvOS 16.0+
- visionOS 1.0+
- watchOS 9.0+
- Mac Catalyst 16.0+

## Installation

### Swift Package Manager
Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/AirplaneFlareModel", from: "1.0.0")
]
```

### Xcode
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select the latest version
4. Add to your target

## Usage

### Basic Implementation

```swift
import SwiftUI
import AirplaneFlareModel

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AirplaneFlareVisualization()
                    .navigationTitle("Flare Analysis")
            }
        }
    }
}
```

### Advanced Usage with Custom Parameters

```swift
struct ContentView: View {
    @State private var computer = AirplaneFlareComputer(
        initialSpeedInKnots: 150,
        touchDownSpeedInKnots: 140,
        initialFPAInDegrees: -3.0,
        desiredTouchdownPointFromFlareInFeet: 2000,
        heightOfFlareInFeet: 30
    )
    
    var body: some View {
        VStack {
            // Custom parameter controls
            HStack {
                Text("Initial Speed: \(Int(computer.initialSpeedInKnots)) knots")
                Slider(value: $initialSpeed, in: 110...190)
            }
            
            // Chart visualization
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                Chart(computer.keyPoints(using: .sqrtFunction), id: \.id) { point in
                    LineMark(
                        x: .value("Distance", point.lateralPositionInFeet),
                        y: .value("Height", -point.heightDescended)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 300)
            }
        }
    }
}
```

### Demo App

Use the complete demo application:

```swift
AirplaneFlareDemoApp()
```

This includes:
- Main visualization tab
- Model comparison view
- Settings and configuration

## API Reference

### AirplaneFlareComputer

The core model for calculating flare profiles:

```swift
let computer = AirplaneFlareComputer(
    initialSpeedInKnots: 150,
    touchDownSpeedInKnots: 140,
    initialFPAInDegrees: -3.0,
    desiredTouchdownPointFromFlareInFeet: 2000,
    heightOfFlareInFeet: 30
)

// Get key points for visualization
let keyPoints = computer.keyPoints(using: .sqrtFunction)

// Access computed properties
let minTime = computer.minimumTimeOfFlareInMinutes
let maxTime = computer.maximumTimeOfFlareInMinutes
let initialFPA = computer.initialFPAInDegrees
```

### AirplaneFlareVisualization

Main visualization view with interactive controls:

```swift
AirplaneFlareVisualization()
```

### AirplaneFlarePointData

Data structure for individual flight profile points:

```swift
struct AirplaneFlarePointData {
    var timeInMinutes: Double
    var lateralPositionInFeet: Double
    var heightDescended: Double
    var lateralSpeedInFeetPerMinute: Double
    var verticalSpeedInFeetPerMinute: Double
    var fPAInDegrees: Double
    var lateralSpeedInKnots: Double
}
```

## Examples

### Flight Profile Analysis

```swift
// Create different configurations
let config1 = AirplaneFlareComputer(
    initialSpeedInKnots: 150,
    touchDownSpeedInKnots: 140,
    initialFPAInDegrees: -3.0,
    desiredTouchdownPointFromFlareInFeet: 2000,
    heightOfFlareInFeet: 30
)

let config2 = AirplaneFlareComputer(
    initialSpeedInKnots: 160,
    touchDownSpeedInKnots: 150,
    initialFPAInDegrees: -2.5,
    desiredTouchdownPointFromFlareInFeet: 2500,
    heightOfFlareInFeet: 35
)

// Compare profiles
let points1 = config1.keyPoints(using: .sqrtFunction)
let points2 = config2.keyPoints(using: .sqrtFunction)
```

### Export Data

```swift
func exportFlightData(computer: AirplaneFlareComputer) {
    let keyPoints = computer.keyPoints(using: .sqrtFunction)
    
    for point in keyPoints {
        print("Time: \(point.timeInMinutes) min")
        print("Distance: \(point.lateralPositionInFeet) ft")
        print("Height: \(point.heightDescended) ft")
        print("Speed: \(point.lateralSpeedInKnots) knots")
        print("FPA: \(point.fPAInDegrees)°")
        print("---")
    }
}
```

## Customization

### Chart Styling

```swift
Chart(keyPoints, id: \.id) { point in
    LineMark(
        x: .value("Distance", point.lateralPositionInFeet),
        y: .value("Height", -point.heightDescended)
    )
    .foregroundStyle(.green) // Custom color
    .lineStyle(StrokeStyle(lineWidth: 3, dash: [5, 5])) // Custom line style
}
```

### Parameter Ranges

Customize slider ranges in your implementation:

```swift
Slider(value: $speed, in: 100...200) // Custom speed range
Slider(value: $height, in: 5...60)   // Custom height range
```

## Requirements

- Swift 5.7+
- iOS 16.0+ / iPadOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / visionOS 1.0+ / watchOS 9.0+
- Xcode 14.0+
- SwiftCharts framework

## Dependencies

- SwiftCharts (automatically included)

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Support

For support, please open an issue on the GitHub repository or contact the development team.

## Changelog

### Version 1.0.0
- Initial release
- Interactive SwiftCharts visualization
- Multi-platform support
- Parameter control sliders
- Model comparison features
- Demo application included