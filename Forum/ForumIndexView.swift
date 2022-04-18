//
//  ForumIndexView.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI

struct ForumIndexView: View {
    @StateObject private var viewModel = ForumIndexViewModel()
    
    var body: some View {
        TabView {
            BoardView()
                .tabItem() {
                    Image(systemName: "list.dash")
                }
                .tag("board")
            
            LocalAccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .accentColor(.primary)
    }
}

struct ForumIndexView_Previews: PreviewProvider {
    static var previews: some View {
        ForumIndexView()
    }
}
