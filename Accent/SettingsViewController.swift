//
//  SettingsViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/11/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import MessageUI
import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.blackColor().CGColor
        topBar.layer.shadowOffset = CGSizeMake(0, 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.CGPath
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "LanguageCell")
            
            cell.textLabel?.text = "Target Language"
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            cell.detailTextLabel?.text = Language.savedLanguage()?.getName()
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        case (1, 0):
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "FeedbackCell")
            
            cell.textLabel?.text = "Send Feedback"
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        case (1, 1):
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "RateCell")
            
            cell.textLabel?.text = "Rate Accent"
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            cell.accessoryType = .DisclosureIndicator
            
            return cell
        case (1, 2):
            let cell = UITableViewCell(style: .Value1, reuseIdentifier: "VersionCell")
            
            cell.textLabel?.text = "Version"
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            var versionString = ""
            
            if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String,
                build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String {
                versionString = "\(version) (\(build))"
            }
            
            versionString = versionString.characters.count == 0 ? "?" : versionString
            cell.detailTextLabel?.text = versionString
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            performSegueWithIdentifier("languageSegue", sender: self)
        case (1, 0):
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            
            controller.setToRecipients(["feedback@getaccent.io"])
            controller.setSubject("Accent Feedback")
            
            if let data = DeviceInfo.deviceData() {
                controller.addAttachmentData(data, mimeType: "text/plain", fileName: "device_information.txt")
            }
            
            presentViewController(controller, animated: true, completion: nil)
        case (1, 1):
            let url = NSURL(string: "itms-apps://itunes.apple.com/app/id1102643624")!
            UIApplication.sharedApplication().openURL(url)
        default:
            break
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
