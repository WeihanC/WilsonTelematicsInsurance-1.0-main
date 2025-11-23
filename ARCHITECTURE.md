# Wilson Telematics Insurance - Architecture Overview

## 🏛️ Architectural Principles

This project follows **Clean Architecture** principles with clear separation of concerns:

1. **Dependency Rule**: Dependencies point inward (App → Features → Core)
2. **Single Responsibility**: Each module has one clear purpose
3. **Testability**: Business logic isolated from UI
4. **Extensibility**: Easy to add new features or swap implementations

## 📐 Layer Structure

```
┌─────────────────────────────────────────────────────┐
│                    App Layer                        │
│  • Entry Point (@main)                             │
│  • Navigation (TabView)                            │
│  • Lifecycle (AppDelegate)                         │
└──────────────────┬──────────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────────┐
│                 Features Layer                      │
│  • UI Components (SwiftUI Views)                   │
│  • User Interactions                               │
│  • Presentation Logic                              │
└──────────────────┬──────────────────────────────────┘
                   │ depends on
┌──────────────────▼──────────────────────────────────┐
│                  Core Layer                         │
│  • Domain Models (Trip, DriverFeatures, etc.)     │
│  • Business Logic (PricingModel)                   │
│  • External SDK Wrapper (TelematicsService)       │
└─────────────────────────────────────────────────────┘
```

## 🎯 Core Layer

### Models
Domain entities representing business concepts:

**Trip**
- Represents a single driving trip
- Contains start/end times, distance, duration
- Includes driving behavior metrics (harsh events, speeding, etc.)
- Provides computed properties for easy consumption
- Includes mock data factory methods for testing

**DriverFeatures**
- Aggregates multiple trips into driver profile
- Calculates normalized metrics (per 100km, ratios)
- Provides driving score calculation
- Can be initialized from Trip array
- Contains both safe and risky driver mock profiles

**PricingQuote**
- Insurance pricing information
- Risk assessment breakdown
- Premium calculation with min/max bounds
- Discount/savings information
- Risk level categorization (low, moderate, high, very high)

### Services

**TelematicsService**
- Singleton service (`shared`)
- Wraps Telematics SDK functionality
- Manages SDK lifecycle (init, enable, disable)
- Provides trip fetching and filtering
- Handles tracking start/stop
- Observable with `@Published` properties
- Includes TODO markers for real SDK integration

**PricingModel**
- Singleton service (`shared`)
- Calculates insurance quotes from driving data
- Configurable premium range ($95-$220)
- Weighted risk factor calculation (35%, 30%, 20%, 15%)
- Supports both real and custom parameter quotes
- Pure business logic - no UI dependencies

## 🎨 Features Layer

### Dashboard
**DashboardView**
- Main overview of driving performance
- Displays driving score (0-100)
- Shows trip statistics grid
- Lists recent trips with behavior highlights
- Refresh functionality for data updates
- Composed of smaller reusable components

**Sub-components:**
- `DrivingScoreCard`: Large score display with color coding
- `TripStatisticsSection`: Grid of key metrics
- `StatCard`: Individual metric card
- `RecentTripsSection`: Trip list container
- `TripRow`: Single trip display with icons

### Pricing Lab
**PricingLabView**
- Interactive insurance pricing simulator
- Real-time quote calculation
- Four adjustable parameters with sliders
- Visual risk factor breakdown
- Reset to average driver functionality

**Sub-components:**
- `QuoteDisplayCard`: Premium display with breakdown
- `RiskFactorBar`: Individual risk factor visualization
- `ParameterSlider`: Reusable slider with label and icon

**Parameters:**
- Harsh braking rate (0-10 per 100km)
- Speeding events (0-15 per trip)
- Phone usage (0-50% of driving time)
- Night driving (0-100% of trips)

### Tips
**TipsView**
- List-based educational content
- Two categories: Safety and Premium Reduction
- 8 driving safety tips
- 6 premium reduction strategies

**Sub-components:**
- `TipRow`: Individual tip display
- `Tip` protocol: Extensible tip system
- `DrivingTip`: Safety-focused tips
- `PremiumTip`: Cost-saving tips

### Onboarding
**OnboardingView**
- Initial user experience
- Three-page introduction
- SDK initialization flow
- Binding to app state for completion

**Sub-components:**
- `OnboardingPage`: Single onboarding page
- Page indicator (built-in TabView)
- Action button (Next/Get Started)

## 🚀 App Layer

### WilsonTelematicsInsuranceApp
- SwiftUI `@main` entry point
- Conditional view based on onboarding state
- `@AppStorage` for persistent onboarding flag
- `@UIApplicationDelegateAdaptor` for lifecycle

**MainTabView**
- Tab-based navigation
- Three tabs: Dashboard, Pricing Lab, Tips
- Selected tab state management

### AppDelegate
- UIKit lifecycle bridge
- SDK lifecycle management
- Foreground/background transitions
- Placeholder for early SDK initialization

## 🔄 Data Flow

