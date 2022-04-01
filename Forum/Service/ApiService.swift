//
//  ApiService.swift
//  Forum
//
//  Created by Frank V on 2022/3/16.
//

import Foundation
import Combine

enum HttpContentType: String {
    case Json = "application/json"
    case FormData = "multipart/form-data"
}

class ApiService: DataFetchable {
    
    let urlString: String
    var tokenService: TokenService?
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    func sessionHandler<C: Decodable>(data: Data?, response: URLResponse?, error: Error?, responsePackageType: C.Type?, promise: Future<C?, Error>.Promise) {
        
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if code != 200 {
            promise(.failure(NSError(domain: "", code: code)))
            return
        }
            
        if let data = data, let responsePackageType = responsePackageType {
            do {
                let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                promise(.success(decoded))
            } catch {
                promise(.failure(error))
            }
            
            return
        }
        
        promise(.success(nil))
    }
    
    func urlRequestBuilder(_ url: URL, method: String = "GET", contentType: HttpContentType?, customToken: String? = nil) -> URLRequest {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        
        if let contentType = contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        if let tokenService = tokenService {
            if let customToken = customToken {
                request.setValue("Bearer " + customToken, forHTTPHeaderField: "Authorization")
            } else {
                request.setValue("Bearer " + tokenService.accessToken!, forHTTPHeaderField: "Authorization")
            }
            
        }
        
        return request
    }
    
    func fetchApi<T: Encodable, C: Decodable>(_ endPointString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString + endPointString)!
        var request = urlRequestBuilder(url, method: method, contentType: .Json)
        
        let data = try? JSONEncoder().encode(requestPackage)
        request.httpBody = data
        
        return Future { [weak self] promise in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, responsePackageType: responsePackageType, promise: promise)
            }.resume()
            
        }
    }
    
    func fetchApi<C: Decodable>(_ endPointString: String, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString + endPointString)!
        let request = urlRequestBuilder(url, contentType: .Json)
        
        return Future { [weak self] promise in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, responsePackageType: responsePackageType, promise: promise)
            }.resume()
            
        }
    }
    
}
