//
//  LocalAccountView.swift
//  Forum
//
//  Created by Frank V on 2022/3/14.
//

import SwiftUI

struct LocalAccountView: View {
    @StateObject private var viewModel: LocalAccountViewModel
    
    init(dataFetchable: DataFetchable, authManager: AuthManager) {
        self._viewModel = StateObject(wrappedValue: LocalAccountViewModel(dataFetchable: dataFetchable, authManager: authManager))
    }
    
    var body: some View {
        
        VStack {
            if !viewModel.isLoggedIn {
                LoginView()
            } else {
                ProfileView()
            }
        }
        .environmentObject(viewModel)
        
    }
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegisterViewPoped = false
    @EnvironmentObject private var viewModel: LocalAccountViewModel
    
    var body: some View {
        
        Button("Register") {
            isRegisterViewPoped.toggle()
        }
        .popover(isPresented: $isRegisterViewPoped) {
            AccountRegisterView(dataFetchable: viewModel.dataFetchable, isRegisterViewPoped: $isRegisterViewPoped)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
        
        Spacer()
        
        VStack {
            Text("Login").font(.title).bold().padding(.bottom)
            
            Text(viewModel.errorMessage ?? " ").font(.callout).foregroundColor(Color.red)
            
            TextField("username", text: $username)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.return)
            
            SecureField("password", text: $password)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 60)
                .keyboardType(.default)
                .submitLabel(.go)
                .onSubmit {
                    viewModel.login(username: username, password: password)
                }
        }
        .padding(38)
        
        Spacer()
    }
}

struct ProfileView: View {
    @EnvironmentObject private var viewModel: LocalAccountViewModel
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "http://localhost:8080/account/" + (viewModel.account?.username ?? "") + "/profile_pic?size=1")) { phase in
                if let image = phase.image {
                    image.resizable()
                } else {
                    Color.gray
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            
            Text(viewModel.account != nil ? viewModel.account!.nickname : "some text")
                .font(.title)
                .bold()
            
            Button {
                viewModel.logout()
            } label: {
                Text("Logout")
                    .padding(10)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(7)
            }
        }
        .redacted(reason: viewModel.account == nil ? .placeholder : [])
    }
}

//struct AccountView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocalAccountView(dataFetchable: ApiService(urlString: ""), authManager: AuthManager())
//        ProfileView()
//    }
//}
