//
//  MainView.swift
//  Todoer
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

struct TopicListView: View {
    @State var boardId: String
    @State var boardName: String
    @State var page = 1
    @StateObject private var viewModel = TopicListViewModel(dataFetchable: ApiService.apiService)
    
    
    var body: some View {
        List(viewModel.topics.indices, id: \.self) { index in
            HStack {
                TopicView(title: viewModel.topics[index].title, lastPostTime: viewModel.topics[index].lastPostTime, formatter: $viewModel.dateFormatter)
                NavigationLink(destination: PostView(title: viewModel.topics[index].title, topicId: viewModel.topics[index].id)) {
                    
                    EmptyView()
                }
                .frame(width: 0)
                .opacity(0)
            }
            .onAppear {
                if index == viewModel.topics.count-1 {
                    page+=1
                    viewModel.fetchTopics(boardId, page: page)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitle(boardName)
        .refreshable {
            page = 1
            viewModel.refresh(boardId)
        }
        .onAppear{
            viewModel.fetchTopics(boardId)
        }
    }
}

struct TopicView: View {
    var title: String
    var lastPostTime: Date
    @Binding var formatter: DateFormatter
    
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
