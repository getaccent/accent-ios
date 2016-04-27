//
//  LanguageViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var noticeLabel: UILabel!
    
    private var languages = [Language]()
    private var selectedLanguage = Language.Spanish
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        selectLabel.text = NSLocalizedString("Select a Language", comment: "")
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), forState: .Normal)
        noticeLabel.text = "(" + NSLocalizedString("Don't worry, you can change this later", comment: "the selected language can be changed later") + ")"
        
        continueButton.setTitleColor(UIColor.accentDarkColor(), forState: .Normal)
        continueButton.layer.borderColor = UIColor.accentDarkColor().CGColor
        continueButton.layer.borderWidth = 1
        continueButton.layer.cornerRadius = 4
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        for i in 0...10 where i != Language.getPrimaryLanguage().rawValue {
            print(i)
            if let language = Language(rawValue: i) {
                languages.append(language)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if presentingViewController is SettingsViewController {
            noticeLabel.alpha = 0
        } else {
            closeButton.alpha = 0
            closeButton.userInteractionEnabled = false
        }
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        Language.saveLanguage(selectedLanguage)
        
        if presentingViewController is SettingsViewController {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            performSegueWithIdentifier("articlesSegue", sender: self)
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = languages[row]
    }
}
