//
//  ArticlesViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import UIKit

class ArticlesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: AccentTabBar!
    
    private var articles = [Article]()
    private var articleToSend: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        Accent.sharedInstance.retrieveArticles { (articles) in
            guard let articles = articles else {
                return
            }
            
            self.articles = articles
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
        let tabs = [AccentTab(name: "Home", image: UIImage(named: "Home")!), AccentTab(name: "Browse", image: UIImage(named: "Browse")!)]
        bottomBar.updateTabs(tabs)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
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
    }
    
    @IBAction func quizletButton(sender: UIBarButtonItem) {
        if Quizlet.sharedInstance.accessToken == nil {
            Quizlet.sharedInstance.beginAuthorization(self)
        } else {
            let setId = Quizlet.sharedInstance.setId
            
            guard setId > 0 else {
                return
            }
            
            let url = NSURL(string: "https://quizlet.com/\(setId)/")!
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let avc = segue.destinationViewController as! ArticleViewController
        avc.article = articleToSend
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return indexPath.row % 5 == 0 ? 312 : 136
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        
        let cell = NSBundle.mainBundle().loadNibNamed(indexPath.row % 5 == 0 ? (article.imageUrl == nil ? "NoImageArticleCell" : "LargeArticleCell") : (article.imageUrl == nil ? "NoImageArticleCell" : "ArticleCell"), owner: self, options: nil)[0] as! ArticleCell
        cell.configure(articles[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        articleToSend = articles[indexPath.row]
        performSegueWithIdentifier("articleSegue", sender: nil)
    }
}
