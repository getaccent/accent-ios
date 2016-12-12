//
//  ArticleViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import AVFoundation
import UIKit

class ArticleViewController: UIViewController, ArticleTextViewDelegate, AudioBarDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var topBarLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomBar: AudioBar!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var article: Article!
    
    private var articleTitle: UILabel!
    private var imageView: UIImageView!
    private var textView: ArticleTextView!
    private var backTextView: ArticleTextView!
    
    private var translateView: UIView!
    private var translateLabel: UILabel!
    
    private var audio = false
    
    private var terms = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        
        navigationController?.isNavigationBarHidden = true
        
        bottomBar.article = article
        bottomBar.delegate = self
        
        let articlesText = NSLocalizedString("Article", comment: "news article")
        topBarLabel.text = articlesText
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {}
        
        if Quizlet.sharedInstance.setId == 0 && terms.count > 2 {
            guard let _ = Language.savedLanguage() else {
                return
            }
            
            Quizlet.sharedInstance.createSet(terms, completion: { (url) in })
        }
    }
    
    let margin: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.cgPath
        
        let bottomShadowPath = UIBezierPath(rect: bottomBar.bounds)
        bottomBar.layer.masksToBounds = false
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomBar.layer.shadowOpacity = 0.15
        bottomBar.layer.shadowPath = bottomShadowPath.cgPath
        
        if articleTitle == nil {
            articleTitle = UILabel()
            articleTitle.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightSemibold)
            articleTitle.numberOfLines = 0
            articleTitle.text = article.title
            scrollView.addSubview(articleTitle)
        }
        
        let articleTitleHeight = (articleTitle.text! as NSString).boundingRect(with: CGSize(width: scrollView.bounds.width - margin * 2, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: articleTitle.font], context: nil).height
        articleTitle.frame = CGRect(x: margin, y: margin, width: scrollView.bounds.width - margin * 2, height: articleTitleHeight)
        
        if imageView == nil {
            imageView = UIImageView()
            scrollView.addSubview(imageView)
            
            Accent.sharedInstance.getArticleThumbnail(article) { (image) in
                self.imageView.image = image
            }
        }
        
        let imageWidth = scrollView.bounds.width - (UIDevice.current.userInterfaceIdiom == .pad ? margin * 6 : 0)
        if article.image == "" {
            imageView.frame = CGRect(x: 0, y: articleTitle.frame.origin.y + articleTitle.frame.size.height, width: imageWidth, height: 0)
        } else {
            imageView.frame = CGRect(x: (scrollView.bounds.width - imageWidth) / 2, y: articleTitle.frame.origin.y + articleTitle.frame.size.height + margin,  width: imageWidth, height: imageWidth * (9/16))
        }
        
        if textView == nil {
            textView = ArticleTextView(delegate: self)
            textView.backgroundColor = UIColor.clear
            textView.isEditable = false
            textView.font = UIFont.systemFont(ofSize: 16)
            textView.isScrollEnabled = false
            textView.text = article.text
            
            scrollView.addSubview(textView)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attributes = [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: textView.font!] as [String : Any]
            textView.attributedText = NSAttributedString(string: textView.text, attributes: attributes)
        }
        
        let textViewHeight = textView.sizeThatFits(CGSize(width: scrollView.bounds.width - margin * 2, height: CGFloat.greatestFiniteMagnitude)).height
        textView.frame = CGRect(x: margin, y: imageView.frame.origin.y + imageView.frame.size.height + margin * 0.625, width: scrollView.bounds.width - margin * 2, height: textViewHeight)
        
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: textView.frame.origin.y + textView.frame.size.height + margin)
        
        if backTextView == nil {
            backTextView = ArticleTextView(delegate: self)
            backTextView.isEditable = textView.isEditable
            backTextView.isSelectable = false
            backTextView.font = textView.font
            backTextView.isScrollEnabled = textView.isScrollEnabled
            backTextView.attributedText = textView.attributedText
            backTextView.textColor = UIColor.white
            
            scrollView.insertSubview(backTextView, belowSubview: textView)
        }
        backTextView.frame = textView.frame
        
        if translateView == nil {
            translateView = UIView()
            translateView.alpha = 0
            translateView.backgroundColor = UIColor(white: 0, alpha: 0.85)
            translateView.layer.cornerRadius = 8
            view.addSubview(translateView)
        }
        translateView.frame = CGRect(x: margin, y: 80, width: view.bounds.width - margin * 2, height: 36)
        
        if translateLabel == nil {
            translateLabel = UILabel()
            translateLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightSemibold)
            translateLabel.text = ""
            translateLabel.textAlignment = .center
            translateLabel.textColor = UIColor.white
            translateView.addSubview(translateLabel)
        }
        translateLabel.frame = CGRect(x: margin, y: 4, width: translateView.frame.size.width - margin * 2, height: 28)
    }
    
    func longTouchReceived(_ point: CGPoint, state: UIGestureRecognizerState, text: String) {
        func moveTranslationView() {
            translateView.frame = CGRect(x: margin, y: point.y - 96 - translateView.frame.size.height, width: translateView.frame.size.width, height: translateView.frame.size.height)
            
            let text = (textView.text as NSString).substring(with: textView.selectedRange)
            Accent.sharedInstance.translateTerm(text) { (translation) in
                guard let translation = translation else {
                    return
                }
                
                var word = ""
                
                if let translation = translation as? String {
                    word = translation
                } else if let translation = translation as? Translation {
                    word = translation.translation
                }
                
                DispatchQueue.main.async {
                    self.translateLabel.text = word
                }
                
                if Quizlet.sharedInstance.setId > 0 {
                    Quizlet.sharedInstance.addTermToSet(text, translation: word)
                } else {
                    self.terms[text] = word
                }
            }
        }
        
        switch state {
        case .began:
            UIView.animate(withDuration: 0.25) {
                self.translateView.alpha = 1
                moveTranslationView()
            }
        case .changed:
            moveTranslationView()
        case .ended:
            UIView.animate(withDuration: 0.25) {
                self.translateView.alpha = 0
                self.translateView.frame = CGRect(x: self.margin, y: 80, width: self.view.bounds.width - self.margin * 2, height: 36)
            }
            
            becomeFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func speechButtonPressed(_ sender: UIButton?) {
        audio = !audio
        
        bottomConstraint.constant = audio ? 0 : -56
        
        backTextView.attributedText = textView.attributedText
        backTextView.textColor = UIColor.white
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hiding() {
        speechButtonPressed(nil)
    }
    
    func updatedSpeechRange(_ range: NSRange) {
        let attributedString = NSMutableAttributedString(string: backTextView.text)
        
        attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.accentBlueColor(), range: range)
        attributedString.addAttribute(NSFontAttributeName, value: backTextView.font!, range: NSMakeRange(0, attributedString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        backTextView.attributedText = attributedString
        backTextView.textColor = UIColor.white
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
