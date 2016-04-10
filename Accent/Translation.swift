//
//  Translation.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import RealmSwift

class Translation: Object {
    
    dynamic var term: String = ""
    dynamic var translation: String = ""
    dynamic var target: String = ""
}
