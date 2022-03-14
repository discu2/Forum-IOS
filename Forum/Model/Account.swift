//
//  Account.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import Foundation

struct Account: Identifiable {
    let id: String
    let username: String
    var roles: [String]
    var nickName: String
}
