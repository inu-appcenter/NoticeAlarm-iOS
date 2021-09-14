//
//  HomeViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/25.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    let keywordCellID: String = "HomeKeywordCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homeCollectionView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController: KeywordListViewController = segue.destination as? KeywordListViewController,
              let cell: HomeKeywordCollectionViewCell = sender as? HomeKeywordCollectionViewCell else {
            return
        }
        
        nextViewController.keyword = cell.keywordButton.titleLabel?.text
    }
}

//MARK: - Extension
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        }
        return cell
    }
}

//MARK: - CollectionViewCell

class HomeKeywordCollectionViewCell: UICollectionViewCell {
    
    let keywordButton: UIButton = UIButton()
    
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
        keywordButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        contentView.addSubview(keywordButton)
        
        keywordButton.snp.makeConstraints { make in
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
        keywordButton.setTitle("#\(name)", for: .normal)
        keywordButton.setTitleColor(.black, for: .normal)
    }
}
