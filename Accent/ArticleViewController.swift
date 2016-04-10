//
//  ArticleViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController, ArticleTextViewDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var article: Article!
    
    private var articleTitle: UILabel!
    private var imageView: UIImageView!
    private var textView: ArticleTextView!
    
    private var translateView: UIView!
    private var translateLabel: UILabel!
    
    private var terms = [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        imageView = UIImageView()
        scrollView.addSubview(imageView)
        
        Accent.sharedInstance.getArticleThumbnail(article) { (image) in
            self.imageView.image = image
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if Quizlet.sharedInstance.setId == 0 && terms.count > 2 {
            guard let _ = Language.savedLanguage() else {
                return
            }
            
            Quizlet.sharedInstance.createSet(terms, completion: { (url) in })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.blackColor().CGColor
        topBar.layer.shadowOffset = CGSizeMake(0, 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.CGPath
        
        if articleTitle == nil {
            articleTitle = UILabel()
            articleTitle.font = UIFont.systemFontOfSize(22, weight: UIFontWeightSemibold)
            articleTitle.numberOfLines = 0
            articleTitle.text = article.title
            scrollView.addSubview(articleTitle)
        }
        
        let articleTitleHeight = (articleTitle.text! as NSString).boundingRectWithSize(CGSizeMake(scrollView.bounds.width - 32, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: articleTitle.font], context: nil).height
        articleTitle.frame = CGRectMake(16, 16, scrollView.bounds.width - 32, articleTitleHeight)
        
        let imageWidth = scrollView.bounds.width
        if article.imageUrl == "" {
            imageView.frame = CGRectMake(0, articleTitle.frame.origin.y + articleTitle.frame.size.height, imageWidth, 0)
        } else {
            imageView.frame = CGRectMake(0, articleTitle.frame.origin.y + articleTitle.frame.size.height + 16, imageWidth, imageWidth * (9/16))
        }
        
        if textView == nil {
            textView = ArticleTextView(delegate: self)
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
        
        let textViewHeight = textView.sizeThatFits(CGSizeMake(scrollView.bounds.width - 32, CGFloat.max)).height
        textView.frame = CGRectMake(16, imageView.frame.origin.y + imageView.frame.size.height + 10, scrollView.bounds.width - 32, textViewHeight)
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.width, textView.frame.origin.y + textView.frame.size.height + 16)
        
        if translateView == nil {
            translateView = UIView()
            translateView.alpha = 0
            translateView.backgroundColor = UIColor(white: 0, alpha: 0.85)
            translateView.layer.cornerRadius = 8
            view.addSubview(translateView)
        }
        translateView.frame = CGRectMake(16, 80, view.bounds.width - 32, 36)
        
        if translateLabel == nil {
            translateLabel = UILabel()
            translateLabel.font = UIFont.systemFontOfSize(16, weight: UIFontWeightSemibold)
            translateLabel.text = ""
            translateLabel.textAlignment = .Center
            translateLabel.textColor = UIColor.whiteColor()
            translateView.addSubview(translateLabel)
        }
        translateLabel.frame = CGRectMake(16, 4, translateView.frame.size.width - 32, 28)
    }
    
    func longTouchReceived(point: CGPoint, state: UIGestureRecognizerState, text: String) {
        func moveTranslationView() {
            translateView.frame = CGRectMake(16, point.y - 96 - translateView.frame.size.height, translateView.frame.size.width, translateView.frame.size.height)
            
            let text = (textView.text as NSString).substringWithRange(textView.selectedRange)
            Accent.sharedInstance.translateTerm(text) { (translation) in
                guard let translation = translation else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.translateLabel.text = translation
                })
                
                if Quizlet.sharedInstance.setId > 0 {
                    Quizlet.sharedInstance.addTermToSet(text, translation: translation)
                } else {
                    self.terms[text] = translation
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
                self.translateView.frame = CGRectMake(16, 80, self.view.bounds.width - 32, 36)
            })
            
            becomeFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func backButtonPressed(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return false
    }
}
