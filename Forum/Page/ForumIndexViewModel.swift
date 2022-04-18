//
//  ForumIndexViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/4/2.
//

import SwiftUI
import Combine

class ForumIndexViewModel: ObservableObject, AuthManager {
    @Dependencies.InjectObject
    var dataFetchable: DataFetchable
    
    @AppStorage("localUsername") private var localUsername: String?
    
    private var cancellables = Set<AnyCancellable>()
    private var authServiceLoaded = false
    
    private let keychainService: KeychainService
    
    init() {
        self.keychainService = KeychainService()
        self.tokenServiceListener()
        Dependencies.Container.main.register(self)
        
        do {
            try self.dataFetchable.enableAuth()
        } catch {
            keychainService.deleteRefreshToken()
            localUsername = nil
        }
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func tokenServiceListener() {
        
        dataFetchable.tokenServicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] service in
                guard let self = self else { return }
                
                if service == nil {
                    if self.authServiceLoaded {
                        self.keychainService.deleteRefreshToken()
                        self.localUsername = nil
                        self.authServiceLoaded = false
                        return
                    }
                    
                    self.authServiceLoaded = true
                }
            }
            .store(in: &cancellables)
        
    }
    
    func login(username: String, password: String, onFinished: @escaping () -> Void, onFaild: @escaping (Error) -> Void) {
        
        dataFetchable.fetchApi("/account/login", method: "POST", requestPackage: LoginBody(username: username, password: password))
            .receive(on: DispatchQueue.main)
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    onFaild(error)
                }
                
            } receiveValue: { [weak self] in
                guard let self = self else { return }
                let token = $0.refreshToken
                
                self.keychainService.saveRefreshToken(token)
                self.localUsername = username
                do {
                    try self.dataFetchable.enableAuth()
                    onFinished()
                } catch {
                    onFaild(error)
                }
            }
            .store(in: &cancellables)
        
    }
    
    func login(username: String, password: String, onFinished: @escaping () -> Void) {
        login(username: username, password: password, onFinished: onFinished, onFaild: {_ in })
    }
    
    func login(username: String, password: String) {
        login(username: username, password: password, onFinished: {}, onFaild: {_ in })
    }
    
    func logout(action: () -> Void = {}) {
        dataFetchable.disableAuth()
        keychainService.deleteRefreshToken()
        localUsername = nil
        action()
    }
    
    struct LoginBody: Encodable {
        let username: String
        let password: String
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String
        let expireDateTime: Double
        let expireIn: Int
    }
    
}
