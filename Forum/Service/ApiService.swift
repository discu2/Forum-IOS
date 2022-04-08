//
//  ApiService.swift
//  Forum
//
//  Created by Frank V on 2022/3/16.
//

import Foundation
import Combine
import SwiftUI

enum HttpContentType: String {
    case Json = "application/json"
    case FormData = "multipart/form-data"
}

struct HttpError: Error {
    let code: Int
}

class ApiService: DataFetchable {
    
    @Published var tokenService: TokenService?
    var tokenServicePublisher: Published<TokenService?>.Publisher { $tokenService }
    
    let urlString: String
    
    var cancellables = Set<AnyCancellable>()
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    private func sessionHandler<C: Decodable>(data: Data?, response: URLResponse?, error: Error?, responsePackageType: C.Type, promise: Future<C?, Error>.Promise) {
        
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if code != 200 {
            promise(.failure(HttpError(code: code)))
            return
        }
        
        if let data = data, !(responsePackageType is NoResponse.Type) {
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
        
        if let customToken = customToken {
            request.setValue("Bearer " + customToken, forHTTPHeaderField: "Authorization")
            return request
        }
        
        if let accessToken = tokenService?.accessToken {
            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
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
    
    func fetchApi<T: Encodable>(_ endPointString: String, method: String ,requestPackage: T) -> Future<NoResponse?, Error> {
        
        let url = URL(string: urlString + endPointString)!
        var request = urlRequestBuilder(url, method: method, contentType: .Json)
        
        let data = try? JSONEncoder().encode(requestPackage)
        request.httpBody = data
        
        return Future { [weak self] promise in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, responsePackageType: NoResponse.self, promise: promise)
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
    
    func enableAuth() throws -> Void {
        tokenService = try TokenService(urlString: urlString, urlRequestBuilder: urlRequestBuilder)
    }
    
    func disableAuth() {
        tokenService = nil
        
        //send logout request
    }
    
    
    
}
