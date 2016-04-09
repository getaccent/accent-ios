//
//  AccentTabView.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class AccentTabView: UIView {
    
    var imageView: UIImageView!
    var nameLabel: UILabel!
    
    var tab: AccentTab!
    
    init(tab: AccentTab) {
        super.init(frame: CGRectZero)
        
        self.tab = tab
        
        nameLabel = UILabel()
        nameLabel.font = UIFont.systemFontOfSize(12, weight: UIFontWeightMedium)
        nameLabel.text = tab.name
        nameLabel.textColor = UIColor.accentDarkColor()
        
        imageView = UIImageView(image: tab.image)
        imageView.image = tab.image.imageWithRenderingMode(.AlwaysTemplate)
        imageView.tintColor = UIColor.accentDarkColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if nameLabel.superview == nil {
            addSubview(nameLabel)
        }
        nameLabel.sizeToFit()
        nameLabel.frame = CGRectMake((bounds.width - nameLabel.bounds.width) / 2, bounds.height - nameLabel.bounds.height - 8, nameLabel.bounds.width, nameLabel.bounds.height)
        
        let imageWidth = nameLabel.frame.origin.y - 14
        if imageView.superview == nil {
            addSubview(imageView)
        }
        imageView.frame = CGRectMake((bounds.width - imageWidth) / 2, 10, imageWidth, imageWidth)
    }
}
