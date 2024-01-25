//
//  Defaults.swift
//  ScanDocument
//
//  Created by FACEKI on 15/01/2024.
//

import Foundation
import Foundation
class Defaults {
    static let shared = Defaults()
    private init() {}
    func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
    }
    func getToken() -> String {
        UserDefaults.standard.string(forKey: "token") ?? ""
    }
}
var Faceki_clientSecret = ""
var Faceki_clientId = ""
var Faceki_selfieImageUrl = "https://facekiassets.faceki.com/public/SelfieGuide.png"
var Faceki_cardGuideUrl = "https://facekiassets.faceki.com/public/Guide.png"


let frameworkImageBundle = Bundle(for: Logger.self)
let pathImage = frameworkImageBundle.path(forResource: "Resources", ofType: "bundle")
let resourcesBundleImg = Bundle(url: URL(fileURLWithPath: pathImage!))

var facekiOnComplete: ((_ date: [AnyHashable:Any]) -> ())?
var FacekiredirectBack: (() -> ())?
