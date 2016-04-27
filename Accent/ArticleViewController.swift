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
        
        navigationController?.navigationBarHidden = true
        
        bottomBar.article = article
        bottomBar.delegate = self
        
        let articlesText = NSLocalizedString("Article", comment: "news article")
        topBarLabel.text = articlesText
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    let margin: CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 32 : 16
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.blackColor().CGColor
        topBar.layer.shadowOffset = CGSizeMake(0, 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.CGPath
        
        let bottomShadowPath = UIBezierPath(rect: bottomBar.bounds)
        bottomBar.layer.masksToBounds = false
        bottomBar.layer.shadowColor = UIColor.blackColor().CGColor
        bottomBar.layer.shadowOffset = CGSizeMake(0, -1)
        bottomBar.layer.shadowOpacity = 0.15
        bottomBar.layer.shadowPath = bottomShadowPath.CGPath
        
        if articleTitle == nil {
            articleTitle = UILabel()
            articleTitle.font = UIFont.systemFontOfSize(22, weight: UIFontWeightSemibold)
            articleTitle.numberOfLines = 0
            articleTitle.text = article.title
            scrollView.addSubview(articleTitle)
        }
        
        let articleTitleHeight = (articleTitle.text! as NSString).boundingRectWithSize(CGSizeMake(scrollView.bounds.width - margin * 2, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: articleTitle.font], context: nil).height
        articleTitle.frame = CGRectMake(margin, margin, scrollView.bounds.width - margin * 2, articleTitleHeight)
        
        if imageView == nil {
            imageView = UIImageView()
            scrollView.addSubview(imageView)
            
            Accent.sharedInstance.getArticleThumbnail(article) { (image) in
                self.imageView.image = image
            }
        }
        
        let imageWidth = scrollView.bounds.width - (UIDevice.currentDevice().userInterfaceIdiom == .Pad ? margin * 6 : 0)
        if article.image == "" {
            imageView.frame = CGRectMake(0, articleTitle.frame.origin.y + articleTitle.frame.size.height, imageWidth, 0)
        } else {
            imageView.frame = CGRectMake((scrollView.bounds.width - imageWidth) / 2, articleTitle.frame.origin.y + articleTitle.frame.size.height + margin,  imageWidth, imageWidth * (9/16))
        }
        
        if textView == nil {
            textView = ArticleTextView(delegate: self)
            textView.backgroundColor = UIColor.clearColor()
            textView.editable = false
            textView.font = UIFont.systemFontOfSize(16)
            textView.scrollEnabled = false
            textView.text = article.text
            
            scrollView.addSubview(textView)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let attributes = [NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: textView.font!]
            textView.attributedText = NSAttributedString(string: textView.text, attributes: attributes)
        }
        
        let textViewHeight = textView.sizeThatFits(CGSizeMake(scrollView.bounds.width - margin * 2, CGFloat.max)).height
        textView.frame = CGRectMake(margin, imageView.frame.origin.y + imageView.frame.size.height + margin * 0.625, scrollView.bounds.width - margin * 2, textViewHeight)
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.width, textView.frame.origin.y + textView.frame.size.height + margin)
        
        if backTextView == nil {
            backTextView = ArticleTextView(delegate: self)
            backTextView.editable = textView.editable
            backTextView.selectable = false
            backTextView.font = textView.font
            backTextView.scrollEnabled = textView.scrollEnabled
            backTextView.attributedText = textView.attributedText
            backTextView.textColor = UIColor.whiteColor()
            
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
        translateView.frame = CGRectMake(margin, 80, view.bounds.width - margin * 2, 36)
        
        if translateLabel == nil {
            translateLabel = UILabel()
            translateLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
            translateLabel.text = ""
            translateLabel.textAlignment = .Center
            translateLabel.textColor = UIColor.whiteColor()
            translateView.addSubview(translateLabel)
        }
        translateLabel.frame = CGRectMake(margin, 4, translateView.frame.size.width - margin * 2, 28)
    }
    
    func longTouchReceived(point: CGPoint, state: UIGestureRecognizerState, text: String) {
        func moveTranslationView() {
            translateView.frame = CGRectMake(margin, point.y - 96 - translateView.frame.size.height, translateView.frame.size.width, translateView.frame.size.height)
            
            let text = (textView.text as NSString).substringWithRange(textView.selectedRange)
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
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.translateLabel.text = word
                })
                
                if Quizlet.sharedInstance.setId > 0 {
                    Quizlet.sharedInstance.addTermToSet(text, translation: word)
                } else {
                    self.terms[text] = word
                }
            }
        }
        
        switch state {
        case .Began:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 1
                moveTranslationView()
            })
        case .Changed:
            moveTranslationView()
        case .Ended:
            UIView.animateWithDuration(0.25, animations: {
                self.translateView.alpha = 0
                self.translateView.frame = CGRectMake(self.margin, 80, self.view.bounds.width - self.margin * 2, 36)
            })
            
            becomeFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func speechButtonPressed(sender: UIButton?) {
        audio = !audio
        
        bottomConstraint.constant = audio ? 0 : -56
        
        backTextView.attributedText = textView.attributedText
        backTextView.textColor = UIColor.whiteColor()
        
        UIView.animateWithDuration(0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hiding() {
        speechButtonPressed(nil)
    }
    
    func updatedSpeechRange(range: NSRange) {
        let attributedString = NSMutableAttributedString(string: backTextView.text)
        
        attributedString.addAttribute(NSBackgroundColorAttributeName, value: UIColor.accentBlueColor(), range: range)
        attributedString.addAttribute(NSFontAttributeName, value: backTextView.font!, range: NSMakeRange(0, attributedString.length))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        backTextView.attributedText = attributedString
        backTextView.textColor = UIColor.whiteColor()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
}
