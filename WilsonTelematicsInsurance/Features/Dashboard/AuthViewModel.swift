import Foundation
import FirebaseAuth
import LoginAuth   // 如果 TelematicsAuthManager.swift 里面已经 import，则这里可以不写

final class AuthViewModel: ObservableObject {
    @Published var telematicsDeviceToken: String?
    @Published var user: User?          // 当前登录的 Firebase 用户
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        // App 启动时，如果之前登录过，会自动读出当前用户
        self.user = Auth.auth().currentUser
    }

    // 注册
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

                // ✅ 这里开始：创建 Damoov Telematics 用户
                TelematicsAuthManager.shared.createTelematicsUser(
                    email: email,
                    clientId: firebaseUser.uid
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let creds):
                            print("✅ Telematics user created. DeviceToken = \(creds.deviceToken)")
                            self.telematicsDeviceToken = creds.deviceToken

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

    // 登录
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

                // 简单做法：每次登录都尝试获取/创建 telematics 用户（由服务端去判断是否已存在）
                TelematicsAuthManager.shared.createTelematicsUser(
                    email: email,
                    clientId: firebaseUser.uid
                ) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let creds):
                            print("✅ Telematics credentials (login): \(creds.deviceToken)")
                            self.telematicsDeviceToken = creds.deviceToken
                        case .failure(let error):
                            print("❌ Telematics auth on login failed: \(error)")
                        }
                    }
                }
            }
        }
    }

    // 登出
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
