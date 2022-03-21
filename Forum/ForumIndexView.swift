//
//  ForumIndexView.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI

struct ForumIndexView: View {
    @State var dataFetchable: DataFetchable
    
    var body: some View {
        TabView {
            BoardView(dataFetchable: dataFetchable)
                .tabItem() {
                    Image(systemName: "list.dash")
                }
                .tag("board")
            
            LocalAccountView(dataFetchable: dataFetchable)
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
