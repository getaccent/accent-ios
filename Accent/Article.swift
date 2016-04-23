//
//  Article.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import RealmSwift

class Article: Object {
    
    dynamic var url: String = ""
    dynamic var title: String = ""
    dynamic var image: String = ""
    dynamic var text: String = ""
    dynamic var authors: String = ""
    dynamic var date: Int = 0
    dynamic var featured: Int = 0
    dynamic var language: String = ""
    
    func getURL() -> NSURL? {
        return NSURL(string: url)
    }
    
    func getImageURL() -> NSURL? {
        return NSURL(string: image)
    }
    
    func getAuthors() -> [String]? {
        return authors.componentsSeparatedByString(",")
    }
    
    func getDate() -> NSDate? {
        return NSDate(timeIntervalSince1970: NSTimeInterval(date))
    }
    
    func getFeatured() -> Bool {
        return featured == 1
    }
    
    func getLanguage() -> Language? {
        return Language.languageFromCode(language)
    }
}
