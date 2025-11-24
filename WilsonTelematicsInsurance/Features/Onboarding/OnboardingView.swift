//
//  OnboardingView.swift
//  WilsonTelematicsInsurance
//

import SwiftUI

struct OnboardingView: View {

    /// Onboarding 是否完成
    @Binding var isOnboardingComplete: Bool

    /// 引用 TelematicsService（包含权限请求）
    @StateObject private var telematicsService = TelematicsService.shared

    /// 当前 Tab（0/1/2）
    @State private var currentPage = 0

    /// 是否显示「权限说明页」
    @State private var showPermissionSheet = false

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {

                OnboardingPage(
                    icon: "car.fill",
                    title: "Welcome to Wilson Insurance",
                    description: "Get personalized insurance rates based on your actual driving behavior.",
                    color: .blue
                )
                .tag(0)

                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Your Driving",
                    description: "We automatically detect your trips and analyze driving patterns safely and securely.",
                    color: .green
                )
                .tag(1)

                OnboardingPage(
                    icon: "dollarsign.circle.fill",
                    title: "Save on Insurance",
                    description: "Safe drivers can save up to 40% on their monthly premium.",
                    color: .purple
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // NEXT / GET STARTED 按钮
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
        .sheet(isPresented: $showPermissionSheet) {
            PermissionExplanationSheet {
                // 用户确认 → 开始请求权限
                telematicsService.requestPermissions()
                telematicsService.startTracking()

                // Onboarding 完成 → 进入主界面
                withAnimation {
                    isOnboardingComplete = true
                }
            }
        }
    }

    /// 按钮逻辑
    private func handleAction() {
        if currentPage < 2 {
            withAnimation { currentPage += 1 }
        } else {
            // 最后一页 → 显示权限说明页（不直接弹系统权限）
            showPermissionSheet = true
        }
    }
}


// MARK: - 权限说明页

struct PermissionExplanationSheet: View {

    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {

            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.top, 32)

            Text("Enable Location & Motion Access")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 12) {

                Text("To record your trips and calculate your personalized insurance prices, please:")
                    .font(.body)

                HStack(alignment: .top) {
                    Text("•")
                    Text("Tap **Allow** when asked to access your **Location**.")
                }

                HStack(alignment: .top) {
                    Text("•")
                    Text("Tap **Allow** when asked to access your **Motion & Fitness Activity**.")
                }

                Text("You can change these anytime in Settings → Privacy.")
                    .padding(.top, 4)
            }
            .font(.subheadline)
            .padding(.horizontal)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Button("Not now") {
                // 如果你希望“Not now”仍然进入主界面：
                // isOnboardingComplete = true
            }
            .foregroundColor(.secondary)
            .padding(.bottom, 24)
        }
    }
}


// MARK: - 单页 UI（不动）

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
                    .bold()
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

