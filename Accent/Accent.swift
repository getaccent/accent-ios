//
//  Accent.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import DigitsKit
import RealmSwift
import SwiftyJSON

public class Accent {
    
    let baseUrl = "http://api.getaccent.io"
    
    private var savedTranslations = [String: String]()
    private var requestsMade = [String]()
    
    private var phoneNumber: String? {
        return Digits.sharedInstance().session()?.phoneNumber.replacingOccurrences(of: "+", with: "")
    }
    
    public class var sharedInstance: Accent {
        struct Static {
            static let instance = Accent()
        }
        return Static.instance
    }
    
    func deleteSavedArticle(_ article: Article) {
        let articleURL = article.url
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(article)
        }
        
        guard let realArticleURL = articleURL, let phoneNumber = phoneNumber else {
            return
        }
        
        guard let urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(realArticleURL)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    func getArticleThumbnail(_ article: Article, completion: @escaping (_ image: UIImage?) -> Void) {
        if article.image == "" {
            return
        }
        
        if let image = imageCache[article.image] {
            DispatchQueue.main.async {
                completion(image)
            }
            
            return
        }
        
        guard let url = article.imageURL else {
            return
        }
        
        let storedURL = article.image
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            imageCache[storedURL] = image
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
    
    func getLocalArticles() -> [Article] {
        let realm = try! Realm()
        return Array(realm.objects(Article.self))
    }
    
    func getSavedArticles(_ completion: @escaping (_ articles: [Article]?) -> Void) {
        guard let phoneNumber = phoneNumber, let url = URL(string: "\(baseUrl)/save?num=\(phoneNumber)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completion(nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            if let articles = json["articles"].array {
                var retrievedArticles = [Article]()
                
                for article in articles {
                    let article = Article.createFromJSON(article)
                    retrievedArticles.append(article)
                }
                
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        for article in retrievedArticles {
                            realm.create(Article.self, value: article, update: true)
                        }
                    }
                }
                
                completion(retrievedArticles)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func parseArticle(_ url: URL, completion: @escaping (_ article: Article?) -> Void) {
        guard let urlString = "\(baseUrl)/parse?url=\(url.absoluteString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            let article = Article.createFromJSON(json)
            completion(article)
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(article)
            }
        }
        
        task.resume()
    }
    
    func retrieveArticles(_ completion: @escaping (_ articles: [Article]?) -> Void) {
        guard let language = Language.savedLanguage(), let url = URL(string: "\(baseUrl)/articles?lang=\(language.getCode())") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            var retrievedArticles = [Article]()
            
            if let articles = json["articles"].array {
                for article in articles {
                    let article = Article.createFromJSON(article)
                    retrievedArticles.append(article)
                }
            }
            
            completion(retrievedArticles)
        }
        
        task.resume()
    }
    
    func saveArticle(_ article: Article, completion: @escaping (_ success: Bool) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }
        
        guard let phoneNumber = phoneNumber, let aurl = article.url?.absoluteString, let urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(aurl)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            completion(json["success"].bool ?? false)
        }
        
        task.resume()
    }
    
    private var wordCache = [String: String]()
    
    func translateTerm(_ term: String, completion: @escaping (_ translation: Any?) -> Void) {
        guard !requestsMade.contains(term), let source = Language.savedLanguage() else {
            return
        }
        
        if let translation = wordCache[term] {
            completion(translation)
            return
        }
        
        let target = Language.getPrimaryLanguage()
        let term = term.replacingOccurrences(of: "\n", with: " ")
        
        do {
            let predicate = NSPredicate(format: "term = %@ AND source = %@ AND target = %@", term, source.getCode(), target.getCode())
            
            let realm = try Realm()
            for translation in realm.objects(Translation.self).filter(predicate) {
                completion(translation)
                wordCache[translation.term] = translation.translation
                return
            }
        } catch {}
        
        guard let urlString = "\(baseUrl)/translate?term=\(term)&lang=\(source.getCode())&target=\(target.getCode())".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed), let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        requestsMade.append(term)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            for (idx, t) in self.requestsMade.enumerated() {
                if term == t {
                    self.requestsMade.remove(at: idx)
                    break
                }
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            let translation = json["translation"].string
            
            guard let translatedTerm = translation else {
                completion(nil)
                return
            }
            
            self.wordCache[term] = translatedTerm
            
            DispatchQueue.main.async {
                let translation = Translation()
                translation.term = term
                translation.translation = translatedTerm
                translation.source = source.getCode()
                translation.target = Language.getPrimaryLanguage().getCode()
                
                completion(translation)
                
                let realm = try! Realm()
                try! realm.write { 
                    realm.add(translation)
                }
            }
        }
        
        task.resume()
    }
}
