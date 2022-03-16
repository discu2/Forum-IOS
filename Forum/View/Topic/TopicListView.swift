//
//  MainView.swift
//  Todoer
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

struct TopicListView: View {
    //@State var show = false
    @State var boardId: String
    @State var boardName: String
    @StateObject private var viewModel = TopicListViewModel()
    
    
    var body: some View {
        List(viewModel.topics, id: \.id) { item in
            HStack {
                TopicView(title: item.title, lastPostTime: item.lastPostTime, formatter: viewModel.dateFormatter)
                NavigationLink(destination: PostView(title: item.title, topicId: item.id)) {
                    
                    EmptyView()
                }
                .frame(width: 0)
                .opacity(0)
            }
        }
        .listStyle(.plain)
        .navigationBarTitle(boardName)
        .onAppear(perform: {viewModel.updateTopics(boardId)})
    }
}

struct TopicView: View {
    var title: String
    var lastPostTime: Date
    var formatter: DateFormatter
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text(title).font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(formatter.string(from: lastPostTime))
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
}


struct TopicListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TopicListView(boardId: "aasojd", boardName: "Preview Name")
        }
    }
}
