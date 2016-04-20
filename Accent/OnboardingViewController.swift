//
//  OnboardingViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import DigitsKit
import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var digitsButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Digits.sharedInstance().logOut()
        
        navigationController?.navigationBarHidden = true
        
        view.backgroundColor = UIColor.accentLightColor()
        
        logoLabel.textColor = UIColor.accentDarkColor()
        descriptionLabel.textColor = UIColor.accentDarkColor()
        
        digitsButton.setTitleColor(UIColor.accentLightColor(), forState: .Normal)
        digitsButton.backgroundColor = UIColor.accentDarkColor()
        digitsButton.layer.cornerRadius = 4
        
        skipButton.setTitleColor(UIColor.accentDarkColor(), forState: .Normal)
        skipButton.layer.borderColor = UIColor.accentDarkColor().CGColor
        skipButton.layer.borderWidth = 1
        skipButton.layer.cornerRadius = 4
        
        descriptionLabel.text = NSLocalizedString("Your global news source", comment: "")
        digitsButton.setTitle(NSLocalizedString("Sign in with Phone Number", comment: ""), forState: .Normal)
        skipButton.setTitle(NSLocalizedString("Continue Without Login", comment: ""), forState: .Normal)
    }
    
    @IBAction func digitsButtonPressed(sender: UIButton) {
        let digits = Digits.sharedInstance()
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        configuration.appearance = DGTAppearance()
        
        configuration.appearance.accentColor = UIColor.accentDarkColor()
        
        digits.authenticateWithViewController(nil, configuration: configuration) { (session, error) in
            guard let _ = session else {
                print(error.localizedDescription)
                return
            }
            
            print(session.phoneNumber)
            
            Accent.sharedInstance.getSavedArticles(session.phoneNumber.stringByReplacingOccurrencesOfString("+", withString: ""), completion: { (articles) in
                print("retrieved saved articles")
            })
            
            self.performSegueWithIdentifier("languageSegue", sender: self)
        }
    }
    
    @IBAction func skipButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("languageSegue", sender: self)
    }
}
