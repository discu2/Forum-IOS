//
//  ApiUtil.swift
//  Forum
//
//  Created by Frank V on 2022/3/16.
//

import Foundation

func fetchApi<T: Encodable, C: Decodable>(urlString: String, method: String ,requestPackage: T, responsePackageType: C.Type , completion: @escaping (_ data: C?) -> Void) {
    guard let url = URL(string: urlString) else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let data = try? JSONEncoder().encode(requestPackage)
    request.httpBody = data
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        
        if let data = data {
            do {
                let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                
                completion(decoded)
            } catch {
                print(error)
            }
        }
    }.resume()
    
}

func fetchApi<C: Decodable>(urlString: String, responsePackageType: C.Type , completion: @escaping (_ data: C?) -> Void) {
    guard let url = URL(string: urlString) else {
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        
        if let data = data {
            do {
                let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                completion(decoded)
            } catch {
                print(error)
            }
        }
    }.resume()
    
}
