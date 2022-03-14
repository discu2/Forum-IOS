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
                    GroupView(group: item, boards: viewModel.boards[item] ?? [])
                }
                .listStyle(.plain)
                Spacer()
            }
            .navigationBarTitle("Boards")
        }
        
        .navigationViewStyle(.stack)
        .onAppear(perform: { viewModel.updateBoards() })
        
    }
}

struct GroupView: View {
    @State var group: String
    @State var boards: [Board] = []
    @State var expanded = false
    
    var body: some View {
        
        DisclosureGroup(group, isExpanded: $expanded) {
            ForEach(boards, id: \.id) { board in
                HStack {
                    Text(board.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    NavigationLink(destination: TopicListView(boardId: board.id, boardName: board.name)) {
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