//
//  ForumNavBarView.swift
//  Forum
//
//  Created by Frank V on 2022/3/7.
//

import SwiftUI

struct ForumNavBarView: View {
    @State private var title: String = ""
    @State private var showBackIcon: Bool = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(_ title: String, showBackIcon: Bool) {
        self.title = title
        
        self.showBackIcon = showBackIcon
    }
    
    var body: some View {
        HStack{
            Button(action: {
                
            }, label: {
                
                if showBackIcon {
                    Image(systemName: "chevron.left")
                }
                
                Text(title)
                    .font(/*@START_MENU_TOKEN@*/.title3/*@END_MENU_TOKEN@*/)
                //.foregroundColor(Color.black)
                
            })
        }
        .padding(10)
        .accentColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.ignoresSafeArea(edges: .top))
    }
}

struct ForumNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ForumNavBarView("test title", showBackIcon: true)
            Spacer()
        }
        
    }
}
