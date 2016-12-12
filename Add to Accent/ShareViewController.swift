//
//  ShareViewController.swift
//  Add to Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import MobileCoreServices
import Social
import UIKit

class ShareViewController: UIViewController {
    
    var overlay: UIView!
    var container: UIView!
    var activityIndicator: UIActivityIndicatorView!
    var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overlay = UIView()
        overlay.alpha = 0
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addSubview(overlay)
        
        container = UIView()
        container.alpha = 0
        container.backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1)
        container.layer.cornerRadius = 8
        view.addSubview(container)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        container.addSubview(activityIndicator)
        
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 15)
        statusLabel.text = NSLocalizedString("Saving for later...", comment: "saving the article to read for later")
        statusLabel.textAlignment = .center
        statusLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        container.addSubview(statusLabel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.overlay.alpha = 1
            self.container.alpha = 1
        }, completion: { (bool) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss()
            }
        })
        
        guard let item = extensionContext?.inputItems[0] as? NSExtensionItem, let attachment = item.attachments?[0] as? NSItemProvider else {
            return
        }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (data, error) in
                guard let url = data as? URL else {
                    return
                }
                
                var toRetrieve = UserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArray(forKey: "AccentArticlesToRetrieve")
                toRetrieve?.append(url.absoluteString)
                UserDefaults(suiteName: "group.io.tinypixels.Accent")?.set(toRetrieve, forKey: "AccentArticlesToRetrieve")
                UserDefaults(suiteName: "group.io.tinypixels.Accent")?.synchronize()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        overlay.frame = view.bounds
        
        container.frame = CGRect(x: (view.bounds.width - 192) / 2, y: (view.bounds.height - 96) / 2, width: 192, height: 96)
        
        activityIndicator.frame = CGRect(x: (container.bounds.width - activityIndicator.bounds.width) / 2, y: 24, width: activityIndicator.bounds.width, height: activityIndicator.bounds.height)
        
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: 16, y: container.bounds.height - statusLabel.frame.size.height - 20, width: container.bounds.width - 32, height: statusLabel.frame.size.height)
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlay.alpha = 0
            self.container.alpha = 0
        }, completion: { (bool) in
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
}
