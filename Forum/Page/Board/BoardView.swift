//
//  BoardView.swift
//  Forum
//
//  Created by Frank V on 2022/3/8.
//

import SwiftUI

struct BoardView: View {
    @StateObject private var viewModel = BoardViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.groups, id: \.self) { item in
                    GroupView(group: item, boards: viewModel.boards[item] ?? []).environmentObject(viewModel)
                }
                .listStyle(.plain)
                Spacer()
            }
            .navigationTitle("Boards")
            .navigationBarTitleDisplayMode(.automatic)
            .refreshable {
                await viewModel.refresh()
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct GroupView: View {
    let group: String
    let boards: [Board]
    @State private var expanded = false
    @EnvironmentObject private var viewModel: BoardViewModel
    
    var body: some View {
        
        DisclosureGroup(group, isExpanded: $expanded) {
            ForEach(boards, id: \.id) { board in
                HStack {
                    Text(board.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    
                    NavigationLink(destination: LazyNavigationView(TopicListView(boardId: board.id, boardName: board.name))) {
                        
                        EmptyView()
                    }
                    .frame(width: 0)
                    .opacity(0)
                }
            }
        }
    }
    
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .previewInterfaceOrientation(.portrait)
    }
}
