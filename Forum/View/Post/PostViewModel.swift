//
//  PostViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import SwiftUI

class PostViewModel: ObservableObject {
    var topicId: String?
    @Published var posts: [Post] = []
    
    init() {}
    
    func updatePosts(_ topic: String) {
        posts = testPosts
    }
    
    var testPosts: [Post] = [
        Post(id: "1h84921fhfdfeo24f", textBlock: TextBlock(ownerId: "aef", username: "testname", postTime: Date.now, lastEditTime: Date.now, content: "this is my text post", likeUserIds: [], dislikeUserIds: [])
             , topicId: "1h84921fho24f", originPost: true),
        
        Post(id: "1h84921fhfdfeo24fg", textBlock: TextBlock(ownerId: "aef", username: "testname", postTime: Date.now, lastEditTime: Date.now, content: "this is my text reply", likeUserIds: [], dislikeUserIds: [])
             , topicId: "1h84921fho24f", originPost: false)
    ]
}
