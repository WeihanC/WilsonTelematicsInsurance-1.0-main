# Telematics SDK Integration Reference

This guide provides specific information about integrating the Damoov Mobile Telematics SDK in this project.

## 📦 Package Information

**Package URL**: `https://github.com/Mobile-Telematics/telematicsSDK-iOS-new-SPM`
**Minimum Version**: 7.0.0
**Package Name**: `TelematicsSDK`
**Import Statement**: `import TelematicsSDK`

## 🔧 Current Integration Status

### ✅ Completed
- [x] Info.plist configured with all required permissions
- [x] Background modes enabled
- [x] Background task identifiers configured
- [x] AppDelegate lifecycle hooks in place
- [x] TelematicsService wrapper created
- [x] SDK initialization flow designed
- [x] Mock data for development

### ⏳ To Be Implemented
- [ ] Add SDK package via SPM in Xcode
- [ ] Replace demo device token with real token
- [ ] Implement real SDK method calls
- [ ] Add SDK delegate implementations
- [ ] Handle SDK errors and edge cases
- [ ] Test with real driving data

## 🚀 SDK Initialization Flow

### ⚠️ CRITICAL: Call initializeSDK() First

Before accessing `RPEntry.instance`, you MUST call `RPEntry.initializeSDK()` in AppDelegate:

```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
) -> Bool {
    // CRITICAL: Initialize SDK first
    RPEntry.initializeSDK()
    return true
}
```

**Skipping this step will cause a fatal error:**
```
Fatal error: RPEntry has not been initialized.
Please call RPEntry.initializeSDK() first.
```

### Step 1: App Launch (AppDelegate)
```swift
func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
) -> Bool {
    // Optional: Early SDK setup
    // Typically done after user login
    return true
}
```

### Step 2: User Onboarding (OnboardingView)
```swift
// Get device token from your auth system
let deviceToken = "YOUR_DEVICE_TOKEN_FROM_BACKEND"

// Initialize SDK
telematicsService.initializeSDK(deviceToken: deviceToken)
telematicsService.startTracking()
```

### Step 3: SDK Setup (TelematicsService)
```swift
func initializeSDK(deviceToken: String) {
    RPEntry.instance.virtualDeviceToken = deviceToken
    RPEntry.instance.setEnableSdk(true)
    self.isSDKEnabled = true
}
```

## 📝 Required Info.plist Keys

All of these are already configured in the project:

```xml
<!-- Location Permissions -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need access to your location to track driving behavior...</string>

<key>NSLocationAlwaysUsageDescription</key>
<string>We need continuous location access to automatically detect...</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access to track your driving behavior...</string>

<!-- Motion Permission -->
<key>NSMotionUsageDescription</key>
<string>We need access to motion sensors to detect driving events...</string>

<!-- Background Modes -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
    <string>remote-notification</string>
</array>

<!-- Background Task Identifiers -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>sdk.damoov.apprefreshtaskid</string>
    <string>sdk.damoov.appprocessingtaskid</string>
</array>
```

## 🎯 Key SDK Methods to Implement

### Trip Management

```swift
// Fetch all trips (IMPLEMENT)
func fetchTrips() async throws -> [Trip] {
    // TODO: Call SDK method to get trips
    // Example:
    // let sdkTrips = await RPEntry.instance.getTrips()
    // return sdkTrips.map { convertToTrip($0) }
    
    // Currently returns mock data
    return Trip.mockTrips()
}

// Get trip details (IMPLEMENT)
func getTripDetails(tripId: String) async throws -> Trip? {
    // TODO: Fetch specific trip from SDK
    return nil
}

// Delete trip (IMPLEMENT)
func deleteTrip(tripId: String) async throws {
    // TODO: Call SDK delete method
}
```

### Tracking Control

```swift
// Start automatic tracking (IMPLEMENT)
func startTracking() {
    // TODO: Uncomment when SDK is added
    // RPEntry.instance.startTracking()
    self.isTracking = true
}

// Stop tracking (IMPLEMENT)
func stopTracking() {
    // TODO: Uncomment when SDK is added
    // RPEntry.instance.stopTracking()
    self.isTracking = false
}

// Check if tracking is active (IMPLEMENT)
func isTrackingActive() -> Bool {
    // TODO: Return actual SDK status
    // return RPEntry.instance.isTracking
    return isTracking
}
```

### Permission Management

```swift
// Check permissions (IMPLEMENT)
func checkPermissions() -> Bool {
    // TODO: Uncomment when SDK is added
    // return RPEntry.instance.isAllRequiredPermissionsGranted()
    return true
}

// Request permissions (IMPLEMENT)
func requestPermissions() {
    // TODO: Implement proper permission flow
    // May need to use CLLocationManager directly
}
```

### Lifecycle Management

```swift
// Foreground transition (ALREADY HOOKED UP)
func applicationWillEnterForeground() {
    guard isSDKEnabled else { return }
    // RPEntry.instance.applicationWillEnterForeground(UIApplication.shared)
}

// Background transition (ALREADY HOOKED UP)
func applicationDidEnterBackground() {
    guard isSDKEnabled else { return }
    // RPEntry.instance.applicationDidEnterBackground(UIApplication.shared)
}
```

## 🔄 Data Conversion

You'll need to convert SDK trip objects to your Trip model:

