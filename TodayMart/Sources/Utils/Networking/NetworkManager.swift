//
//  NetworkManager.swift
//  TodayMart
//
//  Created by Gilwan Ryu on 2019/11/25.
//  Copyright © 2019 Ry. All rights reserved.
//

import UIKit
import Alamofire

typealias DictionaryType = [String: Any]
typealias HeadersType = [String: String]

class NetworkManager {
    // API Call
    static func request(method: HTTPMethod, reqURL: String, parameters: DictionaryType, headers: HeadersType, failed: ((String) -> (Void))? = nil, success: @escaping ((Data) -> (Void))) {
        
        #if DEBUG
        print("전송 URL :",reqURL)
        print("전송 파라미터 :",parameters)
        print("전송 헤더 :",headers)
        #endif
        
        Alamofire.request(reqURL, method: method, parameters: parameters,
                          encoding: method == .get ? URLEncoding(destination: .methodDependent) : JSONEncoding.default,
                          headers: headers).validate().responseData{ response in
                            switch response.result{
                            case .success:
                                if let data = response.data {
                                    success(data)
                                }
                            case .failure:
                                failed?(response.error!.localizedDescription)
                                print("error : \(response.error!.localizedDescription)")
                            }
        }
    }
}

struct Api {
    private static let baseUrl = "http://49.247.138.18"
    
    struct User {
        static let login = "\(baseUrl)/login"
    }
    
    struct Mart {
        static let getAll = "\(baseUrl)/mart"
        static let search = "\(baseUrl)/search"
    }
    
    struct Favorite {
        static let getAll = "\(baseUrl)/favorite"
        static let current = "\(baseUrl)/favorite"
    }
}
