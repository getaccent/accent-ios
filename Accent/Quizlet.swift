//
//  Quizlet.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import SafariServices
import SwiftyJSON
import UIKit

public class Quizlet: NSObject, SFSafariViewControllerDelegate {
    
    private let authToken = "bW5nVDI1QTM2QzphWmtDcDlGZGVHZjRlUDJIOTV3dm03"
    private let clientId = "mngT25A36C"
    
    public class var sharedInstance: Quizlet {
        struct Static {
            static let instance = Quizlet()
        }
        return Static.instance
    }
    
    public var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "QuizletAccessToken")
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "QuizletAccessToken")
        }
    }
    
    public var setId: Int {
        get {
            return UserDefaults.standard.integer(forKey: "QuizletSetID")
        }
        
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: "QuizletSetID")
        }
    }
    
    private var addedTerms = [String]()
    
    private var safariViewController: UIViewController?
    private var state: String?
    
    func addTermToSet(_ term: String, translation: String) {
        guard !addedTerms.contains(term) else {
            return
        }
        
        self.addedTerms.append(term)
        
        guard let accessToken = accessToken else {
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        guard let url = URL(string: "https://api.quizlet.com/2.0/sets/\(setId)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            var storedTerms = [String: String]()
            if let retrievedTerms = json["terms"].array {
                for datum in retrievedTerms {
                    if let term = datum["term"].string, let translation = datum["definition"].string {
                        storedTerms[term] = translation
                    }
                }
            }
            
            guard !storedTerms.keys.contains(term) else {
                return
            }
            
            guard let urlString = "https://api.quizlet.com/2.0/sets/\(self.setId)/terms?term=\(term)&definition=\(translation)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlString) else {
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let task = session.dataTask(with: request) { (data, response, error) in
                guard let _ = data else {
                    return
                }
            }
            
            task.resume()
        }
        
        task.resume()
    }
    
    func beginAuthorization(_ viewController: UIViewController) {
        state = UUID().uuidString
        
        guard let url = URL(string: "https://quizlet.com/authorize?response_type=code&client_id=\(clientId)&scope=read&state=\(state!)&scope=write_set%20read") else {
            return
        }
        
        if #available(iOS 9.0, *) {
            safariViewController = SFSafariViewController(url: url)
            viewController.present(safariViewController!, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func createSet(_ words: [String: String], completion: @escaping (_ url: URL?) -> Void) {
        guard let accessToken = accessToken else {
            return
        }
        
        let url = URL(string: "https://api.quizlet.com/2.0/sets")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        var bodyParameters = [
            "lang_terms": "fr",
            "lang_definitions": "en",
            "title": "Article Words"
        ]
        
        for (idx, word) in words.enumerated() {
            bodyParameters["terms[]\(idx)"] = word.key
            bodyParameters["definitions[]\(idx)"] = word.value
        }
        
        var parts = [String]()
        for (key, value) in bodyParameters {
            let part = NSString(format: "%@=%@",
                                String(key).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!,
                                String(value).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            parts.append(part as String)
        }
        
        var bodyString = parts.joined(separator: "&")
        
        for i in 0..<words.count {
            bodyString = bodyString.replacingOccurrences(of: "terms[]\(i)", with: "terms[]")
            bodyString = bodyString.replacingOccurrences(of: "definitions[]\(i)", with: "definitions[]")
        }
        
        request.httpBody = bodyString.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            guard let url = json["url"].string, let id = json["id"].int, let quizletUrl = URL(string: "https://quizlet.com\(url)") else {
                return
            }
            
            self.setId = id
            
            completion(quizletUrl)
        }
        
        task.resume()
    }
    
    func handleAuthorizationResponse(_ url: URL) {
        safariViewController?.dismiss(animated: true, completion: nil)
        
        var params = [String: String]()
        
        guard let paramsArray = url.query?.components(separatedBy: "&") else {
            return
        }
        
        for param in paramsArray {
            let components = param.components(separatedBy: "=")
            let key = components[0], value = components[1]
            
            params[key] = value
        }
        
        guard let code = params["code"], let state = params["state"], let sentState = self.state else {
            return
        }
        
        guard state == sentState else {
            return
        }
        
        requestTokenWithCode(code)
    }
    
    func openSetWithURL(_ viewController: UIViewController, url: URL) {
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(url: url)
            viewController.present(svc, animated: true, completion: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func requestTokenWithCode(_ code: String) {
        guard let url = URL(string: "https://api.quizlet.com/oauth/token?grant_type=authorization_code&code=\(code)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.addValue("Basic \(authToken)", forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            guard let accessToken = json["access_token"].string else {
                return
            }
            
            self.accessToken = accessToken
        }
        
        task.resume()
    }
}
