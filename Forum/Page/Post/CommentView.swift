//
//  CommentView.swift
//  Forum
//
//  Created by Frank V on 2022/4/5.
//

import SwiftUI

struct CommentView: View {
    @StateObject var viewModel: CommentViewModel
    @Binding var isCommentPoped: Bool
    
    init(dataFetchable: DataFetchable, postId: String, isCommentPoped: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: CommentViewModel(postId: postId, dataFetchable: dataFetchable))
        
        self._isCommentPoped = isCommentPoped
    }
    
    var body: some View {

        ZStack {
            Color.secondary
            
            Text("Comments")
            Button {
                isCommentPoped.toggle()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxHeight: 40)
        
        List(viewModel.comments, id:\.id) { comment in
            CommentBlock(textBlock: comment.textBlock)
                .environmentObject(viewModel)
        }
        .onAppear { viewModel.fetchComments() }
        
    }
}

struct PreviewCommentBlock: View {
    @StateObject var viewModel: CommentViewModel
    
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
        
        //.padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct CommentBlock: View {
    let textBlock: TextBlock
    @EnvironmentObject var viewModel: CommentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AsyncImage(url: URL(string:"http://localhost:8080/account/" + textBlock.ownerUsername + "/profile_pic?size=2")) { phase in
                    if let image = phase.image {
                        image.resizable()
                    } else {
                        Color.gray
                    }
                }
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
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentBlock(textBlock: TextBlock(ownerUsername: "tetser", postTime: Date.now, lastEditTime: Date.now, content: "uihwahfuiaweuifhajwiasdfasdfsdfsdafsdfsdfsadfsadfsadfoddgpefiopjw", likeUsers: [], dislikeUsers: [])).previewLayout(.sizeThatFits)
    }
}
