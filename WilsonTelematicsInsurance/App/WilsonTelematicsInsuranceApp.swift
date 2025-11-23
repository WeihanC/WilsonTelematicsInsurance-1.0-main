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
                    // 已登录 → 显示你的主界面
                    ContentView()
                        .environmentObject(authVM)
                }
            }
        }
    }
}



// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
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
    }
}

#Preview {
    MainTabView()
}
