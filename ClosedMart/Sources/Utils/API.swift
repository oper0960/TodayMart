//
//  URLRequest.swift
//  ClosedMart
//
//  Created by Gilwan Ryu on 2018. 6. 8..
//  Copyright © 2018년 Ry. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class API {
    class func getRequest(url: String, parameters: [String: Any], headers: [String: String], completion: @escaping (Data?, Error?) -> () ) {
        
        let urlComponents = URLComponents(string: url)
        guard var components = urlComponents else { return }
        
        components.queryItems = parameters.map { (item) -> URLQueryItem in
            return URLQueryItem(name: item.key, value: item.value as? String)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: components.url!)
        
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue(AppDelegate.kakaoAPIKEY, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                completion(nil, error)
            } else {
                guard let usableData = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    return
                }
                completion(usableData, nil)
            }
        }
        task.resume()
    }

    class func postRequest(url: String, parameters: [String: Any], completionHandler: @escaping (Data?, URLResponse?, Error?)->() ) {
        
        let session = URLSession(configuration: .default)
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = HTTPMethod.post.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            return
        }
        session.dataTask(with: request, completionHandler: completionHandler)
    }
}
