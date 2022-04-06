//
//  CommentView.swift
//  Forum
//
//  Created by Frank V on 2022/4/5.
//

import SwiftUI

struct CommentView: View {
    @StateObject var viewModel: CommentViewModel
    @State var expened = false
    @State var list = [Comment]()
    
    init(dataFetchable: DataFetchable, postId: String) {
        self._viewModel = StateObject(wrappedValue: CommentViewModel(postId: postId, dataFetchable: dataFetchable))
    }
    
    @ViewBuilder var body: some View {
        
        if expened {
            
        } else {
            List(list, id:\.id) { comment in
                CommentBlock(textBlock: comment.textBlock)
                
            }
        }
        
    }
}

struct CommentBlock: View {
    let textBlock: TextBlock
    
    var body: some View {
        VStack {
            HStack {
                Text(textBlock.ownerUsername)
                    .bold()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "ellipsis")
            }
            Text(textBlock.content)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "hand.thumbsup").resizable()
                    .frame(width: 13, height: 13)
                Image(systemName: "hand.thumbsdown").resizable()
                    .frame(width: 13, height: 13)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentBlock(textBlock: TextBlock(ownerUsername: "tetser", postTime: Date.now, lastEditTime: Date.now, content: "uihwahfuiaweuifhajwiopefiopjw", likeUsers: [], dislikeUsers: [])).previewLayout(.sizeThatFits)
    }
}
