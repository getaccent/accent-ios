//
//  AccentTabBar.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class AccentTabBar: UIView {
    
    private var tabViews = [AccentTabView]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tabWidth = bounds.width / CGFloat(tabViews.count)
        
        var x: CGFloat = 0
        for tab in tabViews {
            tab.frame = CGRectMake(x, 0, tabWidth, bounds.height)
            x += tabWidth
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        guard let touch = touches.first else {
            return
        }
        
        let point = touch.locationInView(self)
        
        for (idx, tab) in tabViews.enumerate() where CGRectContainsPoint(tab.frame, point) {
            selectTab(idx)
            break
        }
    }
    
    func selectTab(idx: Int) {
        for tab in tabViews {
            tab.imageView.tintColor = UIColor.accentGrayColor()
            tab.nameLabel.textColor = UIColor.accentGrayColor()
        }
        
        tabViews[idx].imageView.tintColor = UIColor.accentDarkColor()
        tabViews[idx].nameLabel.textColor = UIColor.accentDarkColor()
    }
    
    func updateTabs(tabs: [AccentTab]) {
        for tabView in tabViews {
            tabView.removeFromSuperview()
        }
        
        for tab in tabs {
            let tabView = AccentTabView(tab: tab)
            
            addSubview(tabView)
            tabViews.append(tabView)
        }
    }
}

class AccentTabView: UIView {
    
    var imageView: UIImageView!
    var nameLabel: UILabel!
    
    var tab: AccentTab!
    
    init(tab: AccentTab) {
        self.tab = tab
        
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if nameLabel == nil {
            nameLabel = UILabel()
            nameLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
            nameLabel.text = tab.name
            nameLabel.textColor = UIColor.accentDarkColor()
            addSubview(nameLabel)
        }
        nameLabel.sizeToFit()
        nameLabel.frame = CGRectMake((bounds.width - nameLabel.bounds.width) / 2, bounds.height - nameLabel.bounds.height - 8, nameLabel.bounds.width, nameLabel.bounds.height)
        
        let imageWidth = nameLabel.frame.origin.y - 14
        if imageView == nil {
            imageView = UIImageView(image: tab.image)
            imageView.image = tab.image.imageWithRenderingMode(.AlwaysTemplate)
            imageView.tintColor = UIColor.accentDarkColor()
            addSubview(imageView)
        }
        imageView.frame = CGRectMake((bounds.width - imageWidth) / 2, 10, imageWidth, imageWidth)
    }
}

struct AccentTab {
    let name: String
    let image: UIImage
}
