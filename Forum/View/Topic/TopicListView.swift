//
//  TopicListView.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

struct TopicListView: View {
    @StateObject var viewModel: TopicListViewModel
    @State var boardId: String
    @State var boardName: String
    
    init(dataFetchable: DataFetchable, boardId: String, boardName: String) {
        self._viewModel = StateObject(wrappedValue: TopicListViewModel(dataFetchable: dataFetchable))
        self.boardId = boardId
        self.boardName = boardName
    }
    
    var body: some View {
        List(viewModel.topics.indices, id: \.self) { index in
            HStack {
                TopicView(title: viewModel.topics[index].title, lastPostTime: viewModel.topics[index].lastPostTime, formatter: viewModel.dateFormatter)
                
                NavigationLink(destination: PostView(dataFetchable: viewModel.dataFetchable, title: viewModel.topics[index].title, topicId: viewModel.topics[index].id)) {
                    
                    EmptyView()
                }
                .frame(width: 0)
                .opacity(0)
            }
            .onAppear {
                if index == viewModel.topics.count-1 {
                    viewModel.page+=1
                    viewModel.fetchTopics(boardId)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitle(boardName)
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear{
            viewModel.boardId = boardId
        }
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
            TopicListView(dataFetchable: ApiService(urlString: ""), boardId: "aasojd", boardName: "Preview Name")
        }
    }
}
