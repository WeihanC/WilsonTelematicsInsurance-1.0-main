//
//  TelematicsAuthManager.swift
//  WilsonTelematicsInsurance
//
//  负责：跟 Damoov LoginAuth 打交道（创建用户 / 刷新 JWT）
//

import Foundation
import LoginAuth

final class TelematicsAuthManager {

    static let shared = TelematicsAuthManager()

    // 你自己的 InstanceId / InstanceKey（来自 DataHub）
    private let instanceId  = "33bda6ca-7cbf-4f31-a2c7-e522ccbbd228"
    private let instanceKey = "2bb56fb7-1460-448e-9712-61bd50bfe22c"

    private init() {}

    // MARK: - Model

    struct TelematicsCredentials: Codable {
        let deviceToken: String
        let jwt: String
        let refreshToken: String
    }

    // MARK: - Public API：创建一个新的 telematics 用户

    /// 为某个业务用户（通常用 Firebase UID）创建一个新的 Damoov 用户
    ///
    /// - Parameters:
    ///   - email: 用户邮箱（可选，用来在 DataHub 里显示）
    ///   - clientId: 业务侧的用户 ID（推荐传 Firebase 的 uid）
    ///   - completion: 返回 TelematicsCredentials 或错误
    func createTelematicsUser(
        email: String?,
        clientId: String?,
        completion: @escaping (Result<TelematicsCredentials, Error>) -> Void
    ) {
        let emailValue    = email     ?? ""
        let clientIdValue = clientId  ?? ""

        // 下面这些字段现在可以留空，将来想从 Profile 里填再扩展
        let phone         = ""
        let firstName     = ""
        let lastName      = ""
        let address       = ""
        let birthday      = ""   // "YYYY-MM-DD" 也可以直接空字符串
        let gender        = ""   // "Male" / "Female" / ""
        let marital       = "4"  // "1..4" = Married / Widowed / Divorced / Single
        let childrenCount = NSNumber(value: 0)

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
            childrenCount: childrenCount,
            clientId: clientIdValue,
            result: { deviceToken, jwt, refreshToken in

                guard let deviceToken = deviceToken,
                      let jwt = jwt,
                      let refreshToken = refreshToken else {
                    let err = NSError(domain: "LoginAuth", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: "LoginAuth returned nil token"
                    ])
                    completion(.failure(err))
                    return
                }

                let creds = TelematicsCredentials(
                    deviceToken: deviceToken,
                    jwt: jwt,
                    refreshToken: refreshToken
                )

                print("✅ Telematics user created. DeviceToken = \(deviceToken)")

                completion(.success(creds))
            }
        )
    }

    // MARK: - Public API：根据 deviceToken 刷新 JWT

    /// 根据已有的 deviceToken 刷新 JWT
    /// - 注意：deviceToken 不变，只更新 jwt / refreshToken
    func refreshJwt(
        forDeviceToken deviceToken: String,
        completion: @escaping (Result<TelematicsCredentials, Error>) -> Void
    ) {
        LoginAuthCore.sharedManager()?.getJWTokenForUser(
            withDeviceToken: deviceToken,
            instanceId: instanceId,
            instanceKey: instanceKey,
            result: { jwt, refresh in
                guard let jwt = jwt, let refresh = refresh else {
                    let err = NSError(domain: "TelematicsAuth", code: -3, userInfo: [
                        NSLocalizedDescriptionKey: "Failed to refresh JWT"
                    ])
                    completion(.failure(err))
                    return
                }

                let creds = TelematicsCredentials(
                    deviceToken: deviceToken,
                    jwt: jwt,
                    refreshToken: refresh
                )

                print("🔄 Refreshed JWT for deviceToken \(deviceToken.prefix(8))...")

                completion(.success(creds))
            }
        )
    }
}
