//
//  AccountRegisterView.swift
//  Forum
//
//  Created by Frank V on 2022/4/7.
//

import SwiftUI

struct AccountRegisterView: View {
    @StateObject private var viewModel: AccountRegisterViewModel
    @State private var errorMessage = " "
    
    @State private var registerAlertPoped = false
    @Binding private var isRegisterViewPoped: Bool
    
    private enum Field: Hashable {
        case EMAIL, USERNAME, PASSWORD
    }
    
    @FocusState private var focusedField: Field?
    
    init(dataFetchable: DataFetchable, isRegisterViewPoped: Binding<Bool>) {
        self._viewModel = StateObject(wrappedValue: AccountRegisterViewModel(dataFetchable: dataFetchable))
        self._isRegisterViewPoped = isRegisterViewPoped
    }
    
    var body: some View {

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
                .onSubmit {
                    focusedField = .USERNAME
                }
                .focused($focusedField, equals: .EMAIL)
            
            TextField("username", text: $viewModel.username)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.default)
                .submitLabel(.return)
                .onSubmit {
                    focusedField = .PASSWORD
                }
                .focused($focusedField, equals: .USERNAME)
            
            SecureField("password", text: $viewModel.password)
                .padding()
                .background(.regularMaterial)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .keyboardType(.default)
                .submitLabel(.return)
                .focused($focusedField, equals: .PASSWORD)
            
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
            .padding(.bottom, 20)
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                focusedField = .EMAIL
            }
        }
    }
}

//struct AccountRegisterView_Previews: PreviewProvider {
//    static var previews: some View {
//        AccountRegisterView()
//    }
//}
