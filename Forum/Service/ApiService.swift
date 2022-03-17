//
//  ApiService.swift
//  Forum
//
//  Created by Frank V on 2022/3/16.
//

import Foundation
import Combine

class ApiService {
    
    public static let apiService = ApiService()
    
    func fetchApi<T: Encodable, C: Decodable>(urlString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONEncoder().encode(requestPackage)
        request.httpBody = data
        
        return Future { promise in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if code == 200 {
                    
                    if let data = data {
                        do {
                            let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                            
                            promise(.success(decoded))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                } else {
                    promise(.failure(NSError(domain: urlString, code: code)))
                }
                
            }.resume()
            
        }
    }
    
    func fetchApi<C: Decodable>(urlString: String, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString)!
        
        return Future { promise in
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if code == 200 {
                    
                    if let data = data {
                        do {
                            let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                            promise(.success(decoded))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                    
                } else {
                    promise(.failure(NSError(domain: urlString, code: code)))
                }
            }.resume()
            
        }
    }
}
