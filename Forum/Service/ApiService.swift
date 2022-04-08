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
    case json = "application/json"
    case formData = "multipart/form-data"
}

enum HttpError: Error {
    case code(Int)
    case unknow
}

class ApiService: DataFetchable {
    
    @Published var tokenService: TokenService?
    var tokenServicePublisher: Published<TokenService?>.Publisher { $tokenService }
    
    let urlString: String
    
    var cancellables = Set<AnyCancellable>()
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    private func sessionHandler(data: Data?, response: URLResponse?, error: Error?, promise: Future<Data, Error>.Promise) {
        
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        guard code == 200 else {
            promise(.failure(HttpError.code(code)))
            return
        }
        
        if let data = data {
            promise(.success(data))
            return
        }

        promise(.failure(HttpError.unknow))
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
    
    func fetchApi<T: Encodable>(_ endPointString: String, method: String ,requestPackage: T) -> Future<Data, Error> {
        
        let url = URL(string: urlString + endPointString)!
        var request = urlRequestBuilder(url, method: method, contentType: .json)
        
        let data = try? JSONEncoder().encode(requestPackage)
        request.httpBody = data
        
        return Future { [weak self] promise in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, promise: promise)
            }
            .resume()
        }
    }
    
    func fetchApi(_ endPointString: String) -> Future<Data, Error> {
        
        let url = URL(string: urlString + endPointString)!
        let request = urlRequestBuilder(url, contentType: .json)
        
        return Future { [weak self] promise in
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, promise: promise)
            }
            .resume()
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
