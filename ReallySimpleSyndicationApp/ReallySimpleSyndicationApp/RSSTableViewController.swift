//
//  RSSTableViewController.swift
//  ReallySimpleSyndicationApp
//
//  Created by Viktor Krasilnikov on 19.10.22.
//

import UIKit
import SafariServices
import Kingfisher

class RSSTableViewController: UITableViewController {
    
    private var rssItems: [RSSItem]? = []
    private var rssImages: [String] = []
    private var rssRows: Int? = 0
    private var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = UserManager.shared.url {
            self.url =  url
        }
        setupUI()
        loadFeed(url: url)
    }
    
    private func setupUI() {
        title = "📰 RSS Feed"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .systemGray5
        tableView.estimatedRowHeight = 150
    }
    
    private func loadFeed(url: String) {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: url) {
            (rssItems, rssImgs) in
            UserManager.shared.url = url
            self.rssItems = rssItems
            self.rssImages = rssImgs
            self.rssRows = rssItems.count
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: TableView setup
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = rssRows {
            return rows
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RSSTableViewCell
        if let item = rssItems?[indexPath.item] {
            cell.item = item
        }
        if !self.rssImages.isEmpty {
            let imgURL = URL(string: self.rssImages[indexPath.row])
            DispatchQueue.main.async(execute: {
                cell.pictureView.kf.indicatorType = .activity
                let processor = DownsamplingImageProcessor(size: CGSize(width: 75, height: 75))
                cell.pictureView.kf.setImage(with: imgURL, options: [.processor(processor)])
            })
        }
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(white: 1, alpha: 1)
        } else {
            cell.backgroundColor = UIColor(white: 1, alpha: 0.5)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = rssItems?[indexPath.item] {
            if let url = URL(string: item.link) {
                let urlVC = SFSafariViewController(url: url)
                urlVC.modalPresentationStyle = .overFullScreen
                present(urlVC, animated: true)
            }
        }
    }

    //MARK: Actions
    
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        loadFeed(url: url)
    }
    
    @IBAction func editUrlTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Edit RSS URL", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.text = UserManager.shared.url
            }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                if let someURL = alertController.textFields![0].text {
                    if someURL.isValidUrl() && someURL.contains("rss") {
                        self.loadFeed(url: someURL)
                        self.url = someURL
                    } else {
                        let alertController = UIAlertController(title: "Not valid URL!", message: "", preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
