//
//  DataFetchable.swift
//  Forum
//
//  Created by Frank V on 2022/3/17.
//

import Foundation
import Combine

protocol DataFetchable {
    var tokenService: TokenService? { get set }
    
    func fetchApi<T: Encodable, C: Decodable>(_ endPointString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error>
    
    func fetchApi<C: Decodable>(_ endPointString: String, responsePackageType: C.Type) -> Future<C?, Error>
    
    func enableAuth(refreshToken: String) throws -> Void
}
