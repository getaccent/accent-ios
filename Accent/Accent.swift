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
        return Digits.sharedInstance().session()?.phoneNumber.stringByReplacingOccurrencesOfString("+", withString: "")
    }
    
    public class var sharedInstance: Accent {
        struct Static {
            static let instance = Accent()
        }
        return Static.instance
    }
    
    func deleteSavedArticle(article: Article) {
        let articleURL = article.url
        
        let realm = try! Realm()
        try! realm.write {
            realm.delete(article)
        }
        
        guard let realArticleURL = articleURL, phoneNumber = phoneNumber else {
            return
        }
        
        guard let urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(realArticleURL)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
    
    func getArticleThumbnail(article: Article, completion: (image: UIImage?) -> Void) {
        if article.image == "" {
            return
        }
        
        if let image = imageCache[article.image] {
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image)
            })
            
            return
        }
        
        guard let url = article.imageURL else {
            return
        }
        
        let storedURL = article.image
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            imageCache[storedURL] = image
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image)
            })
        }
        
        task.resume()
    }
    
    func getLocalArticles() -> [Article] {
        let realm = try! Realm()
        return Array(realm.objects(Article))
    }
    
    func getSavedArticles(completion: (articles: [Article]?) -> Void) {
        guard let phoneNumber = phoneNumber, url = NSURL(string: "\(baseUrl)/save?num=\(phoneNumber)") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                completion(articles: nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            
            if let articles = json["articles"].array {
                var retrievedArticles = [Article]()
                
                for article in articles {
                    let article = Article.createFromJSON(article)
                    retrievedArticles.append(article)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    let realm = try! Realm()
                    try! realm.write {
                        for article in retrievedArticles {
                            realm.create(Article.self, value: article, update: true)
                        }
                    }
                })
                
                completion(articles: retrievedArticles)
            } else {
                completion(articles: nil)
            }
        }
        
        task.resume()
    }
    
    func parseArticle(url: NSURL, completion: (article: Article?) -> Void) {
        guard let urlString = "\(baseUrl)/parse?url=\(url.absoluteString)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            let article = Article.createFromJSON(json)
            completion(article: article)
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(article)
            }
        }
        
        task.resume()
    }
    
    func retrieveArticles(completion: (articles: [Article]?) -> Void) {
        guard let language = Language.savedLanguage(), url = NSURL(string: "\(baseUrl)/articles?lang=\(language.getCode())") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
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
            
            completion(articles: retrievedArticles)
        }
        
        task.resume()
    }
    
    func saveArticle(article: Article, completion: (success: Bool) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }
        
        guard let phoneNumber = phoneNumber, aurl = article.url?.absoluteString, urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(aurl)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let json = JSON(data: data, error: nil)
            completion(success: json["success"].bool ?? false)
        }
        
        task.resume()
    }
    
    private var wordCache = [String: String]()
    
    func translateTerm(term: String, completion: (translation: Any?) -> Void) {
        guard !requestsMade.contains(term), let source = Language.savedLanguage() else {
            return
        }
        
        if let translation = wordCache[term] {
            completion(translation: translation)
            return
        }
        
        let target = Language.getPrimaryLanguage()
        let term = term.stringByReplacingOccurrencesOfString("\n", withString: " ")
        
        do {
            let predicate = NSPredicate(format: "term = %@ AND source = %@ AND target = %@", term, source.getCode(), target.getCode())
            
            let realm = try Realm()
            for translation in realm.objects(Translation).filter(predicate) {
                completion(translation: translation)
                wordCache[translation.term] = translation.translation
                return
            }
        } catch {}
        
        guard let urlString = "\(baseUrl)/translate?term=\(term)&lang=\(source.getCode())&target=\(target.getCode())".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
            completion(translation: nil)
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        requestsMade.append(term)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            for (idx, t) in self.requestsMade.enumerate() {
                if term == t {
                    self.requestsMade.removeAtIndex(idx)
                    break
                }
            }
            
            guard let data = data else {
                completion(translation: nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            let translation = json["translation"].string
            
            guard let translatedTerm = translation else {
                completion(translation: nil)
                return
            }
            
            self.wordCache[term] = translatedTerm
            
            dispatch_async(dispatch_get_main_queue(), {
                let translation = Translation()
                translation.term = term
                translation.translation = translatedTerm
                translation.source = source.getCode()
                translation.target = Language.getPrimaryLanguage().getCode()
                
                completion(translation: translation)
                
                let realm = try! Realm()
                try! realm.write { 
                    realm.add(translation)
                }
            })
        }
        
        task.resume()
    }
}
