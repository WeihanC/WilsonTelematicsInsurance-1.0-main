//
//  AuthViewModel.swift
//  WilsonTelematicsInsurance
//
//  负责：Firebase Email/Password 登录 / 注册
//       + 为每个用户在 Firebase Realtime Database 里绑定自己的 Telematics 账号
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import LoginAuth

final class AuthViewModel: ObservableObject {

    @Published var telematicsDeviceToken: String?
    @Published var user: User?          // 当前登录的 Firebase 用户
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        // App 启动时如果已经登录，可以尝试恢复这个 uid 的 telematics 凭证
        if let current = Auth.auth().currentUser {
            self.user = current
            restoreTelematicsForCurrentUser()
        }
    }

    // MARK: - 注册：Firebase + 新建 telematics 用户 + 写入 Realtime Database

    func signUp(email: String, password: String) {
        errorMessage = nil
        isLoading = true

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let firebaseUser = result?.user else {
                    self.errorMessage = "Failed to create Firebase user."
                    return
                }

                self.user = firebaseUser
                let uid = firebaseUser.uid

                // ✅ 第一次为这个 Firebase 用户创建 Damoov Telematics 用户
                TelematicsAuthManager.shared.createTelematicsUser(
                    email: email,
                    clientId: uid
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let creds):
                            print("✅ Telematics user created for uid \(uid). DeviceToken = \(creds.deviceToken)")
                            self.telematicsDeviceToken = creds.deviceToken

                            // 写入 Realtime Database：/users/<uid>/telematics
                            self.saveTelematicsToRealtimeDB(uid: uid,
                                                            email: email,
                                                            creds: creds)

                            // 初始化 SDK，让这个用户开始可追踪
                            Task { @MainActor in
                                TelematicsService.shared.configure(with: creds)
                            }

                        case .failure(let error):
                            print("❌ Failed to create telematics user:", error)
                            self.errorMessage = "Telematics user error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }

    // MARK: - 登录：按 Firebase UID 从 Realtime DB 恢复 telematics 身份

    func signIn(email: String, password: String) {
        errorMessage = nil
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let firebaseUser = result?.user else { return }
                self.user = firebaseUser
                let uid = firebaseUser.uid

                // 1️⃣ 从 Realtime Database 读取 /users/<uid>/telematics
                self.loadTelematicsFromRealtimeDB(uid: uid) { creds in
                    if let creds = creds {
                        print("🌐 Loaded telematics from Firebase for uid \(uid). DeviceToken = \(creds.deviceToken)")
                        self.telematicsDeviceToken = creds.deviceToken

                        // 2️⃣ 可选：刷新 JWT（防止过期），刷新成功后更新 Firebase
                        TelematicsAuthManager.shared.refreshJwt(forDeviceToken: creds.deviceToken) { refreshResult in
                            DispatchQueue.main.async {
                                switch refreshResult {
                                case .success(let freshCreds):
                                    print("🔄 Using refreshed JWT for uid \(uid)")
                                    self.telematicsDeviceToken = freshCreds.deviceToken

                                    // 更新 DB 里的 jwt / refreshToken
                                    self.saveTelematicsToRealtimeDB(uid: uid,
                                                                    email: email,
                                                                    creds: freshCreds)

                                    Task { @MainActor in
                                        TelematicsService.shared.configure(with: freshCreds)
                                    }

                                case .failure:
                                    // 刷新失败也无所谓，先用旧的 creds
                                    Task { @MainActor in
                                        TelematicsService.shared.configure(with: creds)
                                    }
                                }
                            }
                        }

                    } else {
                        // 3️⃣ DB 里没有记录（老账号 / 第一次改这套逻辑）：创建一个新的 telematics 用户
                        print("⚠️ No telematics data in Firebase for uid \(uid). Creating a new telematics user...")

                        TelematicsAuthManager.shared.createTelematicsUser(
                            email: email,
                            clientId: uid
                        ) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let creds):
                                    print("✅ Created new telematics user for uid \(uid). DeviceToken = \(creds.deviceToken)")
                                    self.telematicsDeviceToken = creds.deviceToken

                                    // 写入 Realtime DB
                                    self.saveTelematicsToRealtimeDB(uid: uid,
                                                                    email: email,
                                                                    creds: creds)

                                    Task { @MainActor in
                                        TelematicsService.shared.configure(with: creds)
                                    }

                                case .failure(let error):
                                    print("❌ Failed to create telematics user on login:", error)
                                    self.errorMessage = "Telematics login error: \(error.localizedDescription)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 恢复当前用户的 telematics（App 再次启动时用）

    private func restoreTelematicsForCurrentUser() {
        guard let current = Auth.auth().currentUser else { return }
        let uid = current.uid

        loadTelematicsFromRealtimeDB(uid: uid) { [weak self] creds in
            guard let self = self, let creds = creds else {
                print("ℹ️ No telematics creds to restore for uid \(uid)")
                return
            }

            print("🔁 Restoring telematics for uid \(uid). DeviceToken = \(creds.deviceToken)")
            self.telematicsDeviceToken = creds.deviceToken

            Task { @MainActor in
                TelematicsService.shared.configure(with: creds)
            }
        }
    }

    // MARK: - 登出

    @MainActor func signOut() {
        guard let currentUid = user?.uid else {
            // 没有登录用户就直接尝试 signOut 一下
            do {
                try Auth.auth().signOut()
            } catch {
                self.errorMessage = error.localizedDescription
            }
            return
        }

        do {
            try Auth.auth().signOut()
            user = nil
            telematicsDeviceToken = nil

            // 停止 SDK 追踪 & 清当前内存数据
            TelematicsService.shared.disableSDK()

            // ⚠️ 不删除 Realtime DB 里的 telematics 数据，
            // 下次登录还可以用同一份 token。
            print("👋 Signed out Firebase user \(currentUid)")

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Realtime Database helpers

    /// 写入 /users/<uid>/telematics
    private func saveTelematicsToRealtimeDB(uid: String, email: String, creds: TelematicsAuthManager.TelematicsCredentials) {
        let ref = Database.database().reference()
        let userRef = ref.child("users").child(uid)

        let teleDict: [String: Any] = [
            "deviceToken": creds.deviceToken,
            "jwt": creds.jwt,
            "refreshToken": creds.refreshToken
        ]

        userRef.updateChildValues([
            "email": email,
            "telematics": teleDict
        ]) { error, _ in
            if let error = error {
                print("❌ Failed to write telematics to Firebase:", error)
            } else {
                print("💾 Saved telematics for uid \(uid) to Firebase")
            }
        }
    }

    /// 读取 /users/<uid>/telematics
    private func loadTelematicsFromRealtimeDB(uid: String,
                                              completion: @escaping (TelematicsAuthManager.TelematicsCredentials?) -> Void) {
        let ref = Database.database().reference()
        let teleRef = ref.child("users").child(uid).child("telematics")

        teleRef.observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any],
                  let deviceToken = dict["deviceToken"] as? String,
                  let jwt = dict["jwt"] as? String,
                  let refreshToken = dict["refreshToken"] as? String else {
                completion(nil)
                return
            }

            let creds = TelematicsAuthManager.TelematicsCredentials(
                deviceToken: deviceToken,
                jwt: jwt,
                refreshToken: refreshToken
            )
            completion(creds)
        }
    }
}
