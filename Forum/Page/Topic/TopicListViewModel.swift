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
    @Published var eof: Bool = false
    
    var refreshing = false
    var page: Int = 1
    
    let dataFetchable: DataFetchable
    var dateFormatter = DateFormatter()
    var cancellables = Set<AnyCancellable>()
    
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
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func refresh() async {
        guard let boardId = boardId else { return }
        
        refreshing = true
        topics.removeAll()
        page = 1
        fetchTopics(boardId)
        
        while(refreshing) {
            try? await Task.sleep(nanoseconds: 10_000_000)
        }
        
    }
    
    func boardIdListener() {
        
        $boardId.sink { [weak self] (data) in
            guard let self = self, let data = data, self.boardId != data else {
                return
            }
            
            self.fetchTopics(data)
        }
        .store(in: &cancellables)
    }
    
    func fetchNextPage() {
        guard !eof, let boardId = boardId else {
            return
        }
        
        page += 1
        fetchTopics(boardId)

    }
    
    func fetchTopics(_ boardId: String) {
        
        dataFetchable.fetchApi("/topic/" + boardId + "?page=" + page.description)
            .receive(on: DispatchQueue.main)
            .decode(type: [TopicResponse].self, decoder: JSONDecoder())
            .sink { [weak self] (completion) in
                switch completion {
                case .finished:
                    self?.refreshing = false
                case .failure(let error):
                    print(error)
                }
                
            } receiveValue: { [weak self] data in
                
                guard let self = self else { return }
                guard data.count > 0 else {
                    self.eof = true
                    return
                }
                
                var topics: [Topic] = []
                
                for r in data {
                    topics.append(Topic(id: r.id, ownerUsername: r.ownerUsername, title: r.title, lastPostUsername: r.lastPosterUsername, postTime: Date(timeIntervalSince1970: r.lastPostTime/1000), lastPostTime: Date(timeIntervalSince1970: r.lastPostTime/1000), pinned: r.pinnedOrder > 0))
                }
                
                if !self.refreshing {
                    self.topics += topics
                    return
                }
                
                self.topics = topics
                
            }
            .store(in: &cancellables)
        
    }
    
    struct TopicResponse: Decodable {
        let id: String
        let boardId: String
        let ownerUsername: String
        let title: String
        let lastPosterUsername: String

        let createTime: Double
        let lastPostTime: Double

        let pinnedOrder: Int;
    }
}
