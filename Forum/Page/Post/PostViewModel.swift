//
//  PostViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import SwiftUI
import Combine

class PostViewModel: ObservableObject {
    @Published var topicId: String? = nil
    @Published private(set) var posts: [Post] = []
    @Published private(set) var avatarIds = [String:String]()
    
    @Dependencies.InjectObject
    private var dataFetchable: DataFetchable
    
    @Dependencies.InjectObject
    private var accountDetailService: AccountDetailService
    
    private var cancellables = Set<AnyCancellable>()
    
    var usernames = [String]()
    
    init() {
        topicIdListener()
        accountsListener()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func topicIdListener() {
        
        $topicId
            .sink { [weak self] (data) in
                guard let self = self, let data = data, self.topicId != data else {
                    return
                }
                
                self.posts = []
                self.fetchPosts(data, page: 1)
            }
            .store(in: &cancellables)
    }
    
    func accountsListener() {
        accountDetailService.$accounts
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
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
    
    func fetchPosts(_ topicId: String, page: Int) {
        
        let endPointString = "/post/" + topicId + "?page=" + page.description
        
        dataFetchable.fetchApi(endPointString)
            .receive(on: DispatchQueue.main)
            .decode(type: [TopicResponse].self, decoder: JSONDecoder())
            .map { data -> (post: [Post], users: [String]) in
                var posts = [Post]()
                var users = [String]()
                
                for p in data {
                    let textblock = TextBlock(ownerUsername: p.ownerUsername, postTime: Date(timeIntervalSince1970: p.postTime/1000), lastEditTime: Date(timeIntervalSince1970: p.lastEditTime/1000), content: p.content, likeUsers: p.likeUsers, dislikeUsers: p.dislikeUsers)
                    posts.append(Post(id: p.id, textBlock: textblock, topicId: p.topicId, originPost: p.originPost))
                    
                    if users.contains(p.ownerUsername) { continue }
                    
                    users.append(p.ownerUsername)
                }
                
                return (posts, users)
            }
            .sink { (completion) in
                switch completion{
                case .finished:
                    self.accountDetailService.fetchAccount(usernames: self.usernames)
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] posts, users in
                self?.posts += posts
                self?.usernames += users
                
            }
            .store(in: &cancellables)
        
    }
    
    struct TopicResponse: Decodable {
        let id: String
        let ownerUsername: String
        let postTime: Double
        let lastEditTime: Double
        let content: String
        let likeUsers: [String]
        let dislikeUsers: [String]
        let topicId: String
        let originPost: Bool
    }
}
