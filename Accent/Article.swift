//
//  Article.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import SwiftyJSON
import RealmSwift

class Article: Object {
    
    dynamic var id: Int = 0
    dynamic var surl: String = ""
    dynamic var title: String = ""
    dynamic var image: String = ""
    dynamic var text: String = ""
    dynamic var sauthors: String = ""
    dynamic var sdate: Int = 0
    dynamic var sfeatured: Int = 0
    dynamic var slanguage: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    var url: URL? {
        return URL(string: surl)
    }
    
    var imageURL: URL? {
        return URL(string: image)
    }
    
    var authors: [String]? {
        return sauthors.components(separatedBy: ",")
    }
    
    var date: NSDate? {
        return NSDate(timeIntervalSince1970: TimeInterval(sdate))
    }
    
    var featured: Bool {
        return sfeatured == 1
    }
    
    var language: Language? {
        return Language.languageFromCode(slanguage)
    }
    
    class func createFromJSON(_ json: JSON) -> Article {
        let article = Article()
        article.id = json["id"].int ?? -1
        article.surl = json["url"].string ?? ""
        article.title = json["title"].string ?? ""
        article.image = json["image"].string ?? ""
        article.text = json["text"].string ?? ""
        article.sauthors = json["authors"].string ?? ""
        article.sdate = json["date"].int ?? 0
        article.sfeatured = json["featured"].int ?? 0
        article.slanguage = json["language"].string ?? ""
        return article
    }
}
