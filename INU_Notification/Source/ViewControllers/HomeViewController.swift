//
//  HomeViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/25.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    private let keywordCellID: String = "HomeKeywordCell"
    // 연산 프로퍼티 적용, 배열을 encode 하여 저장
    private var keywordArray: [String] {
        get {
            var keywords: [String]?
            if let data = UserDefaults.standard.data(forKey: "keyword") {
                keywords = try? PropertyListDecoder().decode([String].self, from: data)
            }
            return keywords ?? []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.dataSource = self
//#if DEBUG
//        let firstLaunch: FirstLaunch = .alwaysFirst()
//#else
        let firstLaunch: FirstLaunch = .init(userDefaults: .standard, key: "isFirst")
//#endif
        if firstLaunch.isFirstLaunch {
            let updateAlert = UIAlertController(title: "처음이시군요!", message: "학과를 선택하러 가시겠어요?", preferredStyle: .alert)
            updateAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                // 유저가 ok버튼을 누르면 ViewController를 보여주잣..
                let vc = self.storyboard?.instantiateViewController(identifier: "MajorSelectViewController") as! MajorSelectViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }))
            present(updateAlert, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeCollectionView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: NoticeViewController = segue.destination as? NoticeViewController,
              let cell: HomeKeywordCollectionViewCell = sender as? HomeKeywordCollectionViewCell,
              let keyword: String  = cell.keywordTitleLabel.text else {
                  return
              }
        
        nextViewController.keyword = keyword
    }
}

//MARK: - Extension
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: keywordCellID, for: indexPath) as? HomeKeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: keywordArray[indexPath.item])
        if indexPath.item % 4 == 0 || indexPath.item % 4 == 3 {
            cell.backgroundColor = UIColor(hex: "#FED630")
            cell.layer.borderColor = UIColor(hex: "#FED630").cgColor
        } else {
            cell.backgroundColor = .none
            cell.layer.borderColor = UIColor(hex: "#FEDE59").cgColor
        }
        return cell
    }
}

//MARK: - CollectionViewCell

class HomeKeywordCollectionViewCell: UICollectionViewCell {
    
    let keywordTitleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    /**
     keywordCell에 UIButton을 추가 및 레이아웃을 설정해주는 역할을 합니다.
     */
    private func setupView() {
        keywordTitleLabel.font = .boldSystemFont(ofSize: 20)
        contentView.addSubview(keywordTitleLabel)
        
        keywordTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(11)
            make.top.equalToSuperview().inset(19)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 4
        layer.borderWidth = 2
        layer.borderColor = UIColor(hex: "FEDE59").cgColor
    }
    
    func configure(name: String?) {
        guard let name = name else { return }
        keywordTitleLabel.text = "#\(name)"
        keywordTitleLabel.textColor = .black
    }
}
