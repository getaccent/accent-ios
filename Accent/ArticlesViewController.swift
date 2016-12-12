//
//  ArticlesViewController.swift
//  Accent
//
//  Created by Jack Cook on 4/9/16.
//  Copyright © 2016 Tiny Pixels. All rights reserved.
//

import MGSwipeTableCell
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
    
    private var refreshControl: UIRefreshControl!
    
    private var articles: [Article] {
        return bottomBar.selectedTab == 0 ? savedArticles : browseArticles
    }
    
    private var browseArticles = [Article]()
    private var savedArticles = [Article]()
    private var articleToSend: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        savedArticles = Accent.sharedInstance.getLocalArticles()
        reloadTableView(false)
        
        Accent.sharedInstance.retrieveArticles { (articles) in
            guard let articles = articles else {
                return
            }
            
            self.browseArticles = articles
            self.reloadTableView(true)
        }
        
        quizletButton.setImage(quizletButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        quizletButton.tintColor = UIColor.accentDarkColor()
        
        settingsButton.setImage(settingsButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
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
        
        tableView.backgroundColor = UIColor.white
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        updateSavedArticles()
        NotificationCenter.default.addObserver(self, selector: #selector(updateSavedArticles), name: NSNotification.Name(rawValue: AccentApplicationWillEnterForeground), object: nil)
    }
    
    func updateSavedArticles() {
        guard let toRetrieve = UserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArray(forKey: "AccentArticlesToRetrieve") else {
            return
        }
        
        for urlString in toRetrieve {
            if let url = URL(string: urlString) {
                Accent.sharedInstance.parseArticle(url, completion: { (article) in
                    guard let article = article else {
                        return
                    }
                    
                    self.savedArticles.append(article)
                    self.reloadTableView(true)
                    
                    guard var toRetrieve = UserDefaults(suiteName: "group.io.tinypixels.Accent")?.stringArray(forKey: "AccentArticlesToRetrieve") else {
                        return
                    }
                    
                    var idx = 0
                    
                    for (i, articleUrl) in toRetrieve.enumerated() where articleUrl == url.absoluteString {
                        idx = i
                        break
                    }
                    
                    toRetrieve.remove(at: idx)
                    UserDefaults(suiteName: "group.io.tinypixels.Accent")?.set(toRetrieve, forKey: "AccentArticlesToRetrieve")
                })
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let topShadowPath = UIBezierPath(rect: topBar.bounds)
        topBar.layer.masksToBounds = false
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBar.layer.shadowOpacity = 0.15
        topBar.layer.shadowPath = topShadowPath.cgPath
        
        let bottomShadowPath = UIBezierPath(rect: bottomBar.bounds)
        bottomBar.layer.masksToBounds = false
        bottomBar.layer.shadowColor = UIColor.black.cgColor
        bottomBar.layer.shadowOffset = CGSize(width: 0, height: -1)
        bottomBar.layer.shadowOpacity = 0.15
        bottomBar.layer.shadowPath = bottomShadowPath.cgPath
    }
    
    @IBAction func quizletButtonPressed(_ sender: UIButton) {
        if Quizlet.sharedInstance.accessToken == nil {
            Quizlet.sharedInstance.beginAuthorization(self)
        } else {
            let setId = Quizlet.sharedInstance.setId
            
            if setId > 0 {
                let url = URL(string: "https://quizlet.com/\(setId)/")!
                Quizlet.sharedInstance.openSetWithURL(self, url: url)
            } else {
                let controller = UIAlertController(title: NSLocalizedString("No Set", comment: ""), message: NSLocalizedString("No sets have been created on your Quizlet account. Translate some words to create one automatically!", comment: ""), preferredStyle: .alert)
                let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                
                controller.addAction(action)
                present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let avc = segue.destination as? ArticleViewController {
            avc.article = articleToSend
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .phone ? (indexPath.row % 5 == 0 ? 312 : 136) : 192
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = articles[indexPath.row]
        
        let cell = Bundle.main.loadNibNamed(UIDevice.current.userInterfaceIdiom == .phone ? (indexPath.row % 5 == 0 ? (article.image == "" ? "NoImageArticleCell" : "LargeArticleCell") : (article.image == "" ? "NoImageArticleCell" : "ArticleCell")) : (article.image == "" ? "PadNoImageArticleCell" : "PadArticleCell"), owner: self, options: nil)?[0] as! ArticleCell
        cell.configure(articles[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        articleToSend = articles[indexPath.row]
        performSegue(withIdentifier: "articleSegue", sender: nil)
    }
    
    func reloadTableView(_ animated: Bool) {
        DispatchQueue.main.async {
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.overlayView.alpha = (self.bottomBar.selectedTab == 0 && self.savedArticles.count == 0) || (self.bottomBar.selectedTab == 1 && self.browseArticles.count == 0) ? 1 : 0
                }
            } else {
                self.overlayView.alpha = (self.bottomBar.selectedTab == 0 && self.savedArticles.count == 0) || (self.bottomBar.selectedTab == 1 && self.browseArticles.count == 0) ? 1 : 0
            }
            
            self.overlayImage.image = UIImage(named: self.bottomBar.selectedTab == 0 ? "Home Outline" : "Sad Face")
            self.overlayText.text = self.bottomBar.selectedTab == 0 ? NSLocalizedString("When you save an article to Accent, it will be listed here.", comment: "") : NSLocalizedString("No articles could be found at this time. Please try again later.", comment: "")
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refresh(_ control: UIRefreshControl) {
        if bottomBar.selectedTab == 0 {
            Accent.sharedInstance.getSavedArticles { (articles) in
                guard let articles = articles else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                    
                    return
                }
                
                self.savedArticles = articles
                self.reloadTableView(true)
            }
        } else {
            Accent.sharedInstance.retrieveArticles { (articles) in
                guard let articles = articles else {
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                    
                    return
                }
                
                self.browseArticles = articles
                self.reloadTableView(true)
            }
        }
    }
    
    func updatedSelectedTab(_ index: Int) {
        reloadTableView(false)
    }
    
    func iconize(_ image: UIImage) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context = UIGraphicsGetCurrentContext()
        UIColor.accentDarkColor().setFill()
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1, y: -1)
        context?.clip(to: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), mask: image.cgImage!)
        context?.fill(CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, canSwipe direction: MGSwipeDirection) -> Bool {
        return true
    }
    
    private func swipeTableCell(_ cell: MGSwipeTableCell!, swipeButtonsForDirection direction: MGSwipeDirection, swipeSettings: MGSwipeSettings!, expansionSettings: MGSwipeExpansionSettings!) -> [AnyObject]! {
        var buttons = [MGSwipeButton]()
        
        func createButton(_ imageName: String) {
            let button = MGSwipeButton(title: "", icon: iconize(UIImage(named: imageName)!), backgroundColor: UIColor.white)
            buttons.append(button)
        }
        
        if bottomBar.selectedTab == 0 {
            createButton("Share")
            createButton("Delete")
            createButton("Archive")
        } else {
            createButton("Share")
            
            if let article = (cell as? ArticleCell)?.article {
                if savedArticles.index(where: { $0 == article }) == nil {
                    createButton("Save")
                }
            } else {
                createButton("Save")
            }
        }
        
        for button in buttons {
            button.buttonWidth = UIScreen.main.bounds.width / CGFloat(buttons.count)
        }
        
        return buttons
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        func shareButton() {
            guard let articleUrl = (cell as? ArticleCell)?.article?.url else {
                return
            }
            
            let activityController = UIActivityViewController(activityItems: [articleUrl], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        if bottomBar.selectedTab == 0 {
            switch index {
            case 0: // share button
                shareButton()
            case 1: // delete button
                guard let indexPath = tableView.indexPath(for: cell) else {
                    return true
                }
                
                let article = savedArticles[indexPath.row]
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .right)
                
                savedArticles.remove(at: indexPath.row)
                
                tableView.endUpdates()
                
                Accent.sharedInstance.deleteSavedArticle(article)
                
                UIView.animate(withDuration: 0.25, animations: {
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
                guard let indexPath = tableView.indexPath(for: cell) else {
                    return true
                }
                
                let article = browseArticles[indexPath.row]
                savedArticles.append(article)
                
                cell.refreshButtons(true)
                
                Accent.sharedInstance.saveArticle(article) { (success) in
                    print("saved")
                }
            default:
                break
            }
        }
        
        return true
    }
}
