//
//  LocalAccountViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI
import Combine

class LocalAccountViewModel: ObservableObject {
    @Published var account: Account?
    @Published var username = ""
    @Published var refreshToken = ""
    @Published var accessToken = ""
    
    @Published var logining = false
    
    private let userDefault = UserDefaults.standard
    
    private let LOCAL_USERNAME = "localUsername"
    private let REFRESH_TOKEN = "refreshToken"
    
    let dataFetchable: DataFetchable
    
    var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        
        self.dataFetchable = dataFetchable
        
        if let username = userDefault.string(forKey: LOCAL_USERNAME) {
            self.username = username
        }
        
        if let refreshToken = userDefault.string(forKey: REFRESH_TOKEN) {
            self.refreshToken = refreshToken
        }
              
    }
    
//    func register(username: String, password: String, mail: String, nickname: String) -> Bool {
//
//    }
    
    func login(username: String, password: String) {
        
        logining = true
        
        dataFetchable.fetchApi(uriString: "/account/login", method: "POST", requestPackage: LoginBody(username: username, password: password), responsePackageType: TokenResponse.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                switch completion {
                    
                case .finished:
                    self?.fetchAccountData(username: username)

                case .failure(let error):
                    print(error)
                
                }
                
                self?.logining = false
                
            } receiveValue: { [weak self] (data) in
                
                guard let self = self else { return }
                self.refreshToken = data!.refreshToken
                self.accessToken = data!.accessToken
                
                self.saveLocalAccount()
            }
            .store(in: &cancellables)
        
    }
    
    func fetchAccountData(username: String) {
        
       let uriString = "/account/" + username
        
        dataFetchable.fetchApi(uriString: uriString, responsePackageType: AccountResponse.self)
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
                self.saveLocalAccount()
            }
            .store(in: &cancellables)

    }
    
    func logout() {
        userDefault.set("", forKey: LOCAL_USERNAME)
        userDefault.set("", forKey: REFRESH_TOKEN)
        refreshToken = ""
        account = nil
        accessToken = ""
    }
    
    func saveLocalAccount() {
        guard let account = account, refreshToken != "" else { return }
        
        userDefault.set(account.username, forKey: LOCAL_USERNAME)
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
    
    struct AccountResponse: Decodable {
        let username: String
        let nickname: String
        let roleIds: [String]
    }
}
