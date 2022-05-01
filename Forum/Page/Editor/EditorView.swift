//
//  EditorView.swift
//  Forum
//
//  Created by Frank V on 2022/4/28.
//

import SwiftUI

struct EditorView: View {
    @StateObject var viewModel: EditorViewModel
    @Environment(\.presentationMode) var presentationMode
    @FocusState var isInputActive: Bool
    
    @State var isDismissAlertPop = false
    @State var isErrorAlertPop = false
    
    let hasTitle: Bool
    
    init(boardId: String, hasTitle: Bool) {
        self._viewModel = StateObject(wrappedValue: EditorViewModel(boardId: boardId))
        self.hasTitle = hasTitle
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if hasTitle {
                    TextField("Title", text: $viewModel.title)
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 3).stroke(.secondary, lineWidth: 2))
                        .padding(5)
                        .padding(.bottom, 5)
                        .focused($isInputActive)
                }
                
                TextEditor(text: $viewModel.content)
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 3).stroke(.secondary, lineWidth: 2))
                    .padding(.horizontal, 5)
                    .padding(.bottom, 5)
                    .focused($isInputActive)
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isDismissAlertPop.toggle()
                        
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.fetchPost()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("Done") {
                        isInputActive = false
                    }
                }
                
            }
            .alert("Are you sure you want to leave editor?", isPresented: $isDismissAlertPop) {
                Button("Yes", role: .destructive) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(boardId: "", hasTitle: true)
    }
}
