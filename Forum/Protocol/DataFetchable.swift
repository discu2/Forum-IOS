//
//  DataFetchable.swift
//  Forum
//
//  Created by Frank V on 2022/3/17.
//

import Foundation
import Combine

struct NoResponse: Decodable {}

protocol DataFetchable {
    var urlString: String { get }
    
    var tokenService: TokenService? { get }
    
    var tokenServicePublisher: Published<TokenService?>.Publisher { get }
    
    func fetchApi<T: Encodable>(_ endPointString: String, method: String ,requestPackage: T) -> Future<Data, Error>
    
    func fetchApi(_ endPointString: String) -> Future<Data, Error>
    
    func enableAuth() throws -> Void
    
    func disableAuth() -> Void
}
