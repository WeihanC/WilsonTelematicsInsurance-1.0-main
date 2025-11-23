//
//  TelematicsAuthManager.swift
//  WilsonTelematicsInsurance
//
//  Created by WIlson's macbook on 11/21/25.
//


import Foundation
import LoginAuth

final class TelematicsAuthManager {

    static let shared = TelematicsAuthManager()

    private let instanceId = "33bda6ca-7cbf-4f31-a2c7-e522ccbbd228"
    private let instanceKey = "2bb56fb7-1460-448e-9712-61bd50bfe22c"

    private init() {}

    struct TelematicsCredentials {
        let deviceToken: String
        let jwt: String
        let refreshToken: String
    }

    func createTelematicsUser(
        email: String?,
        clientId: String?,
        completion: @escaping (Result<TelematicsCredentials, Error>) -> Void
    ) {
        LoginAuthCore.sharedManager()?.createDeviceTokenForUser(
            withInstanceId: instanceId,
            instanceKey: instanceKey,
            result: { deviceToken, jwt, refreshToken in

                guard let deviceToken = deviceToken,
                      let jwt = jwt,
                      let refreshToken = refreshToken else {
                    completion(.failure(NSError(domain: "LoginAuth", code: -1)))
                    return
                }

                completion(.success(
                    TelematicsCredentials(deviceToken: deviceToken,
                                          jwt: jwt,
                                          refreshToken: refreshToken)
                ))
            }
        )
    }
}
