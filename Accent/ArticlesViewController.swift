//
//  ArticlesViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import RealmSwift
import UIKit

class ArticlesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccentTabBarDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var quizletButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomBar: AccentTabBar!
    
    private var articles: [Article] {
        return bottomBar.selectedTab == 0 ? savedArticles : browseArticles
    }
    
    private var browseArticles = [Article]()
    private var savedArticles = [Article]()
    private var articleToSend: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        let realm = try! Realm()
        let articles = realm.objects(Article)
        
        for article in articles {
            savedArticles.append(article)
        }
        
        Accent.sharedInstance.retrieveArticles { (articles) in
            guard let articles = articles else {
                return
            }
            
            self.browseArticles = articles
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
        
        quizletButton.setImage(quizletButton.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        quizletButton.tintColor = UIColor.accentDarkColor()
        
        settingsButton.setImage(settingsButton.imageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        settingsButton.tintColor = UIColor.accentDarkColor()
        
        bottomBar.delegate = self
        
        let tabs = [AccentTab(name: "Home", image: UIImage(named: "Home")!), AccentTab(name: "Browse", image: UIImage(named: "Browse")!)]
        bottomBar.updateTabs(tabs)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateSavedArticles()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateSavedArticles), name: AccentApplicationWillEnterForeground, object: nil)
    }
    
    func updateSavedArticles() {
        guard let toRetrieve = NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArrayForKey("AccentArticlesToRetrieve") else {
            return
        }
        
        for urlString in toRetrieve {
            if let url = NSURL(string: urlString) {
                Accent.sharedInstance.parseArticle(url, completion: { (article) in
                    guard let article = article else {
                        return
                    }
                    
                    self.savedArticles.append(article)
                    
                    dispatch_async(dispatch_get_main_queue(), { 
                        self.tableView.reloadData()
                    })
                    
                    guard var toRetrieve = NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArrayForKey("AccentArticlesToRetrieve") else {
                        return
                    }
                    
                    var idx = 0
                    
                    for (i, articleUrl) in toRetrieve.enumerate() where articleUrl == url.absoluteString {
                        idx = i
                        break
                    }
                    
                    toRetrieve.removeAtIndex(idx)
                    NSUserDefaults(suiteName: "group.io.tinypixels.Accent")?.setObject(toRetrieve, forKey: "AccentArticlesToRetrieve")
                })
            }
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
        
        let bottomShadowPath = UIBezierPath(rect: bottomBar.bounds)
        bottomBar.layer.masksToBounds = false
        bottomBar.layer.shadowColor = UIColor.blackColor().CGColor
        bottomBar.layer.shadowOffset = CGSizeMake(0, -1)
        bottomBar.layer.shadowOpacity = 0.15
        bottomBar.layer.shadowPath = bottomShadowPath.CGPath
    }
    
    @IBAction func quizletButtonPressed(sender: UIButton) {
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
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        
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
    
    func updatedSelectedTab(index: Int) {
        tableView.reloadData()
    }
}
