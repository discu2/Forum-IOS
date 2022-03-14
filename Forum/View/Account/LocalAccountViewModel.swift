//
//  LocalAccountViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI

class LocalAccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var accountId = ""
    @Published var refreshToken = ""
    @Published var accessToken = ""
    
    private let userDefault = UserDefaults.standard
    
    private let LOCAL_ACCOUNT_ID = "localAccountId"
    private let REFRESH_TOKEN = "refreshToken"
    
    init() {
        
        if let accountId = userDefault.string(forKey: LOCAL_ACCOUNT_ID) {
            self.accountId = accountId
        }
        
        if let refreshToken = userDefault.string(forKey: REFRESH_TOKEN) {
            self.refreshToken = refreshToken
        }
        
    }
    
//    func register(username: String, password: String, mail: String, nickname: String) -> Bool {
//
//    }
    
    func updateAccountInfo() {
        //do some thing
    }
    
    func login(username: String, password: String) {
        let url = URL(string: "http://localhost:8080/account/login")!
        let group = DispatchGroup()
        var tokens: TokenResponse?
        var result = false
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        let data = try? encoder.encode(LoginBody(username: username, password: password))
        request.httpBody = data
        
        group.enter()
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    tokens = try decoder.decode(TokenResponse.self, from: data)
                } catch {
                    print(error)
                }
            }
            
            group.leave()
        }).resume()
        
        group.notify(queue: .main) {
            if let tokens = tokens {
                self.refreshToken = tokens.refreshToken
                self.accessToken = tokens.accessToken
                self.saveLocalAccount()
            }
        }
    }
    
    func saveLocalAccount() {
//        guard let account = account else {
//            return
//        }
//
//        userDefault.set(account.id, forKey: LOCAL_ACCOUNT_ID)
        userDefault.set(refreshToken, forKey: REFRESH_TOKEN)
    }
    
    struct LoginBody: Encodable {
        let username: String
        let password: String
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
    }
}
