//
//  LanguageViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class LanguageViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var continueButton: UIButton!
    
    private var selectedLanguage = Language.Spanish
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        continueButton.setTitleColor(UIColor.accentDarkColor(), forState: .Normal)
        continueButton.layer.borderColor = UIColor.accentDarkColor().CGColor
        continueButton.layer.borderWidth = 1
        continueButton.layer.cornerRadius = 4
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    @IBAction func continueButtonPressed(sender: UIButton) {
        Language.saveLanguage(selectedLanguage)
        performSegueWithIdentifier("articlesSegue", sender: self)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let language = Language(rawValue: row) else {
            return "Unknown"
        }
        
        return language.description
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let language = Language(rawValue: row) else {
            return
        }
        
        selectedLanguage = language
    }
}
