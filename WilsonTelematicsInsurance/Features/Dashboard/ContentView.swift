//
//  ContentView.swift
//  WilsonTelematicsInsurance
//
//  Root view after successful authentication
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authVM: AuthViewModel

    /// 记录是否已经完成 onboarding（存到本地，重新打开 App 也记得）
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                // ✅ Onboarding 结束 → 真正的主界面
                MainTabView()
                    .toolbar {
                        // 简单在右上角给一个 Sign Out
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Sign Out") {
                                authVM.signOut()
                            }
                        }
                    }
            } else {
                // ❗第一次登录 / 还没看完 Onboarding → 展示 Onboarding
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
