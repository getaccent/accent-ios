//
//  DeviceInfo.swift
//  Accent
//
//  Created by Jack Cook on 4/11/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import CoreTelephony
import UIKit

class DeviceInfo {
    
    class func deviceData() -> Data? {
        var data = [String]()
        
        data.append("App Version: \(appVersion())\n")
        
        data.append("Device: \(deviceIdentifier())")
        data.append("iOS Version: \(iosVersion())")
        data.append("Language: \(languageData())")
        data.append("Carrier: \(carrierName())")
        data.append("Timezone: \(timezoneName())")
        data.append("Connection Status: \(connectionStatus())")
        
        return NSArray(array: data).componentsJoined(by: "\n").data(using: String.Encoding.utf8)
    }
    
    class func appVersion() -> String {
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            return "\(version) (\(build))"
        }
        
        return "Unknown"
    }
    
    class func deviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { (identifier, element) in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    class func iosVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    class func languageData() -> String {
        if let language = Locale.preferredLanguages.first {
            var result = ""
            
            let components = Locale.components(fromIdentifier: language)
            if let languageCode = components["kCFLocaleLanguageCodeKey"] {
                result += "\(languageCode) "
            }
            
            if let displayName = (Locale(identifier: language) as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: language) {
                result += "(\(displayName))"
            }
            
            return result
        }
        
        return "Unknown"
    }
    
    class func carrierName() -> String {
        let netInfo = CTTelephonyNetworkInfo()
        if let carrier = netInfo.subscriberCellularProvider,
            let name = carrier.carrierName {
            return name
        }
        
        return "Unknown"
    }
    
    class func timezoneName() -> String {
        let timeZone = TimeZone.autoupdatingCurrent
        return timeZone.identifier
    }
    
    class func connectionStatus() -> String {
        return Reachability.isConnectedToNetwork() ? "Connected" : "Not Connected"
    }
}
