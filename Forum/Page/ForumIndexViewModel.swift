//
//  ForumIndexViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/4/2.
//

import SwiftUI
import Combine

class ForumIndexViewModel: ObservableObject, AuthManager {
    let dataFetchable: DataFetchable
    
    @AppStorage("localUsername") private var localUsername: String?
    @AppStorage("refreshToken") private var refreshToken: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
        self.tokenServiceListener()
        
        do {
            try self.dataFetchable.enableAuth()
        } catch {
            refreshToken = nil
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
                    self.refreshToken = nil
                    self.localUsername = nil
                }
            }
            .store(in: &cancellables)
        
    }
    
    func login(username: String, password: String, onFinished: @escaping () -> Void, onFaild: @escaping (Error) -> Void) {
        
        var token: String?
        
        dataFetchable.fetchApi("/account/login", method: "POST", requestPackage: LoginBody(username: username, password: password))
            .receive(on: DispatchQueue.main)
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .sink { [weak self] (completion) in
                guard let self = self else { return }
                
                switch completion {
                    
                case .finished:
                    self.refreshToken = token
                    self.localUsername = username
                    do {
                        try self.dataFetchable.enableAuth()
                        onFinished()
                    } catch {
                        onFaild(error)
                    }
                    
                case .failure(let error):
                    onFaild(error)
                }
                
            } receiveValue: {
                token = $0.refreshToken
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
        refreshToken = nil
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
