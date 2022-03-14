//
//  TextBlock.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import Foundation

struct TextBlock {
    
    let ownerId: String
    let username: String
    let postTime: Date
    var lastEditTime: Date
    var content: String
    var likeUserIds: [String]
    var dislikeUserIds: [String]
    
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
