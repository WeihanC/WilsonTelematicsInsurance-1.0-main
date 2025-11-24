//
//  WilsonTelematicsInsuranceApp.swift
//  WilsonTelematicsInsurance
//
//  App layer: Main application entry point
//

import SwiftUI
import FirebaseCore

@main
struct WilsonTelematicsInsuranceApp: App {

    // 把你写好的 AppDelegate 接入 SwiftUI 生命周期
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        FirebaseApp.configure()
        print("✅ Firebase configured")
    }

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.user == nil {
                    // 没登录 → 显示登录 / 注册界面
                    AuthView()
                        .environmentObject(authVM)
                } else {
                    // 已登录 → 显示你的主界面（里面再做 Onboarding + MainTabView）
                    ContentView()
                        .environmentObject(authVM)
                }
            }
        }
    }
}



// MARK: - Main Tab View (主界面 Tab + 右上角 Sign Out)

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {

                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "gauge")
                    }
                    .tag(0)
                
                PricingLabView()
                    .tabItem {
                        Label("Pricing Lab", systemImage: "dollarsign.circle")
                    }
                    .tag(1)
                
                TipsView()
                    .tabItem {
                        Label("Tips", systemImage: "lightbulb")
                    }
                    .tag(2)
            }
            .navigationTitle(tabTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        authVM.signOut()
                    }
                }
            }
        }
    }

    /// 根据当前 tab 显示标题
    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Dashboard"
        case 1: return "Pricing Lab"
        case 2: return "Driving Tips"
        default: return "Home"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
