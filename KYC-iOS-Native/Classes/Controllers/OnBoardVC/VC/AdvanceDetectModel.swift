//
//  AdvanceDetectModel.swift
//  ScanDocument
//
//

import Foundation

struct AdvanceDetectModel: Codable {
    let liveness: Liveness?
    let objectsDetected: [String]?
    let quality: String?
    let error : String?
    let message : String?

    enum CodingKeys: String, CodingKey {
        case liveness
        case objectsDetected = "objects_detected"
        case quality
        case error
        case message
    }
}

// MARK: - Liveness
struct Liveness: Codable {
    let actual: Bool?
    let livenessScore: Double?
    let message: String?
}


