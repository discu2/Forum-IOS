//
//  AccountRegisterViewModel.swift
//  Forum
//
//  Created by Frank V on 2022/4/7.
//

import SwiftUI
import Combine

class AccountRegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    
    @Published var readyToRegister = false
    
    let dataFetchable: DataFetchable
    
    var cancellables = Set<AnyCancellable>()
    
    let mailRegex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,6}$", options: .caseInsensitive)
    let passwordRegex = try! NSRegularExpression(pattern: "^(?=.*[0-9])(?=.*[A-Z])(?=\\S+$).{8,64}$", options: .caseInsensitive)
    let usernameRegex = try! NSRegularExpression(pattern: "^[A-Z0-9._].{4,16}$", options: .caseInsensitive)
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
        
        readyRegisterListener()
    }
    
    func readyRegisterListener() {
        $email
            .debounce(for: 1.5, scheduler: DispatchQueue.main)
            .combineLatest($username, $password)
            .compactMap { [weak self] mail, username, password in
                guard let self = self else { return false }
                
                return (self.mailRegex.firstMatch(in: mail, range: NSRange(location: 0, length: mail.count)) != nil) &&
                (self.usernameRegex.firstMatch(in: username, range: NSRange(location: 0, length: username.count)) != nil) &&
                (self.passwordRegex.firstMatch(in: password, range: NSRange(location: 0, length: password.count)) != nil)
            }
            .sink { [weak self] result in
                self?.readyToRegister = result
            }
            .store(in: &cancellables)

    }
    
    func register(vmCompletion: @escaping (Error?) -> Void) {
        dataFetchable.fetchApi("/account/register", method: "POST", requestPackage: RegisterRequest(mail: email, username: username, password: password))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    vmCompletion(nil)
                case .failure(let error):
                    vmCompletion(error)
                    print(error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)

    }
    
    struct RegisterRequest: Encodable {
        let mail: String
        let username: String
        let password: String
    }
}
