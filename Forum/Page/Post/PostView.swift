//
//  PostView.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel: PostViewModel
    @State private var title: String
    @State private var topicId: String
    
    init(dataFetchable: DataFetchable, title: String, topicId: String) {
        self._viewModel = StateObject(wrappedValue: PostViewModel(dataFetchable: dataFetchable))
        self.topicId = topicId
        self.title = title
    }
    
    var body: some View {
        List(viewModel.posts, id: \.id) { item in
            TextblockView(textBlock: item.textBlock, id: item.id)
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            /*
             WIP
             */
        }
        .onAppear(perform: {
            viewModel.topicId = topicId
        })
        .environmentObject(viewModel)
        
    }
}


struct TextblockView: View {
    let textBlock: TextBlock
    let id: String
    @EnvironmentObject var viewModel: PostViewModel
    @State var isCommentPoped = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text(textBlock.ownerUsername)
                .font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/).bold()
                .padding(.bottom, 10)
            
            Text(textBlock.content)
                .font(.body)

            Button {
                isCommentPoped.toggle()
            } label: {
                PreviewCommentBlock(dataFetchable: viewModel.dataFetchable, postId: id)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isCommentPoped) {
                CommentView(dataFetchable: viewModel.dataFetchable, postId: id, isCommentPoped: $isCommentPoped)
            }
            
            Spacer()
        }
        
    }
    
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
