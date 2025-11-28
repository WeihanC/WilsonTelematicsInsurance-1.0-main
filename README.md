# Wilson Telematics Insurance

An iOS car insurance pricing app based on driving behavior data

## 📱 Overview

A complete iOS application that calculates personalized car insurance pricing by analyzing real driving behavior data (telematics). Built with Swift and SwiftUI, integrated with Damoov Telematics SDK for tracking and analyzing driving patterns.

**Core Concept**: Safe Driving = Lower Premiums

## ✨ Key Features

### 1. Dashboard
- Real-time driving score (0-100)
- Trip statistics (total trips, distance, driving hours)
- Recent trips list
- Driving behavior metrics visualization

### 2. Pricing Lab
- Interactive sliders to adjust driving behavior parameters
  - Harsh braking frequency
  - Speeding events
  - Phone usage rate
  - Night driving ratio
- Real-time premium calculation
- Risk factors visualization

### 3. Tips
- 8 safe driving tips
- 6 premium reduction strategies
- Categorized display (Safety/Cost)

### 4. Onboarding
- SDK initialization setup
- Permission request guidance
- Device token configuration

## 🏗️ Project Architecture

```
WilsonTelematicsInsurance/
│
├── App/                           # Application Entry
│   ├── WilsonTelematicsInsuranceApp.swift
│   └── AppDelegate.swift
│
├── Core/                          # Business Logic
│   ├── Models/                    # Data Models
│   │   ├── Trip.swift            # Trip data
│   │   ├── DriverFeatures.swift   # Driver features
│   │   └── PricingQuote.swift     # Insurance quote
│   │
│   └── Services/                  # Service Layer
│       ├── TelematicsService.swift    # SDK wrapper
│       └── PricingModel.swift         # Pricing engine
│
└── Views/                         # UI Components
    ├── Dashboard/                 # Dashboard screens
    ├── PricingLab/               # Pricing lab
    ├── Tips/                     # Tips screens
    └── Onboarding/               # Onboarding flow
```

## 💻 Tech Stack

- **Language**: Swift 5.5+
- **UI Framework**: SwiftUI
- **Minimum iOS**: 15.0+
- **Package Manager**: Swift Package Manager (SPM)
- **Third-party SDK**: Damoov Telematics SDK 7.0.0+

## 🎯 Pricing Model

**Base Premium**: $1,200/year

**Risk Factor Weights**:
- Speeding: 35%
- Harsh Braking: 30%
- Phone Usage: 20%
- Night Driving: 15%

**Premium Range**: $840 - $2,400/year (based on risk multiplier 0.7x - 2.0x)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main.git
cd WilsonTelematicsInsurance-1.0-main
```

### 2. Open Project
Open `WilsonTelematicsInsurance.xcodeproj` in Xcode

### 3. Install Dependencies
Xcode will automatically install Telematics SDK via SPM

### 4. Configure SDK Token
Set your device token in `OnboardingView.swift` or `AppDelegate.swift`:
```swift
let deviceToken = "YOUR_DEVICE_TOKEN_HERE"
```

Get token: Register at [Damoov DataHub](https://platform.damoov.com/) and create an application

### 5. Run
Select a simulator or physical device, press `⌘R` to run

## 📋 Required Permissions

The app requires the following iOS permissions (already configured in Info.plist):

- **Location** (Always) - For trip tracking
- **Motion & Fitness** - For driving behavior detection
- **Background Modes** - For background trip recording

## 🎨 Design Patterns

- **MVVM Architecture** - Separation of views and business logic
- **Dependency Injection** - Service management via singleton pattern
- **Protocol-Oriented** - Extensible component design
- **Compositional UI** - Reusable SwiftUI components

## 📊 Data Flow

```
User Drives → SDK Collects Data → TelematicsService Processes 
           → DriverFeatures Calculates → PricingModel Prices 
           → UI Displays Results
```

## 🧪 Testing Features

The project includes complete mock data for testing without real trips:
- `Trip.mockTrips()` - Mock trip data
- `DriverFeatures.mock()` - Mock driver features
- `PricingQuote.mock()` - Mock insurance quotes

## 🔮 Future Plans

- [ ] User authentication system
- [ ] Trip detail map view
- [ ] Historical data analytics
- [ ] Social comparison features
- [ ] Smart push notifications
- [ ] AI driving recommendations

## 📄 License

This project is for **educational and demonstration purposes only**. Not for production use.

## 🆘 Support

- **App Issues**: Please ask in GitHub Issues
- **SDK Issues**: Visit [Damoov Documentation](https://docs.damoov.com/)

## 👨‍💻 Author

**Weihan C**
- GitHub: [@WeihanC](https://github.com/WeihanC)

---

⭐ Star this repo if you find it helpful!
