//
//  KeywordViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/02.
//

import UIKit
import SnapKit

class KeywordViewController: UIViewController {
    
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var selectMajorButton: UIButton!
    @IBOutlet weak var registerKeywordLabel: UILabel!
    @IBOutlet weak var popularKeywordLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var registerKeywordsCollectionView: UICollectionView!
    
    let cellID: String = "registerKeywordCell"
    
    
    //MARK: - App Cycle Part
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeywordsCollectionView.dataSource = self
        keywordTextField.delegate = self
        
        
        // keyword textfield 설정 구간
        keywordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        keywordTextField.clearButtonMode = .always

        // keyword textfield border 설정 구간
        keywordTextField.borderStyle = .none
        keywordTextField.layer.borderWidth = 2
        keywordTextField.layer.cornerRadius = 15
        keywordTextField.layer.borderColor = UIColor(hex: "14286F").cgColor

        // keyword textfield 왼쪽 아이콘 설정 구간
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.image!.size.width + 10.0, height: imageView.image!.size.height)
        imageView.contentMode = .center
        keywordTextField.leftView = imageView
        keywordTextField.leftViewMode = .always
        keywordTextField.leftView?.tintColor = .lightGray

        iconImageView.image = Bundle.main.icon
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // checkMajor()
    }
    
    //MARK: - Delegate Part
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if let isWhiteSpaceExists = keywordTextField.text?.contains(" "),
           isWhiteSpaceExists {
            present(simpleAlert(title: "오류", message: "띄어쓰기는 할 수 없습니다!"), animated: true, completion: nil)
            keywordTextField.text = keywordTextField.text?.trimmingCharacters(in: .whitespaces)
        }
    }
    
    //MARK: - 사용자 정의 함수 part
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 5, left: 16, bottom: 5, right: 16)
        
        
        registerKeywordsCollectionView.setCollectionViewLayout(flowLayout, animated: false)
        registerKeywordsCollectionView.delegate = self
        registerKeywordsCollectionView.dataSource = self
        registerKeywordsCollectionView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
    }

    /// 사용자가 학과를 선택했는지 확인합니다.
    func checkMajor() {

        // UserDefaults에 학과가 저장이 되었는가?
        if let major = UserDefaults.standard.string(forKey: "major"), major != "" {
            print(major)
        } else {
            // 알람 나와랏
            let updateAlert = UIAlertController(title: "경고", message: "이용을 위해 학과를 무조건! 선택하셔야합니다. 선택하러 가시겠어요?", preferredStyle: .alert)
            updateAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                // 유저가 ok버튼을 누르면 ViewController를 보여주잣..
                let vc = self.storyboard?.instantiateViewController(identifier: "MajorSelectViewController") as! MajorSelectViewController
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            }))
            present(updateAlert, animated: true)
            
        }
    }    
}

//MARK: - KeywordCollectionViewCell
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
