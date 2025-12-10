//
//  WilsonTelematicsInsuranceApp.swift
//  WilsonTelematicsInsurance
//
//  App layer: Main application entry point
//

import SwiftUI

@main
struct WilsonTelematicsInsuranceApp: App {

    // 接入 AppDelegate（负责 Firebase + RPEntry 初始化）
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.user == nil {
                    // 未登录 → 显示登录/注册
                    AuthView()
                        .environmentObject(authVM)
                } else {
                    // 登录后 → 主界面
                    MainTabView()              // ✅ 确保这里用的是 MainTabView
                        .environmentObject(authVM)
                }
            }
        }
    }
}



// MARK: - Main Tab View (你的主 TabBar)

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
                
                // ✅ 第三个 Tab：从 TipsView 改成 AlertView
                AlertView()
                    .tabItem {
                        Label("Alerts", systemImage: "exclamationmark.triangle")
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

    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Dashboard"
        case 1: return "Pricing Lab"
        case 2: return "Driving Alerts"   // ✅ 更新标题
        default: return "Home"
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
