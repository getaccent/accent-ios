//
//  ArticlesViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import DigitsKit
import MGSwipeTableCell
import RealmSwift
import UIKit

class ArticlesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AccentTabBarDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var topBarLabel: UILabel!
    @IBOutlet weak var quizletButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var overlayImage: UIImageView!
    @IBOutlet weak var overlayText: UILabel!
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
        
        let articlesText = NSLocalizedString("Articles", comment: "news articles")
        topBarLabel.text = articlesText
        
        let home = NSLocalizedString("Home", comment: "homepage")
        let browse = NSLocalizedString("Browse", comment: "browse articles")
        
        let tabs = [AccentTab(name: home, image: UIImage(named: "Home")!), AccentTab(name: browse, image: UIImage(named: "Browse")!)]
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
        
        overlayView.alpha = bottomBar.selectedTab == 0 && savedArticles.count == 0 ? 1 : 0
        overlayText.text = NSLocalizedString("When you save an article to Accent, it will be listed here.", comment: "")
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
            
            if setId > 0 {
                let url = NSURL(string: "https://quizlet.com/\(setId)/")!
                Quizlet.sharedInstance.openSetWithURL(self, url: url)
            } else {
                let controller = UIAlertController(title: "No Set", message: "No sets have been created on your Quizlet account. Translate some words to create one automatically!", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                controller.addAction(action)
                presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func settingsButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("settingsSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let avc = segue.destinationViewController as? ArticleViewController {
            avc.article = articleToSend
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIDevice.currentDevice().userInterfaceIdiom == .Phone ? (indexPath.row % 5 == 0 ? 312 : 136) : 192
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        
        let cell = NSBundle.mainBundle().loadNibNamed(UIDevice.currentDevice().userInterfaceIdiom == .Phone ? (indexPath.row % 5 == 0 ? (article.imageUrl == nil ? "NoImageArticleCell" : "LargeArticleCell") : (article.imageUrl == nil ? "NoImageArticleCell" : "ArticleCell")) : (article.imageUrl == nil ? "PadNoImageArticleCell" : "PadArticleCell"), owner: self, options: nil)[0] as! ArticleCell
        cell.configure(articles[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        articleToSend = articles[indexPath.row]
        performSegueWithIdentifier("articleSegue", sender: nil)
    }
    
    func updatedSelectedTab(index: Int) {
        overlayView.alpha = (index == 0 && savedArticles.count == 0) || (index == 1 && browseArticles.count == 0) ? 1 : 0
        overlayImage.image = UIImage(named: index == 0 ? "Home Outline" : "Sad Face")
        overlayText.text = index == 0 ? NSLocalizedString("When you save an article to Accent, it will be listed here.", comment: "") : NSLocalizedString("No articles could be found at this time. Please try again later.", comment: "")
        tableView.reloadData()
    }
    
    func iconize(image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context = UIGraphicsGetCurrentContext()
        UIColor.accentDarkColor().setFill()
        
        CGContextTranslateCTM(context, 0, image.size.height)
        CGContextScaleCTM(context, 1, -1)
        CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
        CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        var buttons = [MGSwipeButton]()
        
        func createButton(imageName: String) -> MGSwipeButton {
            let button = MGSwipeButton(title: "", icon: iconize(UIImage(named: imageName)!), backgroundColor: UIColor.whiteColor())
            buttons.append(button)
            return button
        }
        
        if bottomBar.selectedTab == 0 {
            createButton("Share")
            createButton("Delete")
            createButton("Archive")
        } else {
            createButton("Share")
            
            if let article = (cell as? ArticleCell)?.article {
                if savedArticles.indexOf({ $0 == article }) == nil {
                    createButton("Save")
                }
            } else {
                createButton("Save")
            }
        }
        
        for button in buttons {
            button.buttonWidth = UIScreen.mainScreen().bounds.width / CGFloat(buttons.count)
        }
        
        return buttons
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        func shareButton() {
            guard let articleUrl = (cell as? ArticleCell)?.article?.articleUrl else {
                return
            }
            
            let activityController = UIActivityViewController(activityItems: [articleUrl], applicationActivities: nil)
            self.presentViewController(activityController, animated: true, completion: nil)
        }
        
        if bottomBar.selectedTab == 0 {
            switch index {
            case 0: // share button
                shareButton()
            case 1: // delete button
                guard let indexPath = tableView.indexPathForCell(cell) else {
                    return true
                }
                
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
                
                savedArticles.removeAtIndex(indexPath.row)
                
                tableView.endUpdates()
                
                UIView.animateWithDuration(0.25, animations: {
                    self.overlayView.alpha = self.savedArticles.count == 0 ? 1 : 0
                })
            case 2: // archive button
                break
            default:
                break
            }
        } else {
            switch index {
            case 0: // share button
                shareButton()
            case 1: // save button
                guard let indexPath = tableView.indexPathForCell(cell) else {
                    return true
                }
                
                let article = browseArticles[indexPath.row]
                savedArticles.append(article)
                
                cell.refreshButtons(true)
                
                if let phoneNumber = Digits.sharedInstance().session()?.phoneNumber {
                    Accent.sharedInstance.saveArticle(phoneNumber, url: article.articleUrl, completion: { (success) in
                        print("saved")
                    })
                }
            default:
                break
            }
        }
        
        return true
    }
}
