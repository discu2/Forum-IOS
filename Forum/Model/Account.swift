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
    var roles: [String]
    var nickname: String
}
