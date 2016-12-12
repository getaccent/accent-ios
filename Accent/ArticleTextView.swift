//
//  ArticleTextView.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class ArticleTextView: UITextView, UIGestureRecognizerDelegate {
    
    private var articleDelegate: ArticleTextViewDelegate?
    private var longPressRecognizer: UILongPressGestureRecognizer!
    
    init(delegate: ArticleTextViewDelegate?) {
        super.init(frame: CGRect.zero, textContainer: nil)
        
        articleDelegate = delegate
        
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressRecognizer.delegate = self
        addGestureRecognizer(longPressRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let superview = superview?.superview else {
            return
        }
        
        let point = gestureRecognizer.location(in: superview)
        articleDelegate?.longTouchReceived(point, state: gestureRecognizer.state, text: (text as NSString).substring(with: selectedRange))
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

protocol ArticleTextViewDelegate {
    func longTouchReceived(_ point: CGPoint, state: UIGestureRecognizerState, text: String)
}
