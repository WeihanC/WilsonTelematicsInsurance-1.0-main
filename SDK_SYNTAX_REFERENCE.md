# Telematics SDK - Correct Syntax Reference

## ⚠️ Important: Correct SDK Syntax

The Damoov Telematics SDK uses **`RPEntry.instance`** (property), not `RPEntry.instance()` (method).

## 🔴 CRITICAL: Initialization Order

**You MUST call `RPEntry.initializeSDK()` before accessing `RPEntry.instance`**

```swift
// Step 1: Initialize SDK (in AppDelegate)
RPEntry.initializeSDK()

// Step 2: Now you can access RPEntry.instance
RPEntry.instance.virtualDeviceToken = "YOUR_TOKEN"
RPEntry.instance.setEnableSdk(true)
```

**If you skip `initializeSDK()`, you'll get:**
```
Fatal error: RPEntry has not been initialized. 
Please call RPEntry.initializeSDK() first.
```

## ✅ Correct Usage

### Step 1: AppDelegate Initialization
```swift
import UIKit
import TelematicsSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        // CRITICAL: Call this FIRST before accessing RPEntry.instance
        RPEntry.initializeSDK()
        
        // Optional: Set token here if you have it
        // RPEntry.instance.virtualDeviceToken = "YOUR_TOKEN"
        // RPEntry.instance.setEnableSdk(true)
        
        return true
    }
}
```

### Step 2: Set Device Token (After Login/Onboarding)
```swift
// Now that initializeSDK() was called, you can use instance
RPEntry.instance.virtualDeviceToken = "YOUR_DEVICE_TOKEN"
RPEntry.instance.setEnableSdk(true)
```

### Tracking Control
```swift
// Start tracking
RPEntry.instance.startTracking()

// Stop tracking
RPEntry.instance.stopTracking()

// Check if tracking
let isTracking = RPEntry.instance.isTracking
```

### Permission Checking
```swift
// Check all required permissions
let hasPermissions = RPEntry.instance.isAllRequiredPermissionsGranted()
```

### Lifecycle Management
```swift
// In AppDelegate
func applicationWillEnterForeground(_ application: UIApplication) {
    RPEntry.instance.applicationWillEnterForeground(application)
}

func applicationDidEnterBackground(_ application: UIApplication) {
    RPEntry.instance.applicationDidEnterBackground(application)
}
```

## ❌ Incorrect Usage (Will Cause Errors)

```swift
// DON'T DO THIS - instance is not a method!
RPEntry.instance().virtualDeviceToken = token  // ❌ Error
RPEntry.instance().setEnableSdk(true)          // ❌ Error

// DON'T DO THIS - accessing instance before initializeSDK()
RPEntry.instance.virtualDeviceToken = token    // ❌ Fatal error!
// Must call RPEntry.initializeSDK() first!
```

## 🔧 Full Integration Example

```swift
import TelematicsSDK

// In AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        // Step 1: Initialize SDK
        RPEntry.initializeSDK()
        
        return true
    }
}

// In your service/manager
class TelematicsManager {
    static let shared = TelematicsManager()
    
    func initialize(with token: String) {
        // Step 2: Set device token (initializeSDK() already called in AppDelegate)
        RPEntry.instance.virtualDeviceToken = token
        RPEntry.instance.setEnableSdk(true)
        
        // Step 3: Start tracking
        RPEntry.instance.startTracking()
        
        print("SDK initialized successfully")
    }
    
    func checkStatus() -> Bool {
        return RPEntry.instance.isSDKEnabled && 
               RPEntry.instance.isTracking
    }
    
    func shutdown() {
        RPEntry.instance.stopTracking()
        RPEntry.instance.setEnableSdk(false)
        RPEntry.instance.removeVirtualDeviceToken()
    }
}
```

## 📝 Key Points

1. **Call `RPEntry.initializeSDK()` FIRST** (usually in AppDelegate)
2. **`instance` is a property**, not a method - no parentheses
3. All SDK methods are called **on** the instance property
4. Use `RPEntry.instance.methodName()` pattern
5. The instance is a singleton managed by the SDK

## 🔍 Common Mistakes and Fixes

| ❌ Wrong | ✅ Correct |
|---------|-----------|
| Skip `initializeSDK()` | Call `RPEntry.initializeSDK()` first |
| `RPEntry.instance()` | `RPEntry.instance` |
| `RPEntry.instance().virtualDeviceToken` | `RPEntry.instance.virtualDeviceToken` |
| Access instance before init | Initialize, then access instance |

## 🎯 Quick Reference - Proper Order

```swift
// 1. In AppDelegate.didFinishLaunchingWithOptions
RPEntry.initializeSDK()

// 2. Later (after login/onboarding)
RPEntry.instance.virtualDeviceToken = token
RPEntry.instance.setEnableSdk(true)

// 3. Track
RPEntry.instance.startTracking()
RPEntry.instance.stopTracking()

// 4. Check
RPEntry.instance.isSDKEnabled
RPEntry.instance.isTracking
RPEntry.instance.isAllRequiredPermissionsGranted()

// 5. Lifecycle
RPEntry.instance.applicationWillEnterForeground(app)
RPEntry.instance.applicationDidEnterBackground(app)

// 6. Cleanup
RPEntry.instance.setEnableSdk(false)
RPEntry.instance.removeVirtualDeviceToken()
```

## ✅ All Fixed in Project

All files in the Wilson Telematics Insurance project now use the correct syntax and initialization order:
- ✅ AppDelegate.swift - calls `initializeSDK()` first
- ✅ TelematicsService.swift - accesses instance properly
- ✅ All documentation updated

You can now build and run without SDK initialization errors!
