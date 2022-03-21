//
//  TopicViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI
import Combine

class TopicListViewModel: ObservableObject {
    @Published var boardId: String? = nil
    @Published var topics: [Topic] = []
    var refreshing = false
    var page: Int = 1
    
    let dataFetchable: DataFetchable
    var dateFormatter = DateFormatter()
    var cancellable = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.locale = Locale(identifier: "zh_TW")
        
        self.dataFetchable = dataFetchable
        
        boardIdListener()
       
    }
    
    deinit {
        cancellable.forEach { c in
            c.cancel()
        }
    }
    
    func refresh() async {
        guard let boardId = boardId else { return }
        
        refreshing = true
        topics.removeAll()
        page = 1
        fetchTopics(boardId)
        
        while(refreshing) {
            try? await Task.sleep(nanoseconds: 100000000)
        }
        
    }
    
    func boardIdListener() {
        
        $boardId.sink { [weak self] (data) in
            guard let self = self, let data = data, self.boardId != data else {
                return
            }
            
            self.topics.removeAll()
            self.fetchTopics(data)
        }
        .store(in: &cancellable)
    }
    
    func fetchTopics(_ boardId: String) {
        
        dataFetchable.fetchApi(uriString: "/topic/" + boardId + "?page=" + page.description, responsePackageType: [TopicResponse].self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion) in
                
                switch completion{
                case .finished:
                    self?.refreshing = false
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] (data) in
                
                guard let self = self, let data = data else {
                    return
                }
                
                var topics: [Topic] = []
                
                for r in data {
                    topics.append(Topic(id: r.id, ownerId: r.ownerId, username: r.username, title: r.title, lastPosterId: r.lastPosterId, lastPostUsername: r.lastPosterUsername, postTime: Date(timeIntervalSince1970: r.lastPostTime/1000), lastPostTime: Date(timeIntervalSince1970: r.lastPostTime/1000), pinned: r.pinnedOrder > 0))
                }
                
                self.topics += topics
            }
            .store(in: &cancellable)
        
    }
    
    struct TopicResponse: Decodable {
        let id: String
        let boardId: String
        let ownerId: String
        let username: String
        let title: String
        let lastPosterId: String
        let lastPosterUsername: String

        let createTime: Double
        let lastPostTime: Double

        let pinnedOrder: Int;
    }
}
