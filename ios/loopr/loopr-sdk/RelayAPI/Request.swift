//
//  Request.swift
//  loopr-ios
//
//  Created by Xiao Dou Dou on 2/4/18.
//  Copyright © 2018 Loopring. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import SwiftyJSON
import SVProgressHUD

public typealias CompletionHandler = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

class Request {
    
    static var hasNetworkErrorBannerShown: Bool = false
    static let banner = NotificationBanner.generate(title: "Network Error", style: .warning)
    
    static func post(body: JSON, url: URL, showFailureBannerNotification: Bool = false, completionHandler: @escaping CompletionHandler) {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.timeoutInterval = 30

        do {
            try request.httpBody = body.rawData()
        } catch {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                                // is there data
                let httpResponse = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= httpResponse.statusCode,         // is statusCode 2XX
                error == nil else {                               // was there no error, otherwise ...
                print("error=\(String(describing: error))")
                if showFailureBannerNotification {
                    DispatchQueue.main.async {
                        if !banner.isDisplaying && !hasNetworkErrorBannerShown {
                            banner.duration = 10.0
                            banner.show()
                            hasNetworkErrorBannerShown = true
                        }
                        SVProgressHUD.dismiss()
                    }
                }
                completionHandler(nil, response, error)
                return
            }
            completionHandler(data, response, error)
        }
        task.resume()
    }
    
    static func get(_ url: String, parameters: [String: String], completionHandler: @escaping CompletionHandler) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.timeoutInterval = 30

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                                // is there data
                let httpResponse = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= httpResponse.statusCode,         // is statusCode 2XX
                error == nil else {                               // was there no error, otherwise ...
                    completionHandler(nil, response, error)
                    return
            }
            completionHandler(data, response, error)
        }
        task.resume()
    }
    
    static func delete(_ url: String, parameters: [String: String], completionHandler: @escaping CompletionHandler) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 30

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let httpResponse = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= httpResponse.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    completionHandler(nil, response, error)
                    return
            }
            completionHandler(data, response, error)
        }
        task.resume()
    }
}
