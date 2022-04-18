//
//  PostView.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import SwiftUI
import CachedAsyncImage

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @State var title: String
    @State var topicId: String
    
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
    @EnvironmentObject private var viewModel: PostViewModel
    @State private var isCommentPoped = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                avatarBuilder
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                
                Text(textBlock.ownerUsername)
                    .font(/*@START_MENU_TOKEN@*/.body/*@END_MENU_TOKEN@*/).bold()
            }
            .padding(.bottom, 10)
            
            Text(textBlock.content)
                .font(.body)

            Button {
                isCommentPoped.toggle()
            } label: {
                PreviewCommentBlock(postId: id)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isCommentPoped) {
                CommentView(postId: id, isCommentPoped: $isCommentPoped)
            }
            
            Spacer()
        }
        
    }
    
    @ViewBuilder var avatarBuilder: some View {
        if let imageId = viewModel.avatarIds[textBlock.ownerUsername] {
            CachedAsyncImage(url: URL(string:"http://localhost:8080/avatar?id=\(imageId)"), urlCache: .accountAvatarCache) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.gray
                }
            }
        } else {
            Color.gray
        }
    }
    
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
