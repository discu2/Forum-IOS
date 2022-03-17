//
//  BoardViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI
import Combine

class BoardViewModel: ObservableObject {
    @Published var groups: [String] = []
    @Published var boards: [String: [Board]] = [:]
    
    var cancellable = Set<AnyCancellable>()
    
    private let dataFetchable: DataFetchable
    
    init(dataFetchable: DataFetchable){
        self.dataFetchable = dataFetchable
    }
    
    func fetchBoards() {
        
        groups.removeAll()
        boards.removeAll()
        
        var boards: [String: [Board]] = [:]
        var groups: [String] = []
        
        dataFetchable.fetchApi(urlString: "http://localhost:8080/board", responsePackageType: [Board].self)
            .receive(on: DispatchQueue.main)
            .sink { (completion) in
                
                switch completion {
                    
                case .finished:
                    break
                    
                case .failure(let error):
                    print(error)
                    
                }
                
            } receiveValue: { [weak self] (data) in
                guard let self = self else {
                    return
                }
                
                if let data = data {
                    for item in data {
                        if var c = boards[item.groupName] {
                            
                            c.append(item)
                            boards.updateValue(c, forKey: item.groupName)
                            
                        } else {
                            boards.updateValue([item], forKey: item.groupName)
                        }
                    }
                }
                
                groups.append(contentsOf: boards.keys)
                groups.sort()
                
                self.boards = boards
                self.groups = groups
                
            }
            .store(in: &cancellable)
    }
    
}
