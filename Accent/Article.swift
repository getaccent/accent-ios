//
//  Article.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import RealmSwift

class Article: Object {
    
    dynamic var articleUrl: String = ""
    dynamic var imageUrl: String?
    dynamic var text: String = ""
    dynamic var title: String = ""
}
