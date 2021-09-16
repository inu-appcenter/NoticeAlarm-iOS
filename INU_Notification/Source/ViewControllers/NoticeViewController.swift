//
//  KeywordListViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/09/02.
//

import UIKit

class NoticeViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var keywordLabel: UILabel!
    @IBOutlet weak var keywordListCollectionView: UICollectionView!
    var keyword: String?
    private let cellID: String = "noticeListCell"
    // 연산 프로퍼티 적용, 배열을 encode 하여 저장
    private var noticeArray: [Notice] {
        get {
            var notices: [Notice]?
            if let data = UserDefaults.standard.data(forKey: keyword!) {
                notices = try? PropertyListDecoder().decode([Notice].self, from: data)
            }
            return notices ?? []
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: keyword!)
        }
    }
    
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
        keywordListCollectionView.layer.cornerRadius = 16.6666
        keywordListCollectionView.layer.borderWidth = 1
        keywordListCollectionView.layer.borderColor = UIColor.clear.cgColor
        keywordListCollectionView.layer.masksToBounds = true
    }
}
// MARK: - Extension

extension NoticeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
//        return noticeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? KeywordListCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.title.text = "2021-2학기 수강신청 일정 안내"
        cell.content.text = "2021학년도 2학기 수강신청 일정을 아래와 같이 안내하오니 학생들이 해당기간내에 수강..."
//        cell.title.text = noticeArray[indexPath.item].title
//        cell.content.text = noticeArray[indexPath.item].url
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let slideViewController = NoticeDetailViewController()
        slideViewController.modalPresentationStyle = .custom
        slideViewController.transitioningDelegate = self
        self.present(slideViewController, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}


// MARK: - CollectionViewCell

class KeywordListCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 6
        layer.borderWidth = 2
        layer.borderColor = UIColor(hex: "#FED630").cgColor
    }
}
