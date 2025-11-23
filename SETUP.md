# Wilson Telematics Insurance - Setup Guide

This guide will help you get the project up and running in Xcode with the Telematics SDK properly integrated.

## 📋 Prerequisites

- macOS with Xcode 14.0 or later
- iOS 15.0+ target device or simulator
- Apple Developer account (for running on physical device)
- Damoov DataHub account (optional, for production use)

## 🚀 Quick Start

### Step 1: Open the Project in Xcode

1. Double-click `WilsonTelematicsInsurance.xcodeproj` to open in Xcode
2. Wait for Xcode to index the project

### Step 2: Add Telematics SDK via Swift Package Manager

**IMPORTANT**: This step is required for the project to compile.

1. In Xcode, select **File → Add Package Dependencies...**
2. In the search field (top-right), enter:
   ```
   https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM
   ```
3. Set the dependency rule:
   - **Dependency Rule**: Up to Next Major Version
   - **Version**: 7.0.0
4. Click **Add Package**
5. In the dialog, select the **WilsonTelematicsInsurance** target
6. Click **Add Package** again

**Verification**: In the project navigator, you should see "Package Dependencies" with "telematicsSDK-iOS-new-SPM" listed.

### Step 3: Configure Signing & Capabilities

1. Select **WilsonTelematicsInsurance** project in the navigator
2. Select the **WilsonTelematicsInsurance** target
3. Go to **Signing & Capabilities** tab
4. Under **Signing**, select your **Team**
5. Verify that **Background Modes** capability shows:
   - ✅ Location updates
   - ✅ Background fetch
   - ✅ Remote notifications
   
   If not present, click **+ Capability** and add **Background Modes**, then enable the above options.

### Step 4: Build and Run

1. Select your target device (simulator or physical device)
2. Press **⌘R** or click the **Play** button
3. The app should build and launch

**First Launch**: You'll see the onboarding flow. Complete it to initialize the SDK.

## 🔧 Troubleshooting

### Build Errors Related to TelematicsSDK

**Error**: `No such module 'TelematicsSDK'`

**Solution**: 
1. Make sure you completed Step 2 (Adding the package)
2. Clean the build folder: **Product → Clean Build Folder** (⇧⌘K)
3. Reset package caches: **File → Packages → Reset Package Caches**
4. Rebuild the project

### Permission Errors

If the app crashes on launch related to permissions:

1. Check that `Info.plist` contains all required permission descriptions
2. The file should already have location and motion permissions configured
3. On simulator/device, go to Settings → Privacy and verify permissions

### "Untrusted Developer" on Physical Device

If you see this error when running on a physical device:

1. On your iPhone/iPad, go to **Settings → General → VPN & Device Management**
2. Find your Apple ID under "Developer App"
3. Tap **Trust "[Your Name]"**
4. Run the app again

## 📱 Testing the App

### Using Mock Data

The app is configured to use mock data by default, so you can test all features without real trips:

- **Dashboard**: Shows 3 mock trips with realistic data
- **Pricing Lab**: Interactive sliders to experiment with pricing
- **Tips**: Static list of driving safety tips

### Testing with Real Trips

To test with real telematics data:

