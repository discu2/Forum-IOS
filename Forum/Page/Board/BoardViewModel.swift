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
    var refreshing = false
    
    var cancellables = Set<AnyCancellable>()
    
    let dataFetchable: DataFetchable
    
    init(dataFetchable: DataFetchable){
        self.dataFetchable = dataFetchable
        
        tokenServiceListener()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func tokenServiceListener() {
        dataFetchable.tokenServicePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchBoards()
            }
            .store(in: &cancellables)
    }
    
    func refresh() async {
        refreshing = true
        fetchBoards()
        
        while(refreshing) {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
    }
    
    func fetchBoards() {
        
        var boards: [String: [Board]] = [:]
        var groups: [String] = []
        
        dataFetchable.fetchApi("/board")
            .receive(on: DispatchQueue.main)
            .decode(type: [Board].self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    
                }
                
                self?.refreshing = false
                
            } receiveValue: { [weak self] data in
                guard let self = self else {
                    return
                }
                
                for item in data {
                    if var c = boards[item.groupName] {
                        c.append(item)
                        boards.updateValue(c, forKey: item.groupName)
                    } else {
                        boards.updateValue([item], forKey: item.groupName)
                    }
                }
                
                groups.append(contentsOf: boards.keys)
                groups.sort()
                
                self.boards = boards
                self.groups = groups
                
            }
            .store(in: &cancellables)
    }
    
}
