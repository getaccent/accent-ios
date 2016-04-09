//
//  Language.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import Foundation

enum Language: Int {
    case Spanish = 0
    case Chinese
    case French
    case Swedish
    
    var description: String {
        return "\(getName()) (\(getLocalizedName()))"
    }
    
    func getName() -> String {
        switch self {
        case .Spanish: return "Spanish"
        case .Chinese: return "Chinese"
        case .French: return "French"
        case .Swedish: return "Swedish"
        }
    }
    
    func getLocalizedName() -> String {
        switch self {
        case .Spanish: return "Español"
        case .Chinese: return "简体中文"
        case .French: return "Français"
        case .Swedish: return "Svenska"
        }
    }
    
    func getCode() -> String {
        switch self {
        case .Spanish: return "es"
        case .Chinese: return "zh-CN"
        case .French: return "fr"
        case .Swedish: return "sv"
        }
    }
    
    static func languageFromCode(code: String?) -> Language? {
        guard let code = code else {
            return nil
        }
        
        switch code {
        case Language.Spanish.getCode(): return Language.Spanish
        case Language.Chinese.getCode(): return Language.Chinese
        case Language.French.getCode(): return Language.French
        case Language.Swedish.getCode(): return Language.Swedish
        default: return nil
        }
    }
    
    static func savedLanguage() -> Language? {
        return Language.languageFromCode(NSUserDefaults.standardUserDefaults().stringForKey("AccentLanguage"))
    }
    
    static func saveLanguage(language: Language) {
        NSUserDefaults.standardUserDefaults().setObject(language.getCode(), forKey: "AccentLanguage")
    }
}
