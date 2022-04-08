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
    
    let dataFetchable: DataFetchable
    
    private var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
        
        topicIdListener()
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
    
    func fetchPosts(_ topicId: String, page: Int) {
        
        let endPointString = "/post/" + topicId + "?page=" + page.description
        
        dataFetchable.fetchApi(endPointString)
            .receive(on: DispatchQueue.main)
            .decode(type: [TopicResponse].self, decoder: JSONDecoder())
            .sink { (completion) in
                switch completion{
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] (data) in
                guard let self = self else {
                    return
                }
                
                var posts = [Post]()
                
                for p in data {
                    let textblock = TextBlock(ownerUsername: p.ownerUsername, postTime: Date(timeIntervalSince1970: p.postTime/1000), lastEditTime: Date(timeIntervalSince1970: p.lastEditTime/1000), content: p.content, likeUsers: p.likeUsers, dislikeUsers: p.dislikeUsers)
                    posts.append(Post(id: p.id, textBlock: textblock, topicId: p.topicId, originPost: p.originPost))
                }
                
                self.posts += posts
                
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
