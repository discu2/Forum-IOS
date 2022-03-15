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
        
        NavigationView {
            if viewModel.refreshToken == "" {
                LoginView()
            } else {
                ProfileView()
            }
        }.environmentObject(viewModel)
        
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
                login()
                
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
    
    func login() {
        DispatchQueue.main.async {
            viewModel.login(username: username, password: password)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var viewModel: LocalAccountViewModel
    
    var body: some View {
        VStack {
            //            Image("x")
            //                .resizable()
            //                .frame(width: 120, height: 120)
            //                .clipShape(Circle())
            
            Text(viewModel.account != nil ? viewModel.account!.nickname : "some text")
                .font(.title)
                .bold()
            
            Button(action: { viewModel.logout() }) {
                Text("Logout")
                    .padding(10)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(7)
            }
        }
        .onAppear( perform: {
            if viewModel.account == nil {
                viewModel.fetchAccountData(accountId: viewModel.accountId)
            }
            
            
        })
        .redacted(reason: viewModel.account == nil ? .placeholder : [])
        
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAccountView()
        //ProfileView()
    }
}
