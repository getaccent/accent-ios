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
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
        container.addSubview(activityIndicator)
        
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFontOfSize(15)
        statusLabel.text = "Saving for later..."
        statusLabel.textAlignment = .Center
        statusLabel.textColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        container.addSubview(statusLabel)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.25, animations: {
            self.overlay.alpha = 1
            self.container.alpha = 1
        }, completion: { (bool) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1) * Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
                self.dismiss()
            }
        })
        
        guard let item = extensionContext?.inputItems[0] as? NSExtensionItem, attachment = item.attachments?[0] as? NSItemProvider else {
            return
        }
        
        if attachment.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            attachment.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (data, error) in
                guard let url = data as? NSURL else {
                    return
                }
                
                var toRetrieve = NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArrayForKey("AccentArticlesToRetrieve")
                toRetrieve?.append(url.absoluteString)
                NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.setObject(toRetrieve, forKey: "AccentArticlesToRetrieve")
                NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.synchronize()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        overlay.frame = view.bounds
        
        container.frame = CGRectMake((view.bounds.width - 192) / 2, (view.bounds.height - 96) / 2, 192, 96)
        
        activityIndicator.frame = CGRectMake((container.bounds.width - activityIndicator.bounds.width) / 2, 24, activityIndicator.bounds.width, activityIndicator.bounds.height)
        
        statusLabel.sizeToFit()
        statusLabel.frame = CGRectMake(16, container.bounds.height - statusLabel.frame.size.height - 20, container.bounds.width - 32, statusLabel.frame.size.height)
    }
    
    func dismiss() {
        UIView.animateWithDuration(0.25, animations: {
            self.overlay.alpha = 0
            self.container.alpha = 0
        }, completion: { (bool) -> Void in
            self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
        })
    }
}