1. **Get a Device Token**:
   - Register at [Damoov DataHub](https://platform.damoov.com/)
   - Create a new application
   - Copy your device token

2. **Update the Code**:
   - Open `OnboardingView.swift`
   - Find the line: `let deviceToken = "DEMO_DEVICE_TOKEN_\(UUID().uuidString.prefix(8))"`
   - Replace with: `let deviceToken = "YOUR_ACTUAL_TOKEN"`

3. **Test on Physical Device**:
   - Real trip detection requires a physical device (not simulator)
   - Grant all location permissions (Always)
   - Drive around to generate trips
   - Check the Dashboard for real trip data

## 🏗️ Project Structure

```
WilsonTelematicsInsurance/
├── App/
│   ├── WilsonTelematicsInsuranceApp.swift  # App entry point
│   └── AppDelegate.swift                    # SDK lifecycle
├── Core/
│   ├── Models/
│   │   ├── Trip.swift                       # Trip data model
│   │   ├── DriverFeatures.swift             # Aggregated metrics
│   │   └── PricingQuote.swift               # Insurance quote
│   └── Services/
│       ├── TelematicsService.swift          # SDK wrapper
│       └── PricingModel.swift               # Pricing calculator
├── Features/
│   ├── Dashboard/
│   │   └── DashboardView.swift              # Main dashboard UI
│   ├── PricingLab/
│   │   └── PricingLabView.swift             # Pricing simulator
│   ├── Tips/
│   │   └── TipsView.swift                   # Driving tips
│   └── Onboarding/
│       └── OnboardingView.swift             # Initial setup
├── Assets.xcassets/                         # App assets
└── Info.plist                               # App configuration
```

## 🔐 Key Configuration Files

### Info.plist

Contains all required permissions and background task configurations:

- **Location Permissions**: 3 usage descriptions for different scenarios
- **Motion Permission**: For driving behavior detection
- **Background Modes**: `location`, `fetch`, `remote-notification`
- **BGTask Identifiers**: 
  - `sdk.damoov.apprefreshtaskid`
  - `sdk.damoov.appprocessingtaskid`

### AppDelegate.swift

Manages SDK lifecycle:
- `application(_:didFinishLaunchingWithOptions:)` - SDK initialization
- `applicationWillEnterForeground(_:)` - Foreground transition
- `applicationDidEnterBackground(_:)` - Background transition

### TelematicsService.swift

Wrapper around the Telematics SDK with methods for:
- SDK initialization: `initializeSDK(deviceToken:)`
- Trip management: `fetchTrips()`, `getAllTrips()`
- Tracking control: `startTracking()`, `stopTracking()`

## 📊 Understanding the Pricing Model

The app uses a risk-based pricing model:

### Risk Factors (0-1 scale)
- **Speeding**: Events per trip / 10.0
- **Harsh Braking**: Events per 100km / 5.0
- **Phone Usage**: Direct ratio (0-1)
- **Night Driving**: Direct ratio (0-1)

### Risk Score Calculation (0-100)
Weighted combination:
- Speeding: 35%
- Harsh Braking: 30%
- Phone Usage: 20%
- Night Driving: 15%

### Premium Range
- **Base Premium**: $150/month
- **Minimum Premium**: $95/month (safe driver)
- **Maximum Premium**: $220/month (risky driver)

## 🎯 Next Steps for Production

1. **Authentication**:
   - Implement user registration/login
   - Store device token securely in Keychain
   - Integrate with your backend API

2. **Real SDK Integration**:
   - Replace mock data in `TelematicsService`
   - Implement actual SDK delegate methods
   - Add proper error handling

3. **Enhanced Features**:
   - Trip detail views with maps
   - Historical analytics charts
   - Push notifications for trips
   - Social comparison features

4. **Testing**:
   - Add unit tests for pricing model
   - Add UI tests for critical flows
   - Test on various iOS versions

5. **App Store Preparation**:
   - Add app icons
   - Create launch screen
   - Prepare marketing materials
   - Submit for review

## 📚 Additional Resources

- [Damoov Documentation](https://docs.damoov.com/)
- [Telematics SDK for iOS](https://docs.damoov.com/docs/-download-the-sdk-and-install-it-in-your-environment)
- [DataHub Platform](https://platform.damoov.com/)
- [Demo App Example](https://github.com/Mobile-Telematics/telematicsSDK-demoapp-iOS-swift)

## 🆘 Getting Help

If you encounter issues:

1. Check this guide's Troubleshooting section
2. Review the Damoov documentation
3. Check the demo app on GitHub for examples
4. Contact Damoov support for SDK-specific questions

## 🎉 You're All Set!

Your project is now ready to run. Start experimenting with the Pricing Lab, review the driving tips, and explore the codebase to understand how telematics-based insurance pricing works!

Happy coding! 🚗💨
