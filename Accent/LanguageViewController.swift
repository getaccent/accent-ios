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
    private var selectedLanguage = Language.spanish
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        selectLabel.text = NSLocalizedString("Select a Language", comment: "")
        continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        noticeLabel.text = "(" + NSLocalizedString("Don't worry, you can change this later", comment: "the selected language can be changed later") + ")"
        
        continueButton.setTitleColor(UIColor.accentDarkColor(), for: .normal)
        continueButton.layer.borderColor = UIColor.accentDarkColor().cgColor
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presentingViewController is SettingsViewController {
            noticeLabel.alpha = 0
        } else {
            closeButton.alpha = 0
            closeButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
        Language.saveLanguage(selectedLanguage)
        
        if presentingViewController is SettingsViewController {
            dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "articlesSegue", sender: self)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLanguage = languages[row]
    }
}
