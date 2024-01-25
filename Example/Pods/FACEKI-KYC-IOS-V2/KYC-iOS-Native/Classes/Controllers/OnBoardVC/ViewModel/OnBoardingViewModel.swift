//
//  ViewModel.swift
//  ScanDocument
//
//

import Foundation
class OnBoardingViewModel {
    func getToken(clientIdVal : String, clientSecretVal: String) async throws -> OnBoardingModel {
        print(clientIdVal)
        return try await Request.shared.requestApi(OnBoardingModel.self, baseUrl: "https://sdk.faceki.com/auth/api/access-token?clientId="+clientIdVal+"&clientSecret="+clientSecretVal, method: .get, url: "", isSnakeCase: false)
    }
}
