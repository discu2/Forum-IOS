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
    
    init(username: String, roleIds: [String], nickname: String) {
        self.id = UUID().uuidString
        self.username = username
        self.roleIds = roleIds
        self.nickname = nickname
    }
}
