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
    
    func login(username: String, password: String) {
        
        let group = DispatchGroup()
        
        var tokens: TokenResponse?
        var account: Account?
        
        group.enter()
        fetchApi(urlString: "http://localhost:8080/account/login", method: "POST", requestPackage: LoginBody(username: username, password: password), responsePackageType: TokenResponse.self) { data in
            
            tokens = data
            group.leave()
        }
        
        group.enter()
        fetchApi(urlString: "http://localhost:8080/account/" + username, responsePackageType: Account.self) { data in
            
            account = data
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let tokens = tokens, let account = account {
                self.accessToken = tokens.accessToken
                self.refreshToken = tokens.refreshToken
                self.account = account
                
                self.saveLocalAccount()
            }
        }
    }
    
    func fetchAccountData(accountId: String) {
        
        let group = DispatchGroup()
        var account: Account?
        
        group.enter()
        fetchApi(urlString: "http://localhost:8080/account/" + accountId + "?type=id", responsePackageType: Account.self) { data in
            account = data
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let account = account {
                self.account = account
            }
        }
    }
    
    func logout() {
        userDefault.set("", forKey: LOCAL_ACCOUNT_ID)
        userDefault.set("", forKey: REFRESH_TOKEN)
        refreshToken = ""
        account = nil
        accountId = ""
        accessToken = ""
    }
    
    func saveLocalAccount() {
        
        if let account = account {
            userDefault.set(account.id, forKey: LOCAL_ACCOUNT_ID)
        }
        
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
