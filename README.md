# Wilson Telematics Insurance

<div align="center">

[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-yellow.svg)](https://firebase.google.com/)

**Complete iOS Telematics Car Insurance App - Smart Premium Calculation Based on Real Driving Behavior**

Firebase User Auth | Damoov Telematics SDK | Node.js Backend Integration | Real-time Trip Tracking

</div>

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Core Features](#-core-features)
- [Technical Architecture](#-technical-architecture)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Feature Details](#-feature-details)
- [Technical Implementation](#-technical-implementation)
- [Configuration](#-configuration)
- [Roadmap](#-roadmap)
- [FAQ](#-faq)

---

## 🎯 Project Overview

Wilson Telematics Insurance is a **production-grade** iOS application demonstrating how to use telematics technology to calculate car insurance premiums based on driving behavior. This project is **not a demo or template**, but a fully functional real application.

### Key Highlights

- ✅ **Complete User System** - Firebase Authentication (Register/Login/Logout)
- ✅ **Real Backend Integration** - Node.js API for trips and statistics data
- ✅ **Telematics SDK Integration** - Damoov SDK for automatic driving behavior tracking
- ✅ **Real-time Trip Tracking** - GPS tracking + Speed monitoring + Event detection
- ✅ **Map Visualization** - Display trip routes and driving events on map
- ✅ **Dynamic Pricing Engine** - Premium calculation based on risk factors
- ✅ **Interactive Lab** - Users can simulate premium impact of different driving habits

### Use Cases

- **Insurance Companies**: Implement UBI (Usage-Based Insurance) pricing model
- **Driving Behavior Analysis**: Monitor and improve driving habits
- **Fleet Management**: Enterprise fleet driving behavior monitoring
- **Learning Project**: Understand SwiftUI, Firebase, Telematics SDK integration

---

## ✨ Core Features

### 1. 🔐 User Authentication System

Complete user management using Firebase Authentication:

**Login Screen** (AuthView)
- Email/password login
- Remember login state
- Error handling and user feedback

**Registration**
- Create new user account
- Automatically create Telematics user
- Obtain Damoov virtual device token (deviceToken)
- Initialize SDK and start tracking

**Logout**
- Clear user session
- Stop SDK tracking
- Clear local data

### 2. 📊 Dashboard

Real-time display of user driving data and statistics:

**Driving Score Card** (DrivingScoreCard)
- Comprehensive driving score 0-100
- Color coding based on score (Green=Safe, Red=Risky)
- Large font display, clear at a glance

**Trip Statistics** (TripStatisticsSection)
- Total number of trips
- Total distance (kilometers)
- Total driving hours
- Average speed (km/h)
- Data from backend `/api/daily-stats` endpoint

**Recent Trips List** (RecentTripsSection)
- Display last 3 trips
- Each trip includes:
  - Departure and arrival time
  - Trip distance
  - Trip duration
  - Harsh braking, speeding events
  - Phone usage duration
  - Night driving duration
- Click to view trip details

**View All Trips** (AllTripsView)
- Complete trip history
- Search and filter functionality
- Sort by date

**Data Refresh**
- Manual refresh button
- Asynchronous data fetching
- Loading state display

### 3. 🗺️ Trip Details & Map

**Trip Detail View** (TripDetailView)
- Complete trip information
- Interactive map showing route
- Speed curve chart
- Driving event markers

**Map View** (TripMapView)
- Display trip route using MapKit
- Different colors indicate speed changes
- Mark driving event locations:
  - 🔴 Harsh braking events
  - 🟡 Speeding events
  - 📱 Phone usage
  - 🌙 Night driving
- Zoom and pan functionality

**Speed Analysis**
- Real-time speed curve
- Average speed calculation
- Maximum speed annotation

### 4. 🧪 Pricing Lab

Interactive tool for users to understand how driving behavior affects premiums:

**Adjustable Parameters** (4 sliders)
- **Harsh Braking Rate**: 0-10 events/100km
- **Speeding Events**: 0-15 events/trip
- **Phone Usage Ratio**: 0-50%
- **Night Driving Ratio**: 0-100%

**Real-time Calculation**
- Premium updates instantly with slider adjustments
- Display risk score (0-100)
- Display risk multiplier (0.7x - 2.0x)

**Premium Display**
- Monthly premium: $95 - $220/month
- Comparison with base premium (savings or increase)
- Minimum and maximum premium range

**Risk Factor Breakdown**
- Visualization of each factor's weight
- Bar charts showing risk levels
- Color coding (Green=low risk, Yellow=medium, Red=high)

**Reset Function**
- One-click return to average driver parameters

### 5. 💡 Driving Tips (TipsView)

Personalized safety and savings advice:

**Safe Driving Tips** (8 tips)
- Defensive driving techniques
- Deceleration and braking skills
- Attention focus methods
- Adverse weather driving
- Maintain safe distance
- Regular vehicle maintenance

**Premium Savings Strategies** (6 tips)
- Reduce peak hour driving
- Avoid night driving
- Plan routes in advance
- Reduce phone usage
- Smooth acceleration and braking
- Attend safe driving courses

**User Profile** (ProfileView)
- View personal information
- Driving statistics summary
- Settings and preferences

---

## 🏗️ Technical Architecture

### Architecture Pattern

This project adopts **Clean Architecture** + **MVVM Pattern**:

```
┌─────────────────────────────────────────────────┐
│              App Layer                          │
│  • WilsonTelematicsInsuranceApp.swift           │
│  • AppDelegate.swift (Firebase + SDK Init)      │
│  • PermissionManager.swift                      │
│  • TelematicsAuthManager.swift                  │
└──────────────────┬──────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────┐
│           Features Layer                        │
│  Dashboard/                                     │
│    • DashboardView                              │
│    • AuthView + AuthViewModel                   │
│    • TripDetailView                             │
│    • TripMapView                                │
│  PricingLab/                                    │
│    • PricingLabView                             │
│  Tips/                                          │
│    • TipsView                                   │
│    • ProfileView                                │
│  Onboarding/                                    │
│    • OnboardingView                             │
└──────────────────┬──────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────┐
│             Core Layer                          │
│  Models/                                        │
│    • Trip                                       │
│    • DriverFeatures                             │
│    • PricingQuote                               │
│    • TripsResponse                              │
│    • DailyStatsResponse                         │
│  Services/                                      │
│    • TelematicsService (SDK + API)              │
│    • PricingModel (Pricing Engine)              │
└─────────────────────────────────────────────────┘
```

### Tech Stack

**Frontend**
- **Swift 5.5+** - Programming Language
- **SwiftUI** - UI Framework
- **Combine** - Reactive Programming
- **MapKit** - Map Display
- **CoreLocation** - Location Services

**Backend Integration**
- **Node.js API** - Data Fetching Interface
- **RESTful API** - HTTP Communication
- **JWT Authentication** - Bearer Token

**SDK & Services**
- **Damoov Telematics SDK 7.0+** - Driving Behavior Tracking
- **Firebase Authentication** - User Authentication
- **Firebase Core** - Base Services

**Development Tools**
- **Xcode 14.0+**
- **Swift Package Manager** - Dependency Management
- **iOS 15.0+** - Minimum System Version

---

## 📁 Project Structure

```
WilsonTelematicsInsurance/
├── WilsonTelematicsInsurance.xcodeproj/      # Xcode Project
│
├── WilsonTelematicsInsurance/                # Source Code
│   │
│   ├── App/                                  # App Layer (5 files)
│   │   ├── WilsonTelematicsInsuranceApp.swift    # Main entry + Tab navigation
│   │   ├── AppDelegate.swift                     # Firebase + SDK init
│   │   ├── PermissionManager.swift               # Permission management
│   │   ├── TelematicsAuthManager.swift           # Damoov user management
│   │   └── TripMapView.swift                     # Map component
│   │
│   ├── Core/                                 # Core Business Layer
│   │   ├── Models/                           # Data Models (4 files)
│   │   │   ├── Trip.swift                    # Trip model
│   │   │   ├── DriverFeatures.swift          # Driver features
│   │   │   ├── PricingQuote.swift            # Quote model
│   │   │   └── TripsResponse.swift           # API response
│   │   │
│   │   └── Services/                         # Service Layer (4 files)
│   │       ├── TelematicsService.swift       # SDK + API service
│   │       ├── PricingModel.swift            # Pricing engine
│   │       ├── TripsView.swift               # Trips list
│   │       └── TripDetailView.swift          # Trip details
│   │
│   ├── Features/                             # Feature Modules
│   │   ├── Dashboard/                        # Dashboard (6 files)
│   │   │   ├── DashboardView.swift           # Main dashboard
│   │   │   ├── AuthView.swift                # Login/Register UI
│   │   │   ├── AuthViewModel.swift           # Auth logic
│   │   │   ├── ContentView.swift             # Main content container
│   │   │   ├── TripDetailView.swift          # Trip details
│   │   │   └── TripMapView.swift             # Trip map
│   │   │
│   │   ├── PricingLab/                       # Pricing Lab (1 file)
│   │   │   └── PricingLabView.swift          # Interactive pricing
│   │   │
│   │   ├── Tips/                             # Tips (2 files)
│   │   │   ├── TipsView.swift                # Driving tips
│   │   │   └── ProfileView.swift             # User profile
│   │   │
│   │   ├── Onboarding/                       # Onboarding (1 file)
│   │   │   └── OnboardingView.swift          # First-time guide
│   │   │
│   │   └── data/                             # Data Models (1 file)
│   │       └── DailyStatsResponse.swift      # Daily stats response
│   │
│   ├── Assets.xcassets/                      # Resources
│   │   ├── AppIcon.appiconset/               # App icon
│   │   └── AccentColor.colorset/             # Theme color
│   │
│   ├── Info.plist                            # Configuration
│   └── GoogleService-Info.plist              # Firebase config
│
├── README.md                                 # This file
├── PROJECT_SUMMARY.md                        # Project summary
├── START_HERE.md                             # Quick start
├── ARCHITECTURE.md                           # Architecture docs
├── SETUP.md                                  # Setup guide
├── SDK_INTEGRATION.md                        # SDK integration
└── iOS_COMPATIBILITY.md                      # Compatibility notes

Total: 23 Swift files + 5 documentation files + config files
```

---

## 🚀 Quick Start

### Prerequisites

1. **Development Environment**
   - macOS 12.0+
   - Xcode 14.0+
   - CocoaPods (optional)

2. **Account Preparation**
   - Apple Developer account (for device testing)
   - Firebase project (includes `GoogleService-Info.plist`)
   - Damoov DataHub account

3. **Backend Service**
   - Node.js backend running at `http://192.168.1.33:4000`
   - Or modify `backendBaseURL` in `TelematicsService.swift`

### Installation Steps

#### 1. Clone Project

```bash
git clone https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main.git
cd WilsonTelematicsInsurance-1.0-main
```

#### 2. Open Project

```bash
open WilsonTelematicsInsurance.xcodeproj
```

#### 3. Add Telematics SDK

In Xcode:
1. Select **File → Add Package Dependencies...**
2. Enter package URL:
   ```
   https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM
   ```
3. Version: Select `7.0.0` or higher
4. Target: Select `WilsonTelematicsInsurance`
5. Click **Add Package**

#### 4. Configure Backend Address (if needed)

If your backend is not at `192.168.1.33:4000`, modify:

```swift
// TelematicsService.swift, around line 20
private let backendBaseURL = URL(string: "http://YOUR_IP:YOUR_PORT")!
```

#### 5. Configure Firebase (if needed)

To use your own Firebase project:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Replace the file in project
3. Ensure Bundle ID matches

#### 6. Configure Signing

1. Select project target `WilsonTelematicsInsurance`
2. **Signing & Capabilities**
3. Select your Team
4. Confirm Bundle Identifier

#### 7. Run Application

1. Select simulator or device
2. Press `⌘R` or click Run
3. First run will prompt for permissions, select "Always Allow"

---

## 🎮 Feature Details

### User Registration Flow

1. Open app, see login screen
2. Click "Create Account"
3. Enter email and password
4. System automatically:
   - Creates user in Firebase
   - Calls backend `/api/auth/register` to create Damoov user
   - Obtains virtual device token (deviceToken)
   - Initializes Telematics SDK
   - Starts background tracking
5. Enter main interface (Dashboard)

### Trip Tracking Flow

1. **Automatic Tracking**
   - SDK automatically detects driving behavior in background
   - No manual start/stop required
   - Automatically identifies trip start and end

2. **Data Sync**
   - SDK uploads data to Damoov servers
   - Backend periodically fetches data from Damoov API
   - Frontend gets latest data via refresh button

3. **Data Display**
   - Dashboard shows statistical data
   - Trip list shows detailed information
   - Click trip to view map and details

### Pricing Calculation Logic

**Risk Factor Weights**:
```
Risk Score = Speeding(35%) + Harsh Braking(30%) + Phone Usage(20%) + Night Driving(15%)
```

**Premium Calculation**:
```
Base Premium = $150/month
Risk Multiplier = 0.7 + (Risk Score / 100) × 1.3
Final Premium = Base Premium × Risk Multiplier

Premium Range: $95/month (safe driver) to $220/month (high-risk driver)
```

**Examples**:
- Safe driver (score 90): $150 × 0.87 = **$130/month**
- Average driver (score 75): $150 × 1.075 = **$161/month**
- High-risk driver (score 40): $150 × 1.22 = **$183/month**

---

## 🔧 Technical Implementation

### Firebase Authentication Integration

```swift
// AppDelegate.swift
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [...]) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()
    
    // Initialize Telematics SDK
    RPEntry.instance.application(application, 
                                didFinishLaunchingWithOptions: launchOptions)
    
    return true
}
```

### Telematics SDK Configuration

```swift
// TelematicsService.swift
func configure(with credentials: TelematicsCredentials) {
    // 1. Set virtual device token
    RPEntry.instance.virtualDeviceToken = credentials.deviceToken
    
    // 2. Enable SDK
    RPEntry.instance.setEnableSdk(true)
    
    // 3. Enable automatic tracking
    RPEntry.instance.disableTracking = false
    
    print("✅ SDK configured, deviceToken: \(credentials.deviceToken)")
}
```

### API Data Fetching

```swift
// TelematicsService.swift
func fetchTrips() async throws -> [Trip] {
    guard let credentials = credentials else {
        return []
    }
    
    // Build request
    let url = backendBaseURL.appendingPathComponent("/api/trips")
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(credentials.jwt)", 
                    forHTTPHeaderField: "Authorization")
    
    // Send request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Parse response
    let decoded = try JSONDecoder().decode(TripsResponse.self, from: data)
    trips = decoded.trips
    
    return trips
}
```

### Map Display Implementation

```swift
// TripMapView.swift
Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
    MapAnnotation(coordinate: annotation.coordinate) {
        // Show different icons based on event type
        Image(systemName: annotation.iconName)
            .foregroundColor(annotation.color)
            .font(.title)
    }
}
.overlay(
    // Draw route
    MapPolyline(coordinates: coordinates)
        .stroke(Color.blue, lineWidth: 3)
)
```

---

## ⚙️ Configuration

### Info.plist Permissions

Project has all required permissions configured:

```xml
<!-- Location Permissions -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need continuous access to your location to track driving behavior</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>Location access needed even when app is in background to record trips</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Your location is needed when using the app</string>

<!-- Motion Permission -->
<key>NSMotionUsageDescription</key>
<string>Motion sensor access needed to detect driving behavior</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>fetch</string>
    <string>remote-notification</string>
</array>

<!-- Background Task Identifiers -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>sdk.damoov.apprefreshtaskid</string>
    <string>sdk.damoov.appprocessingtaskid</string>
</array>
```

### Backend API Endpoints

Project requires the following API endpoints:

1. **User Authentication**
   - `POST /api/auth/register` - Register new user
   - `POST /api/auth/login` - User login

2. **Trip Data**
   - `GET /api/trips` - Get user trip list
   - `GET /api/trips/:id` - Get single trip details
   - `GET /api/trips/:id/route` - Get trip route coordinates

3. **Statistics Data**
   - `GET /api/daily-stats` - Get daily statistics

All protected endpoints require JWT Bearer Token.

---

## 🔮 Roadmap

### Phase 1: Core Features (Completed ✅)

- [x] Firebase user authentication
- [x] Damoov SDK integration
- [x] Backend API connection
- [x] Dashboard interface
- [x] Trip list and details
- [x] Map visualization
- [x] Pricing Lab
- [x] Driving tips

### Phase 2: Feature Enhancement (Planned)

- [ ] Push Notifications
  - Trip end reminder
  - Driving score notification
  - Premium change alert

- [ ] Data Persistence
  - Core Data integration
  - Offline data caching
  - Historical data query

- [ ] Advanced Analytics
  - Driving trend charts
  - Monthly/yearly reports
  - Compare with other users

### Phase 3: User Experience Optimization

- [ ] Custom themes
- [ ] Dark mode optimization
- [ ] Animations and transitions
- [ ] Haptic feedback
- [ ] Localization support (multi-language)

### Phase 4: Social & Gamification

- [ ] Achievement System
  - Safe driving badges
  - Milestone rewards
  - Consecutive safe driving days

- [ ] Leaderboards
  - Friend comparison
  - Global rankings
  - Regional rankings

- [ ] Challenge System
  - Daily challenges
  - Weekly goals
  - Special events

### Phase 5: Advanced Features

- [ ] Apple Watch App
  - Quick trip view
  - Driving reminders
  - Quick score check

- [ ] Siri Shortcuts
  - Voice trip query
  - Quick score check

- [ ] CarPlay Support
  - In-car display
  - Real-time feedback

### Phase 6: Commercialization

- [ ] Insurance Company Integration
  - API interface
  - Data export
  - Quote generation

- [ ] Payment Integration
  - Apple Pay
  - Subscription management
  - Premium payment

---

## ❓ FAQ

### Q1: Why don't I see any trips?

**A:** Possible reasons:
1. SDK hasn't tracked trips yet (need actual driving)
2. Permissions not correctly granted (check "Always Allow" location permission)
3. Backend not returning data (check network connection and backend status)
4. Need to click "Refresh Data" button to manually refresh

### Q2: How to test on simulator?

**A:** 
- Simulator **cannot** actually track driving behavior
- Recommend using **physical device** for testing
- Can modify backend to return mock data for UI testing

### Q3: How to modify backend address?

**A:** 
Edit line 20 in `TelematicsService.swift`:
```swift
private let backendBaseURL = URL(string: "http://YOUR_IP:PORT")!
```

### Q4: How to get Damoov Device Token?

**A:** 
1. Visit [Damoov DataHub](https://platform.damoov.com/)
2. Create account and login
3. Create new application
4. Get Client ID and Client Secret
5. Call Damoov API through backend to create virtual device

### Q5: Firebase configuration error?

**A:**
1. Confirm `GoogleService-Info.plist` is in project
2. Check Bundle ID matches
3. Verify iOS app configuration in Firebase Console
4. Clean project (⌘⇧K) and rebuild

### Q6: SDK not initialized error

**A:**
Ensure:
1. `AppDelegate` calls `RPEntry.instance.application(...)`
2. User is logged in and has deviceToken
3. Called `TelematicsService.shared.configure(with: credentials)`

### Q7: Map doesn't show route

**A:**
Check:
1. Trip has GPS coordinate data
2. Backend returns `route` data
3. Location permission is correctly granted

### Q8: Build error "No such module 'TelematicsSDK'"

**A:**
1. Confirm SDK added via SPM
2. Clean Build Folder (⌘⇧K)
3. Restart Xcode
4. Check Swift Package Dependencies

---

## 📄 License

This project is for **educational and demonstration purposes only**.

### Important Notes

- ❌ Not for production use (without permission)
- ❌ Pricing model is for demonstration, not real insurance calculation
- ✅ Can be used for iOS development learning
- ✅ Can be used for Telematics technology research

### Third-Party Licenses

- **Damoov Telematics SDK** - Subject to Damoov license terms
- **Firebase** - Subject to Google Terms of Service

---

## 🙏 Acknowledgments

- **Damoov** - Excellent Telematics SDK
- **Firebase** - User authentication and backend services
- **Apple** - SwiftUI and MapKit frameworks
- **Swift Community** - Open source contributions and support

---

## 📞 Support

### Documentation

- 📖 [Damoov Documentation](https://docs.damoov.com/)
- 📖 [Firebase Documentation](https://firebase.google.com/docs)
- 📖 [Apple Developer](https://developer.apple.com/documentation/)

### Contact

- **GitHub**: [@WeihanC](https://github.com/WeihanC)
- **Project Repository**: [WilsonTelematicsInsurance](https://github.com/WeihanC/WilsonTelematicsInsurance-1.0-main)

---

<div align="center">

**Built with Swift, SwiftUI and ❤️**

⭐ Star this repo if you find it helpful!

**Version 1.0** - November 2025

</div>
