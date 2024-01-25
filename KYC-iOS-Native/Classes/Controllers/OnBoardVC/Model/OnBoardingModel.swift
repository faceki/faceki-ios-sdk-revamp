//
//  OnBoardingModel.swift
//  ScanDocument
//
//

import Foundation

// MARK: - Welcome
struct OnBoardingModel: Codable {
    let responseCode: Int?
    let data: DataClass?
}

// MARK: - DataClass
struct DataClass: Codable {
    let accessToken: String?
    let expiresIn: Int?
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}
