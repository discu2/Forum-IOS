//
//  CommentView.swift
//  Forum
//
//  Created by Frank V on 2022/4/5.
//

import SwiftUI
import CachedAsyncImage

struct CommentView: View {
    @StateObject private var viewModel: CommentViewModel
    @Binding private var isCommentPoped: Bool
    
    init(dataFetchable: DataFetchable, postId: String, isCommentPoped: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: CommentViewModel(postId: postId, dataFetchable: dataFetchable))
        
        self._isCommentPoped = isCommentPoped
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.comments, id:\.id) { comment in
                CommentBlock(textBlock: comment.textBlock)
                    .environmentObject(viewModel)
            }
            .onAppear { viewModel.fetchComments() }
            .navigationTitle("Comment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Image(systemName: "xmark").foregroundColor(.primary))
        }
        
    }
}

struct PreviewCommentBlock: View {
    @StateObject private var viewModel: CommentViewModel
    
    init(dataFetchable: DataFetchable, postId: String) {
        self._viewModel = StateObject(wrappedValue: CommentViewModel(postId: postId, dataFetchable: dataFetchable))
    }
    
    var body: some View {
        VStack {
            ZStack {
                Color.secondary
                Text("Comments")
            }
            Text(viewModel.comments.first?.textBlock.ownerUsername ?? "")
                .bold()
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(viewModel.comments.first?.textBlock.content ?? "")
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
        }
        .onAppear {
            viewModel.fetchComments()
        }
        .padding(.vertical, 5)
        
    }
}

struct CommentBlock: View {
    let textBlock: TextBlock
    @EnvironmentObject private var viewModel: CommentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                avatarBuilder
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                Text(textBlock.ownerUsername)
                    .bold()
                    .lineLimit(1)
                Spacer()
                Image(systemName: "ellipsis")
            }
            .padding(.bottom, 1)
            
            Text(textBlock.content)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "hand.thumbsup").resizable()
                    .frame(width: 13, height: 13)
                Image(systemName: "hand.thumbsdown").resizable()
                    .frame(width: 13, height: 13)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
        }
        .padding(.vertical, 3)
    }
    
    @ViewBuilder var avatarBuilder: some View {
        if let imageId = viewModel.avatarIds[textBlock.ownerUsername] {
            CachedAsyncImage(url: URL(string:"http://localhost:8080/avatar?id=\(imageId)")) { phase in
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

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentBlock(textBlock: TextBlock(ownerUsername: "tetser", postTime: Date.now, lastEditTime: Date.now, content: "uihwahfuiaweuifhajwiasdfasdfsdfsdafsdfsdfsadfsadfsadfoddgpefiopjw", likeUsers: [], dislikeUsers: [])).previewLayout(.sizeThatFits)
    }
}
