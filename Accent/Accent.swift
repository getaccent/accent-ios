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
    
    let baseUrl = "http://45.55.202.8:81"
    
    private var savedTranslations = [String: String]()
    private var requestsMade = [String]()
    
    public class var sharedInstance: Accent {
        struct Static {
            static let instance = Accent()
        }
        return Static.instance
    }
    
    func getArticleThumbnail(article: Article, completion: (image: UIImage?) -> Void) {
        guard let imgurl = article.imageUrl else {
            return
        }
        
        if let image = imageCache[imgurl] {
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image)
            })
            
            return
        }
        
        guard let url = NSURL(string: imgurl) else {
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        
        let task = session.dataTaskWithRequest(request) { (data, response, erro) in
            guard let data = data else {
                return
            }
            
            let image = UIImage(data: data)
            imageCache[imgurl] = image
            
            dispatch_async(dispatch_get_main_queue(), {
                completion(image: image)
            })
        }
        
        task.resume()
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
            
            if let url = json["url"].string,
                title = json["title"].string,
                text = json["text"].string {
                    let image = json["image"].string
                    let article = Article()
                    article.articleUrl = url
                    article.imageUrl = image
                    article.text = text
                    article.title = title
                
                    completion(article: article)
                
                    dispatch_async(dispatch_get_main_queue(), { 
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(article)
                        }
                    })
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
                    if let url = article["url"].string,
                        title = article["title"].string,
                        text = article["text"].string {
                            let image = article["image"].string
                            let article = Article()
                            article.articleUrl = url
                            article.imageUrl = image
                            article.text = text
                            article.title = title
                        
                            retrievedArticles.append(article)
                    }
                }
            }
            
            completion(articles: retrievedArticles)
        }
        
        task.resume()
    }
    
    func saveArticle(phoneNumber: String, url: String, completion: (success: Bool) -> Void) {
        guard let urlString = "\(baseUrl)/save?num=\(phoneNumber)&url=\(url)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()), url = NSURL(string: urlString) else {
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
    
    func translateTerm(term: String, completion: (translation: String?) -> Void) {
        guard !requestsMade.contains(term), let language = Language.savedLanguage() else {
            return
        }
        
        do {
            let predicateTerm = term.stringByReplacingOccurrencesOfString("\n", withString: " ").stringByReplacingOccurrencesOfString("'", withString: "")
            
            let realm = try Realm()
            for term in realm.objects(Translation).filter("term = '\(predicateTerm)' AND target = '\(language.getCode())'") {
                completion(translation: term.translation)
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
            guard let data = data else {
                completion(translation: nil)
                return
            }
            
            let json = JSON(data: data, error: nil)
            let translation = json["translation"].string
            
            completion(translation: translation)
            
            guard let translatedTerm = translation else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                let translation = Translation()
                translation.term = term
                translation.translation = translatedTerm
                translation.target = language.getCode()
                
                let realm = try! Realm()
                try! realm.write { 
                    realm.add(translation)
                }
            })
        }
        
        task.resume()
    }
}
