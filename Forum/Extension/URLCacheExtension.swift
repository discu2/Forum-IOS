//
//  URLCacheExtension.swift
//  Forum
//
//  Created by Frank V on 2022/4/11.
//

import Foundation

extension URLCache {
    static let accountAvatarCache = URLCache(memoryCapacity: 10*1000*1000, diskCapacity: 300*1000*1000)
}
