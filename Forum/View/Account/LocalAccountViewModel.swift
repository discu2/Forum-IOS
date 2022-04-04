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
    @Published var isLoggedIn: Bool = false
    
    let dataFetchable: DataFetchable
    let authManager: AuthManager
    
    @AppStorage("localUsername") var localUsername: String?
    
    var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable, authManager: AuthManager) {
        self.dataFetchable = dataFetchable
        self.authManager = authManager
        
        if (dataFetchable.tokenService == nil) {
            return
        }
        
        self.isLoggedIn = true
        fetchLocalAccountData()
    }
    
    //    func register(username: String, password: String, mail: String, nickname: String) -> Bool {
    //
    //    }
    
    func login(username: String, password: String) {
        authManager.login(username: username, password: password) { [weak self] in
            self?.isLoggedIn = true
            self?.fetchLocalAccountData()
        }

    }
    
    func logout() {
        authManager.logout { [weak self] in
            self?.isLoggedIn = false
            self?.account = nil
        }
        
    }
    
    func fetchLocalAccountData() {
        guard let username = localUsername else { return }
        
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
    
    struct AccountResponse: Decodable {
        let username: String
        let nickname: String
        let roleIds: [String]
    }
}
