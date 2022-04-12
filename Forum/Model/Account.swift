//
//  Account.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import Foundation

struct Account: Identifiable, Decodable {
    let id: String
    let username: String
    var roleIds: [String]
    var nickname: String
    var avatarIds: [String:String]
    
    init(username: String, roleIds: [String], nickname: String, avatarIds: [String:String]) {
        self.id = UUID().uuidString
        self.username = username
        self.roleIds = roleIds
        self.nickname = nickname
        self.avatarIds = avatarIds
    }
}
