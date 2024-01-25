import Foundation
import UIKit

@available(macOS 12.0, *)
public class Request {
    public static let shared = Request()
    var BASE_URL = String()
    var header = [String: String]()
    var errorModel: Codable?

    public func setupVariables(baseUrl: String, header: [String: String], errorModel: Codable? = nil) {
        Request.shared.BASE_URL = baseUrl
        Request.shared.header = header
        Request.shared.errorModel = errorModel
    }

    public func requestApi<T: Codable>(_ type: T.Type, baseUrl: String? = nil, method: HTTPMethod, url: String, params: [String: Any]? = nil, isSnakeCase: Bool? = true) async throws -> T {
        if !Reachability.isConnectedToNetwork() {
            throw ServiceError.noInternetConnection
        }

        var request = URLRequest(url: URL(string: ((baseUrl != nil ? baseUrl : BASE_URL) ?? BASE_URL) + url)!)
//        header.updateValue("application/json", forKey: "Content-Type")
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + Defaults.shared.getToken(), "Content-Type": "application/json"]
        request.httpMethod = method.rawValue

        if let params = params {
            let postData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            request.httpBody = postData
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 120.0
        let session = URLSession(configuration: sessionConfig)
        
        let (data, response) = try await session.data(for: request)
        
        print("----------RESPONSE----------")
        print(String(decoding: data, as: UTF8.self))
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.custom("Invalid response")
        }

        switch httpResponse.status?.responseType {
        case .success,.redirection,.clientError,.serverError:
            let decoder = JSONDecoder()
            if isSnakeCase == true {
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
            let JSON = try decoder.decode(type, from: data)
            return JSON
        default:
            print("----------Error----------")
            print("Error code: \(String(describing: httpResponse.status))")
            throw ServiceError.custom("Error code: \(String(describing: httpResponse.status))")
        }
    }

    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"

        return fieldString
    }

    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()

        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")

        return data as Data
    }
    
    func prettyPrintJSON(from data: Data) -> String? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func parseJSON(from data: Data) -> [AnyHashable: Any]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Check if the parsed object is a dictionary
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any] else {
                print("Error: Parsed JSON is not a dictionary")
                return nil
            }
            
            return jsonDictionary
        } catch {
            // Handle the error appropriately, e.g., log it or re-throw
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func uploadMultipleImages<T: Codable>(
        _ type: T.Type,
        method: HTTPMethod,
        imageDatas: [(imageName: String, imageData: Data)],
        url: String,
        params: [String: String]? = nil,
        isSnakeCase: Bool? = true,
        authToken: String // Bearer token parameter
    ) async throws -> T {
        if !Reachability.isConnectedToNetwork() {
            throw ServiceError.noInternetConnection
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        header.updateValue("multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + Defaults.shared.getToken(), "Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let httpBody = NSMutableData()

        if let params = params {
            for (key, value) in params {
                httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
            }
        }

        for imageData in imageDatas {
            httpBody.append(convertFileData(
                fieldName: imageData.imageName,
                fileName: "\(imageData.imageName).png",
                mimeType: "image/png",
                fileData: imageData.imageData,
                using: boundary
            ))
        }

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 120.0
        let session = URLSession(configuration: sessionConfig)
        
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.custom("Invalid response")
        }
        if let prettyJson = self.prettyPrintJSON(from: data) {
            print(prettyJson)
        }
        if let parsedJSONval = parseJSON(from: data) {
            facekiOnComplete?(parsedJSONval)
        }
        
        
        switch httpResponse.status?.responseType {
        case .success:
            let decodedData = try JSONDecoder().decode(type, from: data)
            return decodedData
        default:
            let errorModel = try JSONDecoder().decode(ErrorModel.self, from: data)
            throw ServiceError.custom(errorModel.errors.first?.message ?? "")
        }
    }

    public func uploadData<T: Codable>(_ type: T.Type, method: HTTPMethod, imageData: Data, url: String, params: [String: String]? = nil, isSnakeCase: Bool? = true, imageName: String) async throws -> T {
        if !Reachability.isConnectedToNetwork() {
            throw ServiceError.noInternetConnection
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        header.updateValue("multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + Defaults.shared.getToken(), "Content-Type": "multipart/form-data; boundary=\(boundary)"]
        let httpBody = NSMutableData()

        if let params = params {
            for (key, value) in params {
                httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
            }
        }

        httpBody.append(convertFileData(fieldName: imageName,
                                        fileName: "imagename.png",
                                        mimeType: "image/png",
                                        fileData: imageData,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 120.0
        let session = URLSession(configuration: sessionConfig)
        
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.custom("Invalid response")
        }

        switch httpResponse.status?.responseType {
        case .success:
            let JSON = try JSONDecoder().decode(type, from: data)
            print(self.prettyPrintJSON(from: data)!)
            return JSON
        default:
            let JSON = try JSONDecoder().decode(ErrorModel.self, from: data)
            
            throw ServiceError.custom(JSON.errors.first?.message ?? "")
        }
    }
}
