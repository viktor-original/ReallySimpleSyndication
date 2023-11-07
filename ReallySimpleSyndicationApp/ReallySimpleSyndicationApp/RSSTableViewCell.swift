//
//  RSSTableViewCell.swift
//  ReallySimpleSyndicationApp
//
//  Created by Viktor Krasilnikov on 19.10.22.
//

import UIKit

class RSSTableViewCell: UITableViewCell {
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet{
            titleLabel.textColor = .systemOrange
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.textColor = .gray
        }
    }
    @IBOutlet weak var pubDateLabel: UILabel! {
        didSet {
            pubDateLabel.textColor = .lightGray
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pictureView.kf.cancelDownloadTask()
        pictureView.image = UIImage(systemName: "photo")
    }
    
    var item: RSSItem! {
        didSet {
            titleLabel.text = item.title
            descriptionLabel.text = item.description
            pubDateLabel.text = item.pubDate
        }
    }
    
}