### Read Flow (Display Data)
```
User → View → Service.getAllTrips()
            → DriverFeatures(from: trips)
            → Display in UI
```

### Write Flow (User Interaction)
```
User → Slider Change → calculateCustomQuote()
                     → PricingModel.calculateCustomQuote()
                     → Update @State
                     → View Re-renders
```

### Async Flow (Fetch Data)
```
User → Refresh Button → async fetchTrips()
                      → TelematicsService.fetchTrips()
                      → (SDK call would happen here)
                      → Update @Published trips
                      → View Re-renders automatically
```

## 🎨 Design Patterns

### Observable Objects
- `TelematicsService` is an `ObservableObject`
- Views observe changes via `@StateObject` or `@ObservedObject`
- `@Published` properties trigger automatic UI updates

### Singleton Pattern
- `TelematicsService.shared`
- `PricingModel.shared`
- Single source of truth
- Easy access throughout app

### Protocol-Oriented Design
- `Tip` protocol enables extensibility
- Easy to add new tip types
- Shared rendering logic via `TipRow`

### Factory Pattern
- Mock data factory methods
- `Trip.mockTrips()`, `DriverFeatures.mock()`, etc.
- Consistent test data generation

### Composition
- Small, focused components
- Reusable building blocks
- Easy to test and maintain

### Dependency Injection
- Services passed to views (implicitly via `.shared`)
- Could easily be made explicit for testing
- No tight coupling to concrete implementations

## 🧪 Testing Strategy

### Unit Tests (Recommended)
```swift
// PricingModel tests
func testSafeDriverGetDiscount()
func testRiskyDriverPayMore()
func testPremiumNeverExceedsMaximum()

// DriverFeatures tests
func testDrivingScoreCalculation()
func testHarshEventRateCalculation()

// Trip tests
func testTripDurationCalculation()
func testNightTripDetection()
```

### Integration Tests
```swift
// TelematicsService + PricingModel
func testEndToEndQuoteGeneration()

// View + Service
func testDashboardDataFlow()
```

### UI Tests
```swift
// Critical user flows
func testOnboardingFlow()
func testPricingLabInteraction()
func testTabNavigation()
```

## 🔐 Security Considerations

### Current Implementation
- Demo device token (not secure for production)
- No authentication system
- No sensitive data storage

### Production Recommendations
1. **Authentication**:
   - User login/registration
   - Secure token storage (Keychain)
   - Token refresh mechanism

2. **Data Protection**:
   - Encrypt sensitive trip data
   - Secure API communication (HTTPS)
   - Privacy-compliant data handling

3. **Permissions**:
   - Request permissions at appropriate times
   - Explain permission needs to users
   - Handle permission denials gracefully

## 🚀 Scalability Considerations

### Current Limitations
- All data in memory (no persistence)
- Mock data only
- Single user (no multi-tenancy)

### Production Enhancements
1. **Data Persistence**:
   - Core Data or Realm for local storage
   - Background sync with backend
   - Offline support

2. **Backend Integration**:
   - RESTful API or GraphQL
   - User authentication service
   - Quote generation service
   - Analytics and reporting

3. **Performance**:
   - Pagination for large trip lists
   - Background processing for calculations
   - Image and asset optimization
   - Network request caching

## 📊 Metrics & Analytics

### Recommended Tracking
1. **User Behavior**:
   - Screen views and time spent
   - Feature usage (Lab interactions)
   - Onboarding completion rate

2. **Business Metrics**:
   - Average driving score
   - Quote generation frequency
   - Premium distribution

3. **Technical Metrics**:
   - App crashes and errors
   - SDK initialization success rate
   - Trip detection accuracy

## 🎯 Extension Points

### Easy to Add
1. **New Views**: Follow existing pattern in Features layer
2. **New Models**: Add to Core/Models
3. **New Services**: Add to Core/Services
4. **New Tips**: Implement `Tip` protocol

### Requires More Work
1. **Real SDK Integration**: Update TelematicsService
2. **Backend API**: Add networking layer
3. **User Auth**: Add authentication module
4. **Data Persistence**: Add storage layer

## 📝 Code Quality

### Strengths
✅ Clear separation of concerns
✅ Consistent naming conventions
✅ Comprehensive comments
✅ Mock data for testing
✅ Type-safe Swift code
✅ SwiftUI best practices
✅ Reactive programming with Combine

### Areas for Enhancement
🔸 Add comprehensive unit tests
🔸 Implement error handling throughout
🔸 Add logging infrastructure
🔸 Document complex algorithms
🔸 Add input validation
🔸 Implement accessibility features

## 🎓 Learning Resources

To understand this architecture better, study:
1. **Clean Architecture** (Robert C. Martin)
2. **SwiftUI Data Flow** (Apple Documentation)
3. **Combine Framework** (Apple Documentation)
4. **iOS App Architecture** (objc.io)
5. **Design Patterns in Swift** (Ray Wenderlich)

This architecture provides a solid foundation for a production telematics insurance app while remaining simple enough for learning and experimentation.
