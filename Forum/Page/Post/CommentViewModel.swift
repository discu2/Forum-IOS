//
//  CommentViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/4/5.
//

import SwiftUI
import Combine

class CommentViewModel: ObservableObject {
    @Published var postId: String
    @Published var comments = [Comment]()
    
    let dataFetchable: DataFetchable
    
    var cancellables = Set<AnyCancellable>()
    
    init(postId: String, dataFetchable: DataFetchable) {
        self.postId = postId
        self.dataFetchable = dataFetchable
    }
    
    func fetchComments() {
        dataFetchable.fetchApi("/comment/" + postId + "?page=1", responsePackageType: [CommentResponse].self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] data in
                guard let data = data else { return }
                
                var comments = [Comment]()
                
                for comment in data {
                    comments.append(Comment(id: comment.id, textBlock: TextBlock(ownerUsername: comment.ownerUsername, postTime: Date(timeIntervalSince1970: comment.postTime/1000), lastEditTime: Date(timeIntervalSince1970: comment.lastEditTime/1000), content: comment.content, likeUsers: comment.likeUsers, dislikeUsers: comment.dislikeUsers), postId: comment.postId))
                }
                
                self?.comments += comments
            }
            .store(in: &cancellables)

    }
    
    struct CommentResponse: Decodable {
        let id: String
        let ownerUsername: String
        let postTime: Double
        let lastEditTime: Double
        let content: String
        let likeUsers: [String]
        let dislikeUsers: [String]
        let postId: String
    }
    
}
