//
//  ArticleCell.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import MGSwipeTableCell
import UIKit

var imageCache = [String: UIImage]()

class ArticleCell: MGSwipeTableCell {
    
    var article: Article?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstLineLabel: UILabel?
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var articleImage: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.text = ""
    }
    
    func configure(article: Article) {
        self.article = article
        
        titleLabel.text = article.title
        
        var text = article.text
        
        while text.containsString("\n") {
            text = text.stringByReplacingOccurrencesOfString("\n", withString: "")
        }
        
        firstLineLabel?.text = text
        
        Accent.sharedInstance.getArticleThumbnail(article) { (image) in
            self.articleImage?.image = image
        }
        
        var parts = [String]()
        
        if let domain = article.url?.host?.stringByReplacingOccurrencesOfString("www.", withString: "") {
            parts.append(domain)
        }
        
        if let authors = article.authors where authors.count > 0 {
            if authors[0] != "" {
                parts.append(authors.joinWithSeparator(", "))
            }
        }
        
        authorLabel.text = parts.joinWithSeparator(" • ")
    }
}
