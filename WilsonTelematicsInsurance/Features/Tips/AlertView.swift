//
//  AlertView.swift
//  WilsonTelematicsInsurance
//
//  Created by WIlson's macbook on 12/10/25.
//


import SwiftUI

struct AlertView: View {
    @ObservedObject var manager = DrivingAlertManager.shared

    @State private var showingPopup = false
    @State private var popupAlert: DrivingAlert?

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                // 顶部风险卡片
                riskHeader

                // 调试按钮（不用开车也能测试一次严重提醒）
                Button("测试严重提醒") {
                    DrivingAlertManager.shared.debugTriggerSevereEvent()
                }
                .buttonStyle(.borderedProminent)

                // 下方列表
                if manager.alerts.isEmpty {
                    Spacer()
                    Text("当前没有驾驶提醒。")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    List(manager.alerts) { alert in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Circle()
                                    .fill(alert.level.color)
                                    .frame(width: 10, height: 10)
                                Text(alert.title)
                                    .font(.headline)
                                Spacer()
                                Text(timeString(alert.time))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text(alert.message)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .padding()

            // 顶部实时弹出条（3 秒消失）
            if showingPopup, let popup = popupAlert {
                VStack {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(popup.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text(popup.message)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(popup.level.color)
                    .cornerRadius(14)
                    .shadow(radius: 8)
                    .padding(.top, 8)
                    .padding(.horizontal)

                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(), value: showingPopup)
            }
        }
        // 监听 activeAlert，一旦有新的就弹 popup
        .onChange(of: manager.activeAlert) { newValue in
            guard let alert = newValue else { return }
            popupAlert = alert
            showingPopup = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if popupAlert?.id == alert.id {
                    showingPopup = false
                }
            }
        }
        .navigationTitle("Alert")
    }

    private var riskHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("当前风险等级")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(manager.currentRiskLevel.displayText)
                    .font(.title2.bold())
                    .foregroundColor(manager.currentRiskLevel.color)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(manager.currentRiskLevel.color.opacity(0.12))
        )
    }

    private func timeString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f.string(from: date)
    }
}
