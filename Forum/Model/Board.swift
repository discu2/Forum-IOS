//
//  Board.swift
//  Forum
//
//  Created by Frank V on 2022/3/6.
//

import Foundation

struct Board: Identifiable, Decodable {
    static let PERMISSION_ACCESS = "access"
    static let PERMISSION_POST = "post"
    static let PERMISSION_REPLY = "reply"
    static let PERMISSION_COMMENT = "comment"
    static let PERMISSION_EDIT = "edit"
    static let PERMISSION_MODERATOR = "moderator"
    
    let id: String
    var name: String
    var groupName: String
    
    
}
