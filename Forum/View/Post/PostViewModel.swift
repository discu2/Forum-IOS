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
    @Published var posts: [Post] = []
    
    let dataFetchable: DataFetchable
    
    var cancellable = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
        
        topicIdListener()
    }
    
    deinit {
        cancellable.forEach { c in
            c.cancel()
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
            .store(in: &cancellable)
    }
    
    func fetchPosts(_ topicId: String, page: Int) {
        
        let uriString = "/post/" + topicId + "?page=" + page.description
        
        dataFetchable.fetchApi(uriString: uriString, responsePackageType: [TopicResponse].self)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] (data) in
                guard let self = self, let data = data else {
                    return
                }
                
                var posts: [Post] = []
                
                for p in data {
                    let textblock = TextBlock(ownerUsername: p.ownerUsername, postTime: Date(timeIntervalSince1970: p.postTime/1000), lastEditTime: Date(timeIntervalSince1970: p.lastEditTime/1000), content: p.content, likeUsers: p.likeUsers, dislikeUsers: p.dislikeUsers)
                    posts.append(Post(id: p.id, textBlock: textblock, topicId: p.topicId, originPost: p.originPost))
                }
                
                self.posts += posts
                
            }
            .store(in: &cancellable)
        
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
