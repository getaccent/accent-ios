//
//  Language.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import Foundation

enum Language: Int {
    case English = 0
    case Spanish
    case French
    case German
    case SChinese
    case TChinese
    case Japanese
    case Italian
    case Korean
    case Swedish
    case Russian
    
    var description: String {
        return "\(getName()) (\(getLocalizedName()))"
    }
    
    func getName() -> String {
        switch self {
        case .English: return NSLocalizedString("English", comment: "")
        case .Spanish: return NSLocalizedString("Spanish", comment: "")
        case .French: return NSLocalizedString("French", comment: "")
        case .German: return NSLocalizedString("German", comment: "")
        case .SChinese: return NSLocalizedString("SChinese", comment: "")
        case .TChinese: return NSLocalizedString("TChinese", comment: "")
        case .Japanese: return NSLocalizedString("Japanese", comment: "")
        case .Italian: return NSLocalizedString("Italian", comment: "")
        case .Korean: return NSLocalizedString("Korean", comment: "")
        case .Swedish: return NSLocalizedString("Swedish", comment: "")
        case .Russian: return NSLocalizedString("Russian", comment: "")
        }
    }
    
    func getLocalizedName() -> String {
        switch self {
        case .English: return "English"
        case .Spanish: return "Español"
        case .French: return "Français"
        case .German: return "Deutsch"
        case .SChinese: return "简体中文"
        case .TChinese: return "繁體中文"
        case .Japanese: return "日本語"
        case .Italian: return "Italiano"
        case .Korean: return "한국어"
        case .Swedish: return "Svenska"
        case .Russian: return "Русский"
        }
    }
    
    func getCode() -> String {
        switch self {
        case .English: return "en"
        case .Spanish: return "es"
        case .French: return "fr"
        case .German: return "de"
        case .SChinese: return "zh-CN"
        case .TChinese: return "zh-TW"
        case .Japanese: return "ja"
        case .Italian: return "it"
        case .Korean: return "ko"
        case .Swedish: return "sv"
        case .Russian: return "ru"
        }
    }
    
    static func languageFromCode(code: String?) -> Language? {
        guard let code = code else {
            return nil
        }
        
        switch code {
        case Language.English.getCode(): return .English
        case Language.Spanish.getCode(): return .Spanish
        case Language.French.getCode(): return .French
        case Language.German.getCode(): return .German
        case Language.SChinese.getCode(): return .SChinese
        case Language.TChinese.getCode(): return .TChinese
        case Language.Japanese.getCode(): return .Japanese
        case Language.Italian.getCode(): return .Italian
        case Language.Korean.getCode(): return .Korean
        case Language.Swedish.getCode(): return .Swedish
        case Language.Russian.getCode(): return .Russian
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
