//
//  LocalAccountViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI
import Combine

class LocalAccountViewModel: ObservableObject {
    @Published var account: Account? = nil
    @Published var username: String? = nil
    @Published var refreshToken: String? = nil
    @Published var accessToken: String? = nil
    @Published var isLoggedIn = false
    
    private let userDefault = UserDefaults.standard
    
    private let LOCAL_USERNAME = "localUsername"
    private let REFRESH_TOKEN = "refreshToken"
    
    let dataFetchable: DataFetchable
    
    var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        
        self.dataFetchable = dataFetchable
        
        if let username = userDefault.string(forKey: LOCAL_USERNAME) {
            self.username = username
            fetchAccountData(username: username)
        }
        
        if let refreshToken = userDefault.string(forKey: REFRESH_TOKEN) {
            self.refreshToken = refreshToken
            isLoggedIn = true
        }
    }
    
    //    func register(username: String, password: String, mail: String, nickname: String) -> Bool {
    //
    //    }
    
    func login(username: String, password: String) {
        
        dataFetchable.fetchApi("/account/login", method: "POST", requestPackage: LoginBody(username: username, password: password), responsePackageType: TokenResponse.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                guard let self = self else { return }
                
                switch completion {
                    
                case .finished:
                    self.fetchAccountData(username: username)
                    self.saveLocalAccount()
                    
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] (data) in
                
                guard let self = self else { return }
                self.username = username
                self.refreshToken = data!.refreshToken
                self.accessToken = data!.accessToken
                
            }
            .store(in: &cancellables)
        
    }
    
    func fetchAccountData(username: String) {
        
        let endPointString = "/account/" + username
        
        dataFetchable.fetchApi(endPointString, responsePackageType: AccountResponse.self)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                switch completion {
                    
                case .finished:
                    break
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            } receiveValue: { [weak self] (data) in
                guard let self = self, let data = data else { return }
                
                self.account = Account(username: data.username, roleIds: data.roleIds, nickname: data.nickname)
            }
            .store(in: &cancellables)
        
    }
    
    func logout() {
        isLoggedIn = false
        userDefault.removeObject(forKey: LOCAL_USERNAME)
        userDefault.removeObject(forKey: REFRESH_TOKEN)
        refreshToken = nil
        username = nil
        account = nil
        accessToken = nil
    }
    
    func saveLocalAccount() {
        guard let username = username, let refreshToken = refreshToken else { return }
        
        userDefault.set(username, forKey: LOCAL_USERNAME)
        userDefault.set(refreshToken, forKey: REFRESH_TOKEN)
        
        // Not good
        isLoggedIn = true
    }
    
    struct LoginBody: Encodable {
        let username: String
        let password: String
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
    }
    
    struct AccountResponse: Decodable {
        let username: String
        let nickname: String
        let roleIds: [String]
    }
}
