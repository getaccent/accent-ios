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
    @IBOutlet weak var topBarLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.contentInset = UIEdgeInsetsMake(-8, 0, 0, 0)
        
        let settingsText = NSLocalizedString("Settings", comment: "application settings")
        topBarLabel.text = settingsText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.cgPath
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "LanguageCell")
            
            cell.textLabel?.text = NSLocalizedString("Target Language", comment: "language being learned")
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            cell.detailTextLabel?.text = Language.savedLanguage()?.getName()
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case (1, 0):
            let cell = UITableViewCell(style: .default, reuseIdentifier: "FeedbackCell")
            
            cell.textLabel?.text = NSLocalizedString("Send Feedback", comment: "send feedback")
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case (1, 1):
            let cell = UITableViewCell(style: .default, reuseIdentifier: "RateCell")
            
            cell.textLabel?.text = NSLocalizedString("Rate Accent", comment: "rate accent on the app store")
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        case (1, 2):
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "VersionCell")
            
            cell.textLabel?.text = NSLocalizedString("Version", comment: "app version")
            cell.textLabel?.textColor = UIColor.accentDarkColor()
            
            var versionString = ""
            
            if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
                versionString = "\(version) (\(build))"
            }
            
            versionString = versionString.characters.count == 0 ? "?" : versionString
            cell.detailTextLabel?.text = versionString
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            performSegue(withIdentifier: "languageSegue", sender: self)
        case (1, 0):
            let controller = MFMailComposeViewController()
            controller.mailComposeDelegate = self
            
            controller.setToRecipients(["feedback@getaccent.io"])
            controller.setSubject(NSLocalizedString("Accent Feedback", comment: "feedback about accent"))
            
            if let data = DeviceInfo.deviceData() {
                controller.addAttachmentData(data as Data, mimeType: "text/plain", fileName: "device_information.txt")
            }
            
            present(controller, animated: true, completion: nil)
        case (1, 1):
            let url = URL(string: "itms-apps://itunes.apple.com/app/id1102643624")!
            UIApplication.shared.openURL(url)
        default:
            break
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
