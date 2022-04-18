//
//  ForumApp.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

@main
struct ForumApp: App {
    private let apiService = ApiService(urlString: "http://localhost:8080")
    private let accountDetailSercice = AccountDetailService()
    
    init() {
        dependenciesRegister()
    }
    
    var body: some Scene {
        WindowGroup {
            ForumIndexView()
        }
    }
    
    func dependenciesRegister() {
        Dependencies.Container.main.register(apiService as DataFetchable)
        Dependencies.Container.main.register(accountDetailSercice)
    }
}
