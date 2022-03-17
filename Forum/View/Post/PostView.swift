//
//  PostView.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import SwiftUI

struct PostView: View {
    @State private var title: String
    @State private var topicId: String
    @StateObject private var viewModel = PostViewModel()
    
    init(title: String, topicId: String) {
        self.topicId = topicId
        self.title = title
    }
    
    var body: some View {
        List(viewModel.posts, id: \.id) { item in
            if (item.topicId == topicId) {
                TextblockView(textBlock: item.textBlock)
            }
        }
        .listStyle(.plain)
        .navigationBarTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            /*
             * WIP
             */
        }
        .onAppear(perform: {viewModel.updatePosts(topicId)})
        
    }
}


struct TextblockView: View {
   var textBlock: TextBlock
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text(textBlock.username)
                .font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/).bold()
                .padding(.bottom, 10)
            
            Text(textBlock.content)
                .font(.body)
            
            Spacer()
        }
        
        .padding(10)
    }
    
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
