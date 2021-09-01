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

}


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
