//
//  BoardViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI

class BoardViewModel: ObservableObject {
    @Published var groups: [String] = []
    @Published var boards: [String: [Board]] = [:]
    
    init(){}
    
    func updateBoards() {
        groups.removeAll()
        boards.removeAll()
        
        for item in testBoard {
            
            if var c = boards[item.groupName] {
                				
                c.append(item)
                boards.updateValue(c, forKey: item.groupName)
                
            } else {
                boards.updateValue([item], forKey: item.groupName)
            }
        }
        
        groups.append(contentsOf: boards.keys)
        groups.sort()
    }
    
    let testBoard = [
        Board(id: "ad390jfijocs", name: "Test Board", groupName: "Test group"),
        Board(id: "ad390jfid8jo", name: "Test Board2", groupName: "Test group"),
        Board(id: "adrw934jfijo", name: "Test Board3", groupName: "Test group1"),
        Board(id: "ad0jregerifjo", name: "Test Board4", groupName: "Test group3")
    ]
}
