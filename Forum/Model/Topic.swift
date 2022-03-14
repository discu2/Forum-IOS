//
//  Topic.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import Foundation

struct Topic: Identifiable {
    let id: String
    let owner: String
    var title: String
    let postTime: Date
    let lastPostTime: Date
    //var shortContent: String
}
