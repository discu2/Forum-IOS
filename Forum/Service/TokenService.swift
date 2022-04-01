//
//  TokenService.swift
//  Forum
//
//  Created by Frank V on 2022/4/1.
//

import Foundation

struct InvalidTokenError: Error {}

class TokenService {
    private let apiService: ApiService
    private let refreshToken: String?
    private var expireTime: Date?
    private(set) var accessToken: String?
    
    private init(apiService: ApiService, refreshToken: String) {
        self.apiService = apiService
        self.refreshToken = refreshToken
    }
    
    func fetchAccessToken() async throws -> Void {
        
        let url = URL(string: apiService.urlString + "/oauth/refresh_token")!
        let request = apiService.urlRequestBuilder(url, contentType: .Json, customToken: refreshToken)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw InvalidTokenError()
        }
        
        if let accessTokenPackage = try? JSONDecoder().decode(TokenResponse.self, from: data) {
            self.accessToken = accessTokenPackage.accessToken
            self.expireTime = Date(timeIntervalSince1970: accessTokenPackage.expireDateTime/1000)
            return
        }
        
        throw InvalidTokenError()
    }
    
    static func createServiceIfValid(refreshToken: String, apiService: ApiService) throws -> TokenService {
        
        let service = TokenService(apiService: apiService, refreshToken: refreshToken)
        
        Task {
            try await service.fetchAccessToken()
        }
        
        return service
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let expireDateTime: Double
        let expireIn: Int
    }
}
