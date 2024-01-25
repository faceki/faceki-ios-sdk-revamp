//
//  ViewModel.swift
//  ScanDocument
//
//

import Foundation
class HomeViewModel {
    func documentCopyRulesApiCall() async throws -> DocumentCopyRulesModel {
        return try await Request.shared.requestApi(DocumentCopyRulesModel.self, baseUrl: "https://sdk.faceki.com/kycrules/api/kycrules", method: .get, url: "", isSnakeCase: false)
    }
}
