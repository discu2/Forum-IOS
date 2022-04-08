//
//  Topic.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import Foundation

struct Topic: Identifiable {
    let id: String
    let ownerUsername: String
    var title: String
    var lastPostUsername: String
    let postTime: Date
    let lastPostTime: Date
    let pinned: Bool
}
