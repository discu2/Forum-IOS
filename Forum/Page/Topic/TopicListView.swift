//
//  TopicListView.swift
//  Forum
//
//  Created by Frank V on 2022/3/5.
//

import SwiftUI

struct TopicListView: View {
    @StateObject private var viewModel = TopicListViewModel()
    @State var boardId: String
    @State var boardName: String
    @State var isEditorPresented = false
    
    var body: some View {
        List(viewModel.topics.indices, id: \.self) { index in
            HStack {
                TopicView(title: viewModel.topics[index].title, lastPostTime: viewModel.topics[index].lastPostTime, formatter: viewModel.dateFormatter)
                
                NavigationLink(destination: LazyNavigationView(PostView(title: viewModel.topics[index].title, topicId: viewModel.topics[index].id))) {
                    
                    EmptyView()
                }
                .frame(width: 0)
                .opacity(0)
            }
            .onAppear {
                if index == viewModel.topics.count-1 {
                    viewModel.fetchNextPage()
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(boardName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isEditorPresented = true
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            viewModel.boardId = boardId
        }
        .fullScreenCover(isPresented: $isEditorPresented) {
            EditorView(boardId: boardId, hasTitle: true)
        }
    }
}

struct TopicView: View {
    let title: String
    let lastPostTime: Date
    let formatter: DateFormatter
    
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
