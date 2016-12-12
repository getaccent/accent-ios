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
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = UIColor.accentLightColor()
        
        logoLabel.textColor = UIColor.accentDarkColor()
        descriptionLabel.textColor = UIColor.accentDarkColor()
        
        digitsButton.setTitleColor(UIColor.accentLightColor(), for: .normal)
        digitsButton.backgroundColor = UIColor.accentDarkColor()
        digitsButton.layer.cornerRadius = 4
        
        skipButton.setTitleColor(UIColor.accentDarkColor(), for: .normal)
        skipButton.layer.borderColor = UIColor.accentDarkColor().cgColor
        skipButton.layer.borderWidth = 1
        skipButton.layer.cornerRadius = 4
        
        descriptionLabel.text = NSLocalizedString("Your global news source", comment: "")
        digitsButton.setTitle(NSLocalizedString("Sign in with Phone Number", comment: ""), for: .normal)
        skipButton.setTitle(NSLocalizedString("Continue Without Login", comment: ""), for: .normal)
    }
    
    @IBAction func digitsButtonPressed(_ sender: UIButton) {
        let digits = Digits.sharedInstance()
        let configuration = DGTAuthenticationConfiguration(accountFields: .defaultOptionMask)
        configuration?.appearance = DGTAppearance()
        
        configuration?.appearance.accentColor = UIColor.accentDarkColor()
        
        digits.authenticate(with: nil, configuration: configuration!) { (session, error) in
            guard let _ = session else {
                print(error?.localizedDescription ?? "error occurred authenticating with digits")
                return
            }
            
            Accent.sharedInstance.getSavedArticles { (articles) in
                print("retrieved articles")
            }
            
            self.performSegue(withIdentifier: "languageSegue", sender: self)
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "languageSegue", sender: self)
    }
}
