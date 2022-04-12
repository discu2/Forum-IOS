//
//  AvatarUtil.swift
//  Forum
//
//  Created by Frank V on 2022/4/11.
//

import Foundation
import Combine

enum AvatarSize:Int {
    case NORMAL = 0
    case MIDIUM = 1
    case SMALL = 2
}

class AccountDetailService {
    
    @Published var accounts = [String:Account?]()
        
    let dataFetchable: DataFetchable
    
    var cancellables = Set<AnyCancellable>()
    
    init(dataFetchable: DataFetchable) {
        self.dataFetchable = dataFetchable
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
    }
    
    func fetchAccount(usernames: [String]) {
        for username in usernames {
            fetchAccount(username: username)
        }
    }
    
    func fetchAccount(username: String) {
        guard !accounts.keys.contains(username) else { return }
        
        accounts.updateValue(nil, forKey: username)
        
        let endPointString = "/account/" + username
        
        dataFetchable.fetchApi(endPointString)
            .receive(on: DispatchQueue.main)
            .decode(type: AccountResponse.self, decoder: JSONDecoder())
            .map { data in
                 Account(username: data.username, roleIds: data.roleIds, nickname: data.nickname, avatarIds: data.avatarIds)
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                    
                case .failure(let error):
                    if self?.accounts[username] == nil {
                        self?.accounts.removeValue(forKey: username)
                    }
                    print(error)
                }
                
            } receiveValue: { [weak self] data in
                self?.accounts.updateValue(data, forKey: username)
            }
            .store(in: &cancellables)
        
    }
    
    struct AccountResponse: Decodable {
        let username: String
        let nickname: String
        let roleIds: [String]
        let avatarIds: [String:String]
    }
}
