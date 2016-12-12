//
//  Language.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import Foundation

enum Language: Int {
    case english = 0
    case spanish
    case french
    case german
    case sChinese
    case tChinese
    case japanese
    case italian
    case korean
    case swedish
    case russian
    
    var description: String {
        return "\(getName()) (\(getLocalizedName()))"
    }
    
    func getName() -> String {
        switch self {
        case .english: return NSLocalizedString("English", comment: "")
        case .spanish: return NSLocalizedString("Spanish", comment: "")
        case .french: return NSLocalizedString("French", comment: "")
        case .german: return NSLocalizedString("German", comment: "")
        case .sChinese: return NSLocalizedString("SChinese", comment: "")
        case .tChinese: return NSLocalizedString("TChinese", comment: "")
        case .japanese: return NSLocalizedString("Japanese", comment: "")
        case .italian: return NSLocalizedString("Italian", comment: "")
        case .korean: return NSLocalizedString("Korean", comment: "")
        case .swedish: return NSLocalizedString("Swedish", comment: "")
        case .russian: return NSLocalizedString("Russian", comment: "")
        }
    }
    
    func getLocalizedName() -> String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .sChinese: return "简体中文"
        case .tChinese: return "繁體中文"
        case .japanese: return "日本語"
        case .italian: return "Italiano"
        case .korean: return "한국어"
        case .swedish: return "Svenska"
        case .russian: return "Русский"
        }
    }
    
    func getCode() -> String {
        switch self {
        case .english: return "en"
        case .spanish: return "es"
        case .french: return "fr"
        case .german: return "de"
        case .sChinese: return "zh-CN"
        case .tChinese: return "zh-TW"
        case .japanese: return "ja"
        case .italian: return "it"
        case .korean: return "ko"
        case .swedish: return "sv"
        case .russian: return "ru"
        }
    }
    
    static func languageFromCode(_ code: String?) -> Language? {
        guard let code = code else {
            return nil
        }
        
        switch code {
        case Language.english.getCode(): return .english
        case Language.spanish.getCode(): return .spanish
        case Language.french.getCode(): return .french
        case Language.german.getCode(): return .german
        case Language.sChinese.getCode(): return .sChinese
        case Language.tChinese.getCode(): return .tChinese
        case Language.japanese.getCode(): return .japanese
        case Language.italian.getCode(): return .italian
        case Language.korean.getCode(): return .korean
        case Language.swedish.getCode(): return .swedish
        case Language.russian.getCode(): return .russian
        default: return nil
        }
    }
    
    static func getPrimaryLanguage() -> Language {
        guard let language = (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as? String else {
            return .english
        }
        
        switch language {
        case "en": return .english
        case "es": return .spanish
        case "fr": return .french
        case "de": return .german
        case "zh": return .sChinese
        case "ja": return .japanese
        case "it": return .italian
        case "ko": return .korean
        case "sv": return .swedish
        case "ru": return .russian
        default: return .english
        }
    }
    
    static func savedLanguage() -> Language? {
        return Language.languageFromCode(UserDefaults.standard.string(forKey: "AccentLanguage"))
    }
    
    static func saveLanguage(_ language: Language) {
        UserDefaults.standard.set(language.getCode(), forKey: "AccentLanguage")
    }
}
