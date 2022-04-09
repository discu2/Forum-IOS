//
//  LazyNavigationView.swift
//  Forum
//
//  Created by Frank V on 2022/4/9.
//

import SwiftUI

struct LazyNavigationView<Content: View>: View {
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
