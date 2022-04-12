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
    @Published private(set) var comments = [Comment]()
    @Published private(set) var avatarIds = [String:String]()
    
    let dataFetchable: DataFetchable
    let accountDetialService: AccountDetailService
    
    var usernames = [String]()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(postId: String, dataFetchable: DataFetchable) {
        self.postId = postId
        self.dataFetchable = dataFetchable
        self.accountDetialService = AccountDetailService(dataFetchable: dataFetchable)
        
        accountsListener()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func accountsListener() {
        accountDetialService.$accounts
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .map {
                var result = [String:String]()
                for username in $0.keys {
                    guard let avatarId = ($0[username] as? Account)?.avatarIds["SMALL"] else { continue }
                    result.updateValue(avatarId, forKey: username)
                }
                
                return result
            }
            .sink { [weak self] data in
                self?.avatarIds = data
            }
            .store(in: &cancellables)
    }
    
    func fetchComments() {
        dataFetchable.fetchApi("/comment/" + postId + "?page=1")
            .receive(on: DispatchQueue.main)
            .decode(type: [CommentResponse].self, decoder: JSONDecoder())
            .map { data -> (comments: [Comment], users: [String]) in
                var comments = [Comment]()
                var users = [String]()
                
                for comment in data {
                    comments.append(Comment(id: comment.id, textBlock: TextBlock(ownerUsername: comment.ownerUsername, postTime: Date(timeIntervalSince1970: comment.postTime/1000), lastEditTime: Date(timeIntervalSince1970: comment.lastEditTime/1000), content: comment.content, likeUsers: comment.likeUsers, dislikeUsers: comment.dislikeUsers), postId: comment.postId))
                    
                    if users.contains(comment.ownerUsername) {
                        continue
                    }
                    
                    users.append(comment.ownerUsername)
                }
                
                return (comments, users)
            }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    self.accountDetialService.fetchAccount(usernames: self.usernames)
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] data, users in
                self?.comments += data
                self?.usernames += users
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
