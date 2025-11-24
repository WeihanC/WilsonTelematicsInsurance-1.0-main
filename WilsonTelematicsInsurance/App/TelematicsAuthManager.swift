//
//  TelematicsAuthManager.swift
//  WilsonTelematicsInsurance
//

import Foundation
import LoginAuth

final class TelematicsAuthManager {

    static let shared = TelematicsAuthManager()

    // 你自己的 InstanceId / InstanceKey
    private let instanceId  = "33bda6ca-7cbf-4f31-a2c7-e522ccbbd228"
    private let instanceKey = "2bb56fb7-1460-448e-9712-61bd50bfe22c"

    private init() {}

    // MARK: - Model

    struct TelematicsCredentials: Codable {
        let deviceToken: String
        let jwt: String
        let refreshToken: String
    }

    // MARK: - Public API

    /// 创建 / 重新创建 Damoov 用户（带上 email / clientId 等参数）
    ///
    /// 注意：这里使用的是 “Create DeviceToken with Parameters” 版本，
    /// 跟官方 demo app 一样，DataHub 会立刻有 Email。
    func createTelematicsUser(
        email: String?,
        clientId: String?,
        completion: @escaping (Result<TelematicsCredentials, Error>) -> Void
    ) {
        let emailValue   = email    ?? ""
        let clientIdValue = clientId ?? ""

        // 下面这些字段你现在可以先留空，
        // 以后想从 Profile 里填就很容易扩展
        let phone        = ""
        let firstName    = ""
        let lastName     = ""
        let address      = ""
        let birthday     = ""   // "YYYY-MM-DD" 也可以留空
        let gender       = ""   // "Male" / "Female" / ""
        let marital      = "4"  // "1..4" = Married / Widowed / Divorced / Single
        let childrenCountNumber = NSNumber(value: 0) // ← 这里必须是 NSNumber

        LoginAuthCore.sharedManager()?.createDeviceTokenForUser(
            withParametersAndInstanceId: instanceId,
            instanceKey: instanceKey,
            email: emailValue,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            address: address,
            birthday: birthday,
            gender: gender,
            maritalStatus: marital,
            childrenCount: childrenCountNumber,
            clientId: clientIdValue,
            result: { deviceToken, jwt, refreshToken in

                guard let deviceToken = deviceToken,
                      let jwt = jwt,
                      let refreshToken = refreshToken else {
                    completion(.failure(NSError(domain: "LoginAuth", code: -1)))
                    return
                }

                let creds = TelematicsCredentials(
                    deviceToken: deviceToken,
                    jwt: jwt,
                    refreshToken: refreshToken
                )

                // 保存本地，方便以后登录复用同一个 deviceToken / jwt
                TelematicsAuthManager.saveCredentials(creds)

                print("✅ Telematics user created. DeviceToken = \(deviceToken)")

                completion(.success(creds))
            }
        )
    }

    // MARK: - Local storage (UserDefaults)

    private enum StorageKeys {
        static let telematicsCreds = "Wilson_TelematicsCredentials"
    }

    /// 保存 telematics 凭证到本地（用于下次登录复用）
    static func saveCredentials(_ creds: TelematicsCredentials) {
        do {
            let data = try JSONEncoder().encode(creds)
            UserDefaults.standard.set(data, forKey: StorageKeys.telematicsCreds)
            print("💾 Saved telematics credentials to UserDefaults")
        } catch {
            print("⚠️ Failed to save telematics creds: \(error)")
        }
    }

    /// 从本地读取 telematics 凭证（如果存在）
    static func loadSavedCredentials() -> TelematicsCredentials? {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.telematicsCreds) else {
            return nil
        }
        do {
            let creds = try JSONDecoder().decode(TelematicsCredentials.self, from: data)
            print("📥 Loaded telematics credentials from UserDefaults")
            return creds
        } catch {
            print("⚠️ Failed to load telematics creds: \(error)")
            return nil
        }
    }

    /// 清除本地缓存（Sign Out 时用）
    static func clearSavedCredentials() {
        UserDefaults.standard.removeObject(forKey: StorageKeys.telematicsCreds)
        print("🗑️ Cleared saved telematics credentials")
    }

    // 方便你之前如果写成 shared.loadSavedCredentials() 也能编译：
    func loadSavedCredentialsInstance() -> TelematicsCredentials? {
        Self.loadSavedCredentials()
    }

    func clearCredentialsInstance() {
        Self.clearSavedCredentials()
    }
}
