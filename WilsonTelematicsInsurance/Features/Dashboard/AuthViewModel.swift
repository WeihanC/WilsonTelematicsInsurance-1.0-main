import Foundation
import FirebaseAuth
import LoginAuth   // TelematicsAuthManager 用到
// 不需要在这里 import TelematicsSDK，交给 TelematicsService 管

final class AuthViewModel: ObservableObject {
    @Published var telematicsDeviceToken: String?
    @Published var user: User?          // 当前登录的 Firebase 用户
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        // App 启动时，如果之前登录过，会自动读出当前用户
        self.user = Auth.auth().currentUser
    }

    // MARK: - 注册（只在「新用户」时调用一次 createTelematicsUser）

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

                // ✅ 第一次为这个账号创建 Damoov Telematics 用户
                TelematicsAuthManager.shared.createTelematicsUser(
                    email: email,
                    clientId: firebaseUser.uid
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let creds):
                            print("✅ Telematics user created. DeviceToken = \(creds.deviceToken)")
                            self.telematicsDeviceToken = creds.deviceToken

                            // 初始化 SDK，让这个用户开始可追踪
                            Task { @MainActor in
                                TelematicsService.shared.configure(with: creds)
                            }

                            // TODO: 以后可以存在 Firestore：
                            // self.saveTelematicsCredentialsToFirestore(user: firebaseUser, creds: creds)

                        case .failure(let error):
                            print("❌ Failed to create telematics user: \(error)")
                            // 可选：在 UI 上提示
                            // self.errorMessage = "Telematics user error: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }

    // MARK: - 登录（⚠️ 不要再每次 createTelematicsUser）

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

                // ✅ 登录时的正确流程：
                // 1. 先尝试从本地读取已经保存的 TelematicsCredentials
                if let savedCreds = TelematicsAuthManager.loadSavedCredentials() {
                    print("✅ Loaded saved telematics credentials. DeviceToken = \(savedCreds.deviceToken)")
                    self.telematicsDeviceToken = savedCreds.deviceToken

                    // 2. 用已有的 deviceToken 配置 SDK（同一个账号 = 同一个 deviceToken）
                    Task { @MainActor in
                        TelematicsService.shared.configure(with: savedCreds)
                    }
                } else {
                    // 3. 如果本地没有（例如你第一次写这套逻辑之前的老账号），可以临时再创建一次
                    //    注意：真实上线时建议从你的后端拿，而不是在客户端频繁新建
                    print("⚠️ No saved telematics credentials. Creating a new telematics user for this account...")

                    TelematicsAuthManager.shared.createTelematicsUser(
                        email: email,
                        clientId: firebaseUser.uid
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let creds):
                                print("✅ Telematics credentials (login created): \(creds.deviceToken)")
                                self.telematicsDeviceToken = creds.deviceToken

                                Task { @MainActor in
                                    TelematicsService.shared.configure(with: creds)
                                }

                            case .failure(let error):
                                print("❌ Telematics auth on login failed: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - 登出

    @MainActor func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil

            // 登出时，可以让 SDK 停止追踪（避免后台还在跑）
            TelematicsService.shared.disableSDK()

            // 注意：这里 **不要** 调 TelematicsAuthManager.shared.clearCredentials()
            // 否则下次登录又会生成新的 deviceToken，跟你现在遇到的问题一样。

        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
