//
//  AccentTabBar.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class AccentTabBar: UIView {
    
    var delegate: AccentTabBarDelegate?
    var selectedTab = 0
    
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
        
        selectedTab = idx
        delegate?.updatedSelectedTab(idx)
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
        
        selectTab(0)
    }
}

protocol AccentTabBarDelegate {
    func updatedSelectedTab(index: Int)
}

struct AccentTab {
    let name: String
    let image: UIImage
}
