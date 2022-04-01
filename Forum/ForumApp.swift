//
//  ForumApp.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

private let apiService = ApiService(urlString: "http://localhost:8080")

@main
struct ForumApp: App {
    var body: some Scene {
        WindowGroup {
            ForumIndexView(dataFetchable: apiService)
        }
    }
}
