//
//  AccountRegisterView.swift
//  Forum
//
//  Created by Frank V on 2022/4/7.
//

import SwiftUI

struct AccountRegisterView: View {
    @StateObject var viewModel: AccountRegisterViewModel
    @State var errorMessage = " "
    
    @State var registerAlertPoped = false
    @Binding var isRegisterViewPoped: Bool
    
    init(dataFetchable: DataFetchable, isRegisterViewPoped: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: AccountRegisterViewModel(dataFetchable: dataFetchable))
        self._isRegisterViewPoped = isRegisterViewPoped
    }
    
    var body: some View {
        Button {
            isRegisterViewPoped.toggle()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        
        Spacer()
        
        VStack {
            Text("Register").font(.title).bold().padding(.bottom)
            
            Text(errorMessage)
                .font(.callout)
                .foregroundColor(Color.red)
            
            TextField("email", text: $viewModel.email)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.return)
            
            TextField("username", text: $viewModel.username)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .submitLabel(.return)
            
            SecureField("password", text: $viewModel.password)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .keyboardType(.default)
                .submitLabel(.return)
            
            Button {
                viewModel.register { error in
                    if error != nil {
                        errorMessage = "Failed to register"
                    } else {
                        registerAlertPoped = true
                    }
                }
            } label: {
                Image(systemName: "arrow.right")
                    .frame(width: 32, height: 32)
            }
            .padding(.bottom, 60)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.readyToRegister)
            .alert("Register succeced!", isPresented: $registerAlertPoped) {
                Button("OK") {
                    registerAlertPoped = false
                    isRegisterViewPoped = false
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .padding(38)
        
        Spacer()
    }
}

//struct AccountRegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountRegisterView()
//    }
//}
