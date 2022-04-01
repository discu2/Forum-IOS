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
    
    var body: some Scene {
        WindowGroup {
            ForumIndexView(dataFetchable: apiService)
        }
    }
}
