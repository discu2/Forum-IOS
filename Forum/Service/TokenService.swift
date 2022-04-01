//
//  TokenService.swift
//  Forum
//
//  Created by Frank V on 2022/4/1.
//

import Foundation

class TokenService {
    private let apiService: ApiService
    private let refreshToken: String?
    private var expireTime: Date?
    private(set) var accessToken: String?
    
    private init(apiService: ApiService, refreshToken: String) {
        self.apiService = apiService
        self.refreshToken = refreshToken
        self.fetchAccessToken()
    }
    
    func fetchAccessToken() {
        
        let url = URL(string: apiService.urlString + "/oauth/refresh_token")!
        let request = apiService.urlRequestBuilder(url, method: "POST", contentType: .Json, customToken: refreshToken)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if code != 200 {
                self.accessToken = nil
                return
            }
                
            if let data = data {
                do {
                    let accessTokenPackage = try JSONDecoder().decode(TokenResponse.self, from: data)
                    self.accessToken = accessTokenPackage.accessToken
                    self.expireTime = Date(timeIntervalSince1970: accessTokenPackage.expireDateTime/1000)
                } catch {
                    self.accessToken = nil
                }
            }
        }.resume()
    }
    
    static func createServiceIfVaild(refreshToken: String, apiService: ApiService) -> TokenService? {
        let service = TokenService(apiService: apiService, refreshToken: refreshToken)
        return service.accessToken == nil ? nil : service
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let expireDateTime: Double
        let expireIn: Int
    }
}
