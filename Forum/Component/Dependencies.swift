//
//  ContentView.swift
//  swift-native-dependency-injection
//
//  Created by 陳囿豪 on 2020/6/27.
//  Copyright © 2020 陳囿豪. All rights reserved.
//
//  Source: https://github.com/yasuoyuhao/swift-native-dependency-injection
//  License: https://github.com/yasuoyuhao/swift-native-dependency-injection/blob/master/LICENSE

enum Dependencies {
    struct NameSpace: Equatable {
        let rawValue: String
        static let main = NameSpace(rawValue: "__default_name_space__")
        static func === (lhs: NameSpace, rhs: NameSpace) -> Bool { lhs.rawValue == rhs.rawValue }
    }
    
    final class Container {
        private var dependencies: [(key: Dependencies.NameSpace, value: Any)] = []
        
        static let main = Container()
        
        func register(_ dependency: Any, for key: Dependencies.NameSpace = .main) {
            dependencies.append((key: key, value: dependency))
        }
        
        func unRegisterAll() {
            dependencies.removeAll()
        }
        
        func resolve<T>(_ key: Dependencies.NameSpace = .main) -> T {
            return (dependencies
                .filter { (dependencyTuple) -> Bool in
                    return dependencyTuple.key === key
                        && dependencyTuple.value is T
            }
                .first)?.value as! T // swiftlint:disable:this force_cast
        }
    }
    
    @propertyWrapper
    struct InjectObject<T> {
        private let dNameSpace: NameSpace
        private let container: Container
        var wrappedValue: T {
            get { container.resolve(dNameSpace) }
        }
        
        init(_ dNameSpace: NameSpace = .main, on container: Container = .main) {
            self.dNameSpace = dNameSpace
            self.container = container
        }
    }
}
