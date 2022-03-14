//
//  TopicViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

class TopicListViewModel: ObservableObject {
    @Published var topics: [Topic] = []
    @Published var dateFormatter = DateFormatter()
    
    init() {

        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale.current
        dateFormatter.doesRelativeDateFormatting = true
        
        

        // modifying locale

        dateFormatter.locale = Locale(identifier: "zh_TW")
        //updateTopics("oajsd")
        
       
    }
    
    func updateTopics(_ boardId: String) {
        
        let timeNow = Date.now
        
        topics = [
            Topic(id: "1h84921fho24f", owner: "aa", title: "test1", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test2", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test3", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test4", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test5", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test6", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test7", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test8", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test9", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test10", postTime: timeNow, lastPostTime: timeNow),
            Topic(id: UUID().uuidString, owner: "aa", title: "test11", postTime: timeNow, lastPostTime: timeNow)
        ]
        
    }
    
}
