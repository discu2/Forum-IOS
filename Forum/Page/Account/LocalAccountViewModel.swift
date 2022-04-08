//
//  LocalAccountViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI
import Combine

class LocalAccountViewModel: ObservableObject {
    @Published private(set) var account: Account? = nil
    @Published private(set) var isLoggedIn: Bool = false
    @Published private(set) var errorMessage: String? = nil
    
    let dataFetchable: DataFetchable
    private let authManager: AuthManager
    
    @AppStorage("localUsername") var localUsername: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable, authManager: AuthManager) {
        self.dataFetchable = dataFetchable
        self.authManager = authManager
        
        if (dataFetchable.tokenService == nil) {
            return
        }
        
        self.isLoggedIn = true
        fetchLocalAccountData()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func login(username: String, password: String) {
        authManager.login(username: username, password: password) { [weak self] in
            guard let self = self else { return }
            self.isLoggedIn = true
            self.fetchLocalAccountData()
            self.errorMessage = nil
        } onFaild: { [weak self] _ in
            self?.errorMessage = "Failed to login"
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
        
        dataFetchable.fetchApi(endPointString)
            .receive(on: DispatchQueue.main)
            .decode(type: AccountResponse.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                
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