```swift
// Example conversion function (IMPLEMENT)
private func convertSDKTripToTrip(_ sdkTrip: Any) -> Trip {
    // TODO: Map SDK trip properties to Trip struct
    // This depends on the SDK's trip object structure
    
    /*
    Example:
    return Trip(
        id: sdkTrip.id,
        startDate: sdkTrip.startDate,
        endDate: sdkTrip.endDate,
        distance: sdkTrip.distanceKm,
        duration: sdkTrip.duration,
        // ... map all other properties
    )
    */
    
    fatalError("Not implemented")
}
```

## 🔐 Getting a Device Token

### Development/Testing
For development, you can use a demo token (current implementation):
```swift
let deviceToken = "DEMO_DEVICE_TOKEN_\(UUID().uuidString.prefix(8))"
```

### Production Setup

1. **Register at DataHub**:
   - Go to https://platform.damoov.com/
   - Create an account
   - Create a new application

2. **Get API Credentials**:
   - Instance ID
   - Instance Key
   - These are used for backend API integration

3. **Generate Device Tokens**:
   - Device tokens should be generated by your backend
   - Each user gets a unique device token
   - Token should be securely stored in iOS Keychain

4. **Integration Flow**:
   ```
   User → Your App (Login)
          ↓
   Your Backend (Authenticate)
          ↓
   Damoov API (Create Device Token)
          ↓
   Your Backend (Return Token)
          ↓
   Your App (Store in Keychain)
          ↓
   Initialize SDK with Token
   ```

## 🐛 Common Issues & Solutions

### Issue: SDK Not Tracking
**Symptoms**: No trips appear even after driving
**Solutions**:
1. Check location permission (must be "Always")
2. Verify SDK is enabled: `RPEntry.instance.isSDKEnabled`
3. Check device token is valid
4. Ensure background modes are enabled in Xcode
5. Test on physical device (simulator limited)

### Issue: Trips Not Uploading
**Symptoms**: Trips recorded but not syncing
**Solutions**:
1. Check network connectivity
2. Verify device token hasn't expired
3. Check background app refresh is enabled
4. Review SDK logs for errors

### Issue: High Battery Usage
**Symptoms**: App draining battery quickly
**Solutions**:
1. Ensure proper lifecycle management
2. Verify background modes are correctly configured
3. Consider adjusting tracking sensitivity
4. Use SDK's battery optimization features

### Issue: Permissions Denied
**Symptoms**: User denied location access
**Solutions**:
1. Provide clear explanation of why permission is needed
2. Direct user to Settings to change permission
3. Handle gracefully in UI
4. Consider offering "manual trip mode"

## 📚 SDK Documentation Links

- **Main Docs**: https://docs.damoov.com/
- **iOS SDK Guide**: https://docs.damoov.com/docs/-download-the-sdk-and-install-it-in-your-environment
- **DataHub Platform**: https://platform.damoov.com/
- **Demo App**: https://github.com/Mobile-Telematics/telematicsSDK-demoapp-iOS-swift
- **Changelog**: https://docs.damoov.com/changelog/sdk-for-ios
- **API Reference**: https://docs.damoov.com/reference

## 🎓 Implementation Checklist

Use this checklist when implementing real SDK integration:

### Phase 1: Basic Setup
- [ ] Add SDK package in Xcode
- [ ] Verify all imports work
- [ ] Build project successfully
- [ ] Test on simulator

### Phase 2: Authentication
- [ ] Implement user login flow
- [ ] Connect to your backend for token generation
- [ ] Store token securely in Keychain
- [ ] Handle token refresh if needed

### Phase 3: SDK Integration
- [ ] Replace demo token with real token
- [ ] Implement `initializeSDK` properly
- [ ] Add proper error handling
- [ ] Implement SDK delegates if needed

### Phase 4: Trip Management
- [ ] Implement `fetchTrips()` with real SDK call
- [ ] Add trip conversion logic
- [ ] Test trip data structure
- [ ] Verify all trip properties map correctly

### Phase 5: Tracking
- [ ] Implement tracking start/stop
- [ ] Test automatic trip detection
- [ ] Verify background tracking
- [ ] Check battery usage

### Phase 6: Permissions
- [ ] Implement permission checking
- [ ] Add permission request UI
- [ ] Handle permission denials
- [ ] Add settings deep link

### Phase 7: Testing
- [ ] Test on physical device
- [ ] Test various trip scenarios
- [ ] Test background modes
- [ ] Test app state transitions
- [ ] Test permission flows

### Phase 8: Production
- [ ] Production device tokens
- [ ] Error tracking/logging
- [ ] Analytics integration
- [ ] App Store submission

## 💡 Best Practices

1. **Always Check SDK Enabled**:
   ```swift
   guard telematicsService.isSDKEnabled else { return }
   ```

2. **Handle Async Properly**:
   ```swift
   Task {
       do {
           let trips = try await telematicsService.fetchTrips()
           // Process trips
       } catch {
           // Handle error
       }
   }
   ```

3. **Lifecycle Management**:
   - Always call lifecycle methods
   - Don't initialize SDK on every launch
   - Clean up properly on logout

4. **Error Handling**:
   - Wrap SDK calls in try-catch
   - Provide user feedback
   - Log errors for debugging

5. **Testing**:
   - Use mock data for UI testing
   - Test with real data on device
   - Test all permission states
   - Test offline scenarios

## 🔗 Next Steps

1. Follow SETUP.md to add the SDK package
2. Get a device token from DataHub
3. Replace demo token in OnboardingView
4. Uncomment SDK method calls in TelematicsService
5. Implement conversion functions
6. Test on physical device
7. Iterate and refine

Good luck with your integration! 🚀
