//
//  APIRequest.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/08.
//

import Foundation

enum APIError: Error {
    case responseProblem
    case encodingProblem
    case decodingProblem
}

enum EditStatus: String {
    case editMajor = "update"
    case addkeywords = "info"
    case removeKeywords = "delete"
}

struct APIRequest {
    let resourceURL: URL
    
    init(endpoint: EditStatus) {
        guard let resourceURL = URL(string: "http://3.38.60.57:8001/\(endpoint.rawValue)") else {
            fatalError()
        }
        self.resourceURL = resourceURL
    }
    
    func send(message messageToSend: [String: String], completion: @escaping(Result<String, APIError>) -> Void) {
        do {
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(messageToSend)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in
                // 응답 과정에 문제가 생겼는가
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                      let jsonData = data else {
                    completion(.failure(.responseProblem))
                    return
                }
                if let responseData = String(data: jsonData, encoding: .utf8) {
                    completion(.success(responseData))
                } else {
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        } catch {
            completion(.failure(.encodingProblem))
        }
    }
}
