//
//  ApiService.swift
//  Forum
//
//  Created by Frank V on 2022/3/16.
//

import Foundation
import Combine

class ApiService: DataFetchable {
    
    let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
    private func sessionHandler<C: Decodable>(data: Data?, response: URLResponse?, error: Error?, responsePackageType: C.Type, promise: Future<C?, Error>.Promise) {
        
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        
        if code != 200 {
            promise(.failure(NSError(domain: "", code: code)))
            return
        }
            
        if let data = data {
            do {
                let decoded = try JSONDecoder().decode(responsePackageType, from: data)
                promise(.success(decoded))
            } catch {
                promise(.failure(error))
            }
            
            return
        }
        
        promise(.success(nil))
    }
    
    func fetchApi<T: Encodable, C: Decodable>(_ endPointString: String, method: String ,requestPackage: T, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString + endPointString)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try? JSONEncoder().encode(requestPackage)
        request.httpBody = data
        
        return Future { [weak self] promise in
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, responsePackageType: responsePackageType, promise: promise)
            }.resume()
            
        }
    }
    
    
    func fetchApi<C: Decodable>(_ endPointString: String, responsePackageType: C.Type) -> Future<C?, Error> {
        
        let url = URL(string: urlString + endPointString)!
        
        return Future { [weak self] promise in
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let self = self else { return }
                self.sessionHandler(data: data, response: response, error: error, responsePackageType: responsePackageType, promise: promise)
            }.resume()
            
        }
    }
}
