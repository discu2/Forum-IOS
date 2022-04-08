//
//  ForumIndexView.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI

struct ForumIndexView: View {
    @StateObject private var viewModel: ForumIndexViewModel
    
    init(dataFetchable: DataFetchable) {
        self._viewModel = StateObject(wrappedValue: ForumIndexViewModel(dataFetchable: dataFetchable))
    }
    
    var body: some View {
        TabView {
            BoardView(dataFetchable: viewModel.dataFetchable)
                .tabItem() {
                    Image(systemName: "list.dash")
                }
                .tag("board")
            
            LocalAccountView(dataFetchable: viewModel.dataFetchable, authManager: viewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                }
        }
        .accentColor(.primary)
    }
}

struct ForumIndexView_Previews: PreviewProvider {
    static var previews: some View {
        ForumIndexView(dataFetchable: ApiService(urlString: ""))
    }
}
