//
//  KeywordListViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/09/02.
//

import UIKit

class KeywordListViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var keywordListCollectionView: UICollectionView!
    var keyword: String?
    let cellID: String = "keywordListCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        keywordListCollectionView.delegate = self
        keywordListCollectionView.dataSource = self
        backgroundView.layer.zPosition = -1
        keywordLabelConfigure()
        keywordListCollectionViewConfigure()
    }
    
    func keywordLabelConfigure() {
        keywordLabel.text = keyword
        keywordLabel.layer.cornerRadius = 25
        keywordLabel.layer.borderWidth = 1
        keywordLabel.layer.borderColor = UIColor.white.cgColor
        keywordLabel.backgroundColor = .white
        keywordLabel.layer.masksToBounds = true
    }
    
    func keywordListCollectionViewConfigure() {
        keywordListCollectionView.layer.cornerRadius = 2
        keywordListCollectionView.layer.borderWidth = 1
        keywordListCollectionView.layer.borderColor = UIColor.clear.cgColor
        keywordListCollectionView.layer.masksToBounds = true
    }
}

class KeywordListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 4
        layer.borderWidth = 2
        layer.borderColor = UIColor(hex: "#FED630").cgColor
    }
}
