# Wilson Telematics Insurance

<div align="center">

**A Complete iOS Telematics-Based Insurance Pricing Application**

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-Educational-lightgrey.svg)](LICENSE)

*Transform driving behavior data into personalized insurance pricing*

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Technical Details](#-technical-details)
- [Roadmap](#-roadmap)
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

---

## 🎯 Overview

Wilson Telematics Insurance is a complete iOS application that leverages real-time driving behavior data (telematics) to calculate personalized car insurance pricing. By monitoring driving patterns such as harsh braking, speeding, phone usage, and night driving, the app provides users with transparent, behavior-based insurance quotes and actionable tips to reduce premiums.

Built with modern iOS technologies including **Swift**, **SwiftUI**, and the **Damoov Telematics SDK**, this application demonstrates the future of usage-based insurance (UBI) where safe drivers are rewarded with lower premiums.

### Key Highlights

- 📊 **Real-time Driving Analytics** - Track and visualize driving behavior metrics
- 💰 **Dynamic Pricing Model** - Insurance quotes based on actual driving patterns
- 🎮 **Interactive Pricing Lab** - Experiment with different driving behaviors to see premium impacts
- 💡 **Personalized Tips** - Get actionable advice to improve driving safety and reduce costs
- 🏗️ **Clean Architecture** - MVVM pattern with clear separation of concerns
- 📱 **Native iOS** - Built entirely with SwiftUI for a modern, responsive UI

---

## ✨ Features

### 📈 Dashboard

The main hub for all driving insights:

- **Real-time Driving Score** (0-100) - Overall assessment of driving safety
- **Trip Statistics** - Total trips, distance traveled, and driving hours
- **Recent Trips List** - Detailed view of recent journeys with behavior metrics
- **Live Data Sync** - Refresh button to fetch the latest telematics data
- **Quick Overview Cards** - At-a-glance metrics for key driving behaviors

### 🧪 Pricing Lab

Interactive tool for understanding insurance pricing:

- **Dynamic Sliders** - Adjust driving behavior parameters in real-time
  - Harsh braking rate (events per 100 km)
  - Speeding events per trip
  - Phone usage percentage
  - Night driving ratio
- **Live Premium Calculation** - See immediate pricing updates as you adjust behaviors
- **Risk Score Breakdown** - Understand how each factor contributes to your premium
- **Visual Risk Indicators** - Color-coded bars showing risk levels for each category
- **Baseline Comparison** - Compare custom scenarios against your actual driving

### 💡 Tips & Advice

Comprehensive guidance for safer driving and lower premiums:

- **8 Safety Tips** - Best practices for defensive and safe driving
- **6 Cost-Saving Strategies** - Actionable advice to reduce insurance premiums
- **Categorized Content** - Tips organized by safety and financial impact
- **Easy-to-Follow Format** - Clear, concise advice with practical implementation steps

### 🚀 Onboarding

Smooth initial setup experience:

- **SDK Initialization** - Seamless setup of the Damoov Telematics SDK
- **Permission Requests** - Guided flow for location and motion permissions
- **Device Token Configuration** - Easy integration with Damoov DataHub
- **Welcome Experience** - Clear explanation of app features and benefits

---

## 🏗️ Architecture

The application follows a **clean, layered architecture** with clear separation between business logic, data models, and UI components:

```
┌─────────────────────────────────────────────────┐
│                      App                        │
│   (Entry Point & Configuration)                 │
│   • WilsonTelematicsInsuranceApp.swift          │
│   • AppDelegate.swift                           │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                     Views                       │
│    (SwiftUI UI Modules)                         │
│   • Dashboard    • Tips                         │
│   • PricingLab   • Onboarding                   │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                     Core                        │
│   (Business Logic & Services)                   │
│   • Models: Trip, DriverFeatures, PricingQuote  │
│   • Services: TelematicsService, PricingModel   │
└─────────────────────────────────────────────────┘
```

### Design Patterns

- **MVVM (Model-View-ViewModel)** - Views observe `@ObservableObject` services for reactive updates
- **Dependency Injection** - Services accessed via `.shared` singleton pattern for easy testing
- **Protocol-Oriented Design** - `Tip` protocol enables extensible tips system
- **Composition** - Small, reusable SwiftUI components for maintainability

---

## 📁 Project Structure

```
WilsonTelematicsInsurance/
│
├── App/
│   ├── WilsonTelematicsInsuranceApp.swift    # SwiftUI @main entry point
│   ├── AppDelegate.swift                     # SDK lifecycle management
│   └── Info.plist                            # App configuration & permissions
│
├── Core/
│   ├── Models/
│   │   ├── Trip.swift                        # Trip data model
│   │   ├── DriverFeatures.swift              # Aggregated driving metrics
│   │   └── PricingQuote.swift                # Insurance quote model
│   │
│   └── Services/
│       ├── TelematicsService.swift           # Telematics SDK wrapper
│       └── PricingModel.swift                # Insurance pricing engine
│
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift               # Main dashboard screen
│   │   ├── DrivingScoreCard.swift            # Score display component
│   │   ├── TripStatsCard.swift               # Statistics component
│   │   └── RecentTripsList.swift             # Trip history list
│   │
│   ├── PricingLab/
│   │   ├── PricingLabView.swift              # Interactive pricing tool
│   │   ├── BehaviorSlider.swift              # Custom slider component
│   │   └── RiskFactorBar.swift               # Risk visualization
│   │
│   ├── Tips/
│   │   ├── TipsView.swift                    # Tips & advice screen
│   │   ├── TipCard.swift                     # Individual tip display
│   │   └── Tip.swift                         # Tip protocol & data
│   │
│   └── Onboarding/
│       └── OnboardingView.swift              # Initial setup screen
│
├── Resources/
│   └── Assets.xcassets                       # App icons and images
│
└── WilsonTelematicsInsurance.xcodeproj       # Xcode project file
```

---

## 💻 Requirements

### System Requirements

- **iOS**: 15.0 or later
- **Xcode**: 14.0 or later
- **Swift**: 5.5 or later
- **macOS**: 12.0+ (for development)

### Device Requirements

- iPhone or iPad running iOS 15.0+
- **Physical device recommended** for accurate telematics data collection
- Background app refresh capability
- Location services support

### Permissions Required

The app requires the following iOS permissions (pre-configured in `Info.plist`):

- **Location Permissions** (for trip tracking):
  - `NSLocationAlwaysAndWhenInUseUsageDescription`
  - `NSLocationAlwaysUsageDescription`
  - `NSLocationWhenInUseUsageDescription`
  
- **Motion Permission** (for driving behavior detection):
  - `NSMotionUsageDescription`

- **Background Modes**:
  - Location updates
  - Background fetch
  - Remote notifications

---

## 🚀 Installation

### Option 1: Clone and Open in Xcode

```bash
# Clone the repository
git clone https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main.git

# Navigate to project directory
cd WilsonTelematicsInsurance-1.0-main

# Open in Xcode
open WilsonTelematicsInsurance.xcodeproj
```

### Option 2: Download ZIP

1. Download the repository as ZIP from GitHub
2. Extract the archive
3. Double-click `WilsonTelematicsInsurance.xcodeproj` to open in Xcode

### Installing Dependencies

The project uses **Swift Package Manager (SPM)** for dependency management:

1. **Open the project in Xcode**
2. Navigate to **File → Add Package Dependencies**
3. Enter the Telematics SDK package URL:
   ```
   https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM
   ```
4. Set **minimum version**: `7.0.0`
5. Select target: `WilsonTelematicsInsurance`
6. Click **Add Package**

Xcode will automatically resolve and download the dependency.

---

## ⚙️ Configuration

### 1. Obtain a Device Token

To use the Telematics SDK, you need a device token from Damoov:

1. Create an account at [Damoov DataHub](https://platform.damoov.com/)
2. Create a new application in the dashboard
3. Copy your device token

### 2. Configure the Token

Update the device token in your code:

**In `OnboardingView.swift`:**
```swift
// Replace with your actual token
let deviceToken = "YOUR_DEVICE_TOKEN_HERE"
telematicsService.initializeSDK(deviceToken: deviceToken)
```

**Or in `AppDelegate.swift`:**
```swift
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    TelematicsService.shared.initializeSDK(deviceToken: "YOUR_DEVICE_TOKEN_HERE")
    return true
}
```

> **Note**: For development and testing, the app includes demo functionality with mock data that works without a real token.

### 3. Configure Signing

1. Open the project in Xcode
2. Select the `WilsonTelematicsInsurance` target
3. Go to **Signing & Capabilities**
4. Add your Apple Developer account
5. Select your team and bundle identifier

### 4. Enable Background Modes

Ensure the following capabilities are enabled:

- ✅ **Location updates**
- ✅ **Background fetch**
- ✅ **Remote notifications**

### 5. Background Task Identifiers

The following background task identifiers are already configured in `Info.plist`:

- `sdk.damoov.apprefreshtaskid`
- `sdk.damoov.appprocessingtaskid`

---

## 🎮 Usage

### Running the App

1. **Select Target Device**
   - Choose a simulator (iOS 15.0+) or connect a physical device
   - Physical device recommended for real telematics data

2. **Build and Run**
   - Press `⌘R` or click the Run button
   - Grant permissions when prompted:
     - Location (Always)
     - Motion & Fitness

3. **Initial Setup**
   - Complete the onboarding flow
   - SDK will initialize automatically
   - App will start tracking trips in the background

### Testing with Mock Data

For testing without real trips, the app includes comprehensive mock data:

```swift
// In your code
let mockTrips = Trip.mockTrips()           // Sample trip data
let mockFeatures = DriverFeatures.mock()   // Aggregated features
let mockQuote = PricingQuote.mock()        // Sample insurance quote
```

This allows you to:
- Test UI components without waiting for real trip data
- Demonstrate app functionality in presentations
- Develop and debug features offline

---

## 🔧 Technical Details

### Telematics Integration

The `TelematicsService` provides a clean interface to the Damoov SDK:

```swift
// Initialize the SDK
TelematicsService.shared.initializeSDK(deviceToken: "YOUR_TOKEN")

// Start automatic trip tracking
TelematicsService.shared.startTracking()

// Fetch trip data
let trips = try await TelematicsService.shared.fetchTrips()

// Calculate driving features from trips
let features = DriverFeatures(from: trips)
```

**Key Features:**
- Automatic trip detection
- Background tracking
- Low battery impact
- Accurate event detection (braking, speeding, phone usage)

### Pricing Algorithm

The `PricingModel` calculates insurance premiums based on risk factors:

```swift
// Calculate quote from actual driving data
let quote = PricingModel.shared.calculateQuote(from: driverFeatures)

// Custom quote for experimentation (Pricing Lab)
let customQuote = PricingModel.shared.calculateCustomQuote(
    harshBrakingRate: 2.0,           // Events per 100 km
    speedingEventsPerTrip: 3.0,      // Average speeding events
    phoneUsageRatio: 0.1,            // 10% phone usage
    nightDrivingRatio: 0.2           // 20% night driving
)
```

**Risk Factor Weights:**
- 🏎️ **Speeding**: 35% - Highest impact on premium
- 🚗 **Harsh Braking**: 30% - Strong indicator of risk
- 📱 **Phone Usage**: 20% - Distraction factor
- 🌙 **Night Driving**: 15% - Increased accident risk

**Base Premium**: $1,200/year  
**Risk Multiplier Range**: 0.7x to 2.0x  
**Final Premium Range**: $840 to $2,400/year

### Data Models

**Trip Model:**
```swift
struct Trip {
    let id: String
    let startTime: Date
    let endTime: Date
    let distance: Double              // Kilometers
    let harshBrakingCount: Int
    let speedingCount: Int
    let phoneUsageSeconds: Double
    let nightDrivingSeconds: Double
}
```

**Driver Features Model:**
```swift
struct DriverFeatures {
    let totalTrips: Int
    let totalDistance: Double         // Kilometers
    let totalDrivingHours: Double
    let harshBrakingRate: Double      // Per 100 km
    let speedingEventsPerTrip: Double
    let phoneUsageRatio: Double       // 0.0 to 1.0
    let nightDrivingRatio: Double     // 0.0 to 1.0
}
```

**Pricing Quote Model:**
```swift
struct PricingQuote {
    let basePremium: Double           // Base annual premium
    let riskMultiplier: Double        // 0.7 to 2.0
    let finalPremium: Double          // Calculated premium
    let riskScore: Double             // 0 to 100
    let riskFactors: [RiskFactor]     // Individual risk breakdowns
}
```

---

## 🗺️ Roadmap

### Phase 1: Production-Ready SDK Integration ✅ (Current)

- [x] Basic SDK integration
- [x] Mock data for testing
- [ ] Complete SDK method implementations
- [ ] Robust error handling
- [ ] Real-time trip detection testing

### Phase 2: User Authentication & Backend

- [ ] User registration and login system
- [ ] Secure token storage (Keychain)
- [ ] Backend API for user data
- [ ] Cloud sync for trip history
- [ ] User profile management

### Phase 3: Enhanced Features

- [ ] **Trip Detail View**
  - Interactive map showing route
  - Driving events marked on map
  - Speed graph throughout trip
  - Detailed behavior breakdown

- [ ] **Historical Analytics**
  - Monthly/yearly driving trends
  - Premium history over time
  - Improvement tracking
  - Goal setting and achievements

- [ ] **Social & Comparison**
  - Anonymous comparison with similar drivers
  - Leaderboards (optional opt-in)
  - Share achievements on social media
  - Challenge friends

- [ ] **Smart Notifications**
  - Trip summaries after each drive
  - Weekly driving reports
  - Premium update alerts
  - Safety tips based on patterns

### Phase 4: Advanced Features

- [ ] **AI-Powered Insights**
  - Predictive driving pattern analysis
  - Personalized improvement recommendations
  - Route safety ratings
  - Optimal driving time suggestions

- [ ] **Gamification**
  - Achievement badges
  - Streak tracking
  - Reward points for safe driving
  - Premium discounts for milestones

- [ ] **Integration Options**
  - Connect with insurance providers
  - Export data to other platforms
  - API for third-party integrations

### Phase 5: Testing & Quality Assurance

- [ ] **Comprehensive Testing**
  - Unit tests for pricing model
  - UI tests for critical user flows
  - Integration tests with SDK
  - Performance testing
  - Security audit

- [ ] **Analytics & Monitoring**
  - Crash reporting (Firebase Crashlytics)
  - Usage analytics
  - Performance monitoring
  - A/B testing framework

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### Ways to Contribute

1. **Report Bugs** - Found a bug? Open an issue with detailed steps to reproduce
2. **Suggest Features** - Have an idea? We'd love to hear it!
3. **Submit Pull Requests** - Fix bugs or add features
4. **Improve Documentation** - Help make our docs clearer
5. **Share Feedback** - User experience insights are valuable

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Style Guidelines

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and concise
- Write unit tests for new features

---

## 📄 License

This project is licensed for **educational and demonstration purposes only**.

### Important Notes:

- **Not for Production Use** - This is a demo/learning project
- **SDK License** - The Damoov Telematics SDK has its own license terms
- **Insurance Pricing** - The pricing model is simplified for demonstration and should not be used for actual insurance calculations

For any questions about licensing or usage, please open an issue on GitHub.

---

## 🆘 Support

### Getting Help

**For App-Related Questions:**
- Open an issue on [GitHub Issues](https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main/issues)
- Check existing issues for similar problems
- Provide detailed information including iOS version and Xcode version

**For Telematics SDK Questions:**
- Visit [Damoov Documentation](https://docs.damoov.com/)
- Check the [SDK GitHub Repository](https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM)
- Contact Damoov support team

### Common Issues

**Issue**: SDK not initializing
- **Solution**: Verify your device token is correct and active

**Issue**: Trips not recording
- **Solution**: Check location permissions are set to "Always" and background modes are enabled

**Issue**: Build errors after cloning
- **Solution**: Clean build folder (⌘⇧K) and ensure Swift packages are resolved

**Issue**: App crashes on launch
- **Solution**: Verify all permissions are configured in Info.plist and SDK version is 7.0.0+

---

## 👨‍💻 About

This project was developed to demonstrate the integration of telematics technology with insurance pricing models, showcasing how modern iOS development practices can create compelling, data-driven user experiences.

### Technologies Used

- **Swift** - Primary programming language
- **SwiftUI** - Modern declarative UI framework
- **Damoov Telematics SDK** - Trip detection and behavior analysis
- **Swift Package Manager** - Dependency management
- **Combine** - Reactive programming framework

### Author

**Weihan C**
- GitHub: [@WeihanC](https://github.com/WeihanC)

---

<div align="center">

**Made with ❤️ using SwiftUI**

⭐ Star this repo if you find it helpful!

</div>
