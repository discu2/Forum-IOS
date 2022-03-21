//
//  DataFetchable.swift
//  Forum
//
//  Created by Frank V on 2022/3/17.
//

import Foundation
import Combine

protocol DataFetchable {
    func fetchApi<T: Encodable, C: Decodable>(uriString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error>
    
    func fetchApi<C: Decodable>(uriString: String, responsePackageType: C.Type) -> Future<C?, Error>
}