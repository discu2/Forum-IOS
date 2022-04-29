//
//  EditorViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/4/28.
//

import SwiftUI
import Combine

class EditorViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var title: String = ""
    let boardId: String
    
    @Dependencies.InjectObject
    var dataFetchable: DataFetchable
    
    var cancellable = Set<AnyCancellable>()
    
    init(boardId: String) {
        self.boardId = boardId
    }
    
    func fetchPost() {
        dataFetchable.fetchApi("/topic/\(boardId)", method: "POST", requestPackage: PostRequest(title: title, content: content))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellable)
    }
    
    struct PostRequest: Codable{
        let title: String
        let content: String
    }
}
