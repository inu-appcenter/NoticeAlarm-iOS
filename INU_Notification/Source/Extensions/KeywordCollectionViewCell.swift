//
//  KeywordCollectionViewCell.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/19.
//

import UIKit

class KeywordCollectionViewCell: UICollectionViewCell {

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
        contentView.addSubview(keywordButton)
        
        keywordButton.snp.makeConstraints { maker in
            maker.edges.equalToSuperview().inset(10)
        }
    }

    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = KeywordCollectionViewCell()
        cell.configure(name: name)
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.lightGray.cgColor
        
    }

    func configure(name: String?) {
        guard let name = name else { return }
        keywordButton.setTitle("#\(name)", for: .normal)
        keywordButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        keywordButton.semanticContentAttribute = .forceRightToLeft
        keywordButton.tintColor = .lightGray
        keywordButton.setTitleColor(.lightGray, for: .normal)
    }
}
