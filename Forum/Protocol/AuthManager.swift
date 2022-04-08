//
//  AuthManager.swift
//  Forum
//
//  Created by Frank V on 2022/4/4.
//

import Foundation

protocol AuthManager {
    func login(username: String, password: String, onFinished: @escaping () -> Void, onFaild: @escaping (Error) -> Void) -> Void
    
    func login(username: String, password: String, onFinished: @escaping () -> Void) -> Void
    
    func login(username: String, password: String) -> Void
    
    func logout(action: () -> Void) -> Void
}
