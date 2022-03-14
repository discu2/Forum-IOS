//
//  LocalAccountView.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI

struct LocalAccountView: View {
    @StateObject private var viewModel = LocalAccountViewModel()
    
    var body: some View {
        if viewModel.refreshToken == "" {
            LoginView().environmentObject(viewModel)
        } else {
            Text(viewModel.refreshToken)
        }
        
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMsg = ""
    @EnvironmentObject var viewModel: LocalAccountViewModel
    
    var body: some View {
        VStack {
            Text("Login").font(.title).bold().padding(.bottom)
            TextField("username", text: $username)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .keyboardType(.namePhonePad)
            SecureField("password", text: $password)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            Button(action: {
                viewModel.login(username: username, password: password)
                
            }) {
                Text("Login")
                    .padding(10)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(7)
            }
        }
        .padding(38)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAccountView()
    }
}
