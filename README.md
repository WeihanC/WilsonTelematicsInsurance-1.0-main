# Wilson Telematics Insurance App

A complete iOS application that uses driving behavior data (telematics) to estimate car insurance pricing. Built with Swift, SwiftUI, and the Damoov Telematics SDK.

## 🏗️ Project Architecture

The project follows a clean, layered architecture:

### Core Layer
Contains business logic, models, and services:
- **Models**: `Trip`, `DriverFeatures`, `PricingQuote`
- **Services**: 
  - `TelematicsService`: Wraps the Telematics SDK functionality
  - `PricingModel`: Calculates insurance pricing from driving behavior

### Features Layer
UI modules organized by feature:
- **Dashboard**: Overview of driving metrics and recent trips
- **Pricing Lab**: Interactive tool to experiment with insurance pricing
- **Tips**: Driving safety advice and premium reduction tips
- **Onboarding**: Initial user experience and SDK setup

### App Layer
Application entry point and configuration:
- `WilsonTelematicsInsuranceApp`: SwiftUI @main entry point with TabView navigation
- `AppDelegate`: SDK lifecycle management

## 📦 Dependencies

The project uses Swift Package Manager (SPM) to integrate:

- **TelematicsSDK**: Version 7.0.0+
  - URL: `https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM`
  - Provides driving behavior tracking and trip detection

## 🔐 Permissions & Configuration

### Info.plist Configuration

The app requires the following permissions (already configured):

**Location Permissions** (for trip tracking):
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- `NSLocationWhenInUseUsageDescription`

**Motion Permission** (for driving behavior detection):
- `NSMotionUsageDescription`

**Background Modes** (for automatic trip detection):
- `location`
- `fetch`
- `remote-notification`

**Background Task Identifiers** (required by Telematics SDK):
- `sdk.damoov.apprefreshtaskid`
- `sdk.damoov.appprocessingtaskid`

### Capabilities Required

In Xcode, ensure the following capabilities are enabled:
1. **Background Modes**:
   - Location updates
   - Background fetch
   - Remote notifications

## 🚀 Setup Instructions

### 1. Open in Xcode

```bash
# Option A: Create a new Xcode project and copy files
# 1. Open Xcode
# 2. Create new App project named "WilsonTelematicsInsurance"
# 3. Copy all Swift files to the project
# 4. Copy Info.plist to replace the default

# Option B: Use existing project structure
# 1. Open the WilsonTelematicsInsurance.xcodeproj in Xcode
```

### 2. Add Telematics SDK via SPM

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the package URL: `https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM`
3. Set minimum version: **7.0.0**
4. Select target: **WilsonTelematicsInsurance**
5. Click **Add Package**

### 3. Configure Device Token

To use the Telematics SDK, you need a device token from Damoov DataHub:

1. Create an account at [Damoov DataHub](https://platform.damoov.com/)
2. Create a new application
3. Get your device token
4. Update the token in `OnboardingView.swift` or `AppDelegate.swift`

For development, the app uses a demo token: `DEMO_DEVICE_TOKEN_[UUID]`

### 4. Configure Signing & Capabilities

1. Select the **WilsonTelematicsInsurance** target
2. Go to **Signing & Capabilities**
3. Add your Apple Developer account
4. Enable **Background Modes**:
   - ✅ Location updates
   - ✅ Background fetch
   - ✅ Remote notifications

### 5. Build and Run

1. Select a simulator or physical device (iOS 15.0+)
2. Press **⌘R** to build and run
3. Grant permissions when prompted

## 📱 Features

### Dashboard
- Real-time driving score (0-100)
- Trip statistics (total trips, distance, hours)
- Recent trips list with behavior metrics
- Refresh button to fetch latest data

### Pricing Lab
- Interactive sliders for driving behavior parameters:
  - Harsh braking rate
  - Speeding events per trip
  - Phone usage percentage
  - Night driving percentage
- Real-time premium calculation
- Risk score breakdown
- Visual risk factor bars

### Tips
- Safe driving tips (8 tips)
- Premium reduction advice (6 tips)
- Categorized by safety and cost savings

## 🧪 Mock Data

The app includes comprehensive mock data for testing without real trips:
- `Trip.mockTrips()`: Sample trip data
- `DriverFeatures.mock()`: Aggregated features
- `PricingQuote.mock()`: Sample quotes

## 🔧 Technical Details

### Minimum Requirements
- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

### Telematics SDK Integration

The `TelematicsService` provides a clean interface to the SDK:

```swift
// Initialize SDK
telematicsService.initializeSDK(deviceToken: "YOUR_TOKEN")

// Start tracking
telematicsService.startTracking()

// Fetch trips
let trips = try await telematicsService.fetchTrips()

// Get driving features
let features = DriverFeatures(from: trips)
```

### Pricing Model

The `PricingModel` calculates premiums based on risk factors:

```swift
// Calculate quote from driver features
let quote = pricingModel.calculateQuote(from: features)

// Custom quote for experimentation
let customQuote = pricingModel.calculateCustomQuote(
    harshBrakingRate: 2.0,
    speedingEventsPerTrip: 3.0,
    phoneUsageRatio: 0.1,
    nightDrivingRatio: 0.2
)
```

Risk factors weighted as:
- Speeding: 35%
- Harsh Braking: 30%
- Phone Usage: 20%
- Night Driving: 15%

## 🎨 Design Patterns

- **MVVM**: Views observe `@ObservableObject` services
- **Dependency Injection**: Services accessed via `.shared` singleton pattern
- **Protocol-Oriented**: `Tip` protocol for extensible tips system
- **Composition**: Small, reusable SwiftUI components

## 📝 Next Steps

To make this production-ready:

1. **Implement Real SDK Integration**:
   - Replace mock data in `TelematicsService.fetchTrips()`
   - Implement actual SDK method calls (commented as TODO)
   - Add proper error handling

2. **Add Authentication**:
   - User registration/login
   - Secure token storage (Keychain)
   - Backend API integration

3. **Enhanced Features**:
   - Trip detail view with maps
   - Historical pricing trends
   - Compare with other drivers
   - Push notifications for trips

4. **Testing**:
   - Unit tests for pricing model
   - UI tests for critical flows
   - Integration tests with SDK

5. **Analytics & Monitoring**:
   - Crash reporting
   - Usage analytics
   - Performance monitoring

## 📚 Resources

- [Damoov Documentation](https://docs.damoov.com/)
- [Telematics SDK iOS](https://docs.damoov.com/docs/-download-the-sdk-and-install-it-in-your-environment)
- [DataHub Platform](https://platform.damoov.com/)

## 📄 License

This is a demo project for educational purposes.

## 🤝 Support

For SDK-related questions, visit [Damoov Documentation](https://docs.damoov.com/) or contact their support team.
