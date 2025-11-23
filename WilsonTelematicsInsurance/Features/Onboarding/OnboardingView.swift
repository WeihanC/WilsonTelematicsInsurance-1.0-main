//
//  OnboardingView.swift
//  WilsonTelematicsInsurance
//
//  Features layer: Initial onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool
    @StateObject private var telematicsService = TelematicsService.shared
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPage(
                    icon: "car.fill",
                    title: "Welcome to Wilson Insurance",
                    description: "Get personalized insurance rates based on your actual driving behavior",
                    color: .blue
                )
                .tag(0)
                
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Driving",
                    description: "We automatically detect your trips and analyze your driving patterns safely and securely",
                    color: .green
                )
                .tag(1)
                
                OnboardingPage(
                    icon: "dollarsign.circle.fill",
                    title: "Save on Insurance",
                    description: "Safe drivers can save up to 40% on their monthly premium. The better you drive, the less you pay!",
                    color: .purple
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Action Button
            Button(action: handleAction) {
                Text(currentPage < 2 ? "Next" : "Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
    
    private func handleAction() {
        if currentPage < 2 {
            withAnimation {
                currentPage += 1
            }
        } else {
            // Initialize SDK with a placeholder device token
            // In a real app, this would be obtained from your authentication system
            let deviceToken = "DEMO_DEVICE_TOKEN_\(UUID().uuidString.prefix(8))"
            telematicsService.initializeSDK(deviceToken: deviceToken)
            telematicsService.startTracking()
            
            withAnimation {
                isOnboardingComplete = true
            }
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(color)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
