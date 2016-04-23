//
//  Accent.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import RealmSwift
import SwiftyJSON

public class Accent {
    
    let baseUrl = "http://45.55.202.8"
    
    private var savedTranslations = [String: String]()
    private var requestsMade = [String]()
    
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
        
        guard let realArticleURL = articleURL, urlString = "\(baseUrl)/unsave?url=\(realArticleURL)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
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
    
    func getSavedArticles(phoneNumber: String, completion: (articles: [Article]) -> Void) {
        guard let url = NSURL(string: "\(baseUrl)/saved?num=\(phoneNumber)") else {
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
            
            if let urls = json["entries"].array {
                var toRetrieve = NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArrayForKey("AccentArticlesToRetrieve")
                
                for url in urls {
                    if let url = url["url"].string {
                        toRetrieve?.append(url)
                    }
                }
                
                NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.setObject(toRetrieve, forKey: "AccentArticlesToRetrieve")
                NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.synchronize()
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
    
    func saveArticle(phoneNumber: String?, article: Article, completion: (success: Bool) -> Void) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }
        
        guard let phoneNumber = phoneNumber, urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(article.url)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
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
    
    func translateTerm(term: String, completion: (translation: Translation?) -> Void) {
        guard !requestsMade.contains(term), let language = Language.savedLanguage() else {
            return
        }
        
        let term = term.stringByReplacingOccurrencesOfString("\n", withString: " ")
        
        do {
            let predicate = NSPredicate(format: "term = %@ AND target = %@", term, language.getCode())
            
            let realm = try Realm()
            for translation in realm.objects(Translation).filter(predicate) {
                completion(translation: translation)
                return
            }
        } catch {}
        
        guard let urlString = "\(baseUrl)/translate?term=\(term)&lang=\(language.getCode())".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
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
            
            dispatch_async(dispatch_get_main_queue(), {
                let translation = Translation()
                translation.term = term
                translation.translation = translatedTerm
                translation.target = language.getCode()
                
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
