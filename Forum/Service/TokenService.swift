//
//  TokenService.swift
//  Forum
//
//  Created by Frank V on 2022/4/1.
//

import Foundation

struct InvalidTokenError: Error {}

class TokenService {
    private let urlString: String
    private let refreshToken: String?
    private var expireTime: Double?
    private var _accessToken: String?
    
    private let urlRequestBuilder: (URL, String, HttpContentType?, String?) -> URLRequest
    
    var accessToken: String? {
        get {
            guard let expireTime = expireTime else {
                return nil
            }
            
            if expireTime - Date.now.timeIntervalSince1970.binade > 10 {
                return _accessToken
            }
            
            try? fetchAccessToken()
            return _accessToken
        }
    }
    
    private let REFRESH_TOKEN = "refreshToken"
    
    
    init(urlString: String, urlRequestBuilder: @escaping (URL, String, HttpContentType?, String?) -> URLRequest) throws {
        guard let refreshToken = UserDefaults.standard.string(forKey: REFRESH_TOKEN) else { throw InvalidTokenError() }
        
        self.urlString = urlString
        self.refreshToken = refreshToken
        self.urlRequestBuilder = urlRequestBuilder
        
        try fetchAccessToken()
    }
    
    func fetchAccessToken() throws {
        
        let url = URL(string: urlString + "/oauth/refresh_token")!
        let request = self.urlRequestBuilder(url, "GET", .json, refreshToken)
        let semaphore = DispatchSemaphore(value: 0)
        
        var throwable: Error?
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throwable = error
                semaphore.signal()
                return
            }
            
            if let data = data, let accessTokenPackage = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                self._accessToken = accessTokenPackage.accessToken
                self.expireTime = accessTokenPackage.expireDateTime/1000
                print("Access token updated")
            }
            
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        
        if let throwable = throwable {
            throw throwable
        }
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let expireDateTime: Double
        let expireIn: Int
    }
}
