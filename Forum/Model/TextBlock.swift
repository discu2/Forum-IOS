//
//  TextBlock.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import Foundation

struct TextBlock {
    
    let ownerUsername: String
    let postTime: Date
    var lastEditTime: Date
    var content: String
    var likeUsers: [String]
    var dislikeUsers: [String]
    
}

struct Post: Identifiable {
    let id: String
    let textBlock: TextBlock
    let topicId: String
    let originPost: Bool
}

struct Comment: Identifiable {
    let id: String
    let textBlock: TextBlock
    let topicId: String
}
