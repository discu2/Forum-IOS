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
    var tokenService: TokenService? { get set }
    
    var tokenServicePublisher: Published<TokenService?>.Publisher { get }
    
    func fetchApi<T: Encodable, C: Decodable>(_ endPointString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error>
    
    func fetchApi<T: Encodable>(_ endPointString: String, method: String ,requestPackage: T) -> Future<NoResponse?, Error>
    
    func fetchApi<C: Decodable>(_ endPointString: String, responsePackageType: C.Type) -> Future<C?, Error>
    
    func enableAuth() throws -> Void
    
    func disableAuth() -> Void
}
