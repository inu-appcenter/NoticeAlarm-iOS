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

// MARK: - Extension

extension KeywordViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    // 연산 프로퍼티 적용, 배열을 encode 하여 저장
    private var keywordArray: [String] {
        get {
            var keywords: [String]?
            if let data = UserDefaults.standard.data(forKey: "keyword") {
                keywords = try? PropertyListDecoder().decode([String].self, from: data)
            }
            return keywords ?? []
        }
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: "keyword")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? KeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: keywordArray[indexPath.item])
        cell.keywordButton.tag = indexPath.item
        cell.keywordButton.addTarget(self, action: #selector(deleteKeywords), for: .touchUpInside)
        return cell
    }
    
    // 셀의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return KeywordCollectionViewCell.fittingSize(availableHeight: 45, name: keywordArray[indexPath.item])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        /// textField에 `text`가 작성되어있는가?
        guard let text = textField.text, text != "" else {
            present(simpleAlert(title: "오류", message: "키워드를 입력해주세요!"), animated: true, completion: nil)
            return true
        }
        
        // UserDefaults에 토큰이나 학과 설정이 제대로 되어있는가
        let userDefault: UserDefaults = .standard
        guard let major = userDefault.string(forKey: "major"),
              let token = userDefault.string(forKey: "FCMToken") else {
            present(simpleAlert(title: "오류", message: "토큰 또는 학과 설정이\n제대로 되어있지 않습니다!"), animated: true, completion: nil)
            return true
        }
        
        // 이미 등록한 키워드가 존재하는가?
        if keywordArray.firstIndex(where: {$0 == text}) != nil {
            present(simpleAlert(title: "오류", message: "이미 등록된 키워드입니다"), animated: true, completion: nil)
            return true
        }
        
        // MARK: Send to Server
        var message: Message = [:]
        message["major"] = major
        message["token"] = token
        message["keyword"] = text
        let postRequest = APIRequest(endpoint: .addkeywords)
        
        // 데이터 전달!
        postRequest.send(message: message) { result in
            switch result {
            case .success(let response):
                print("The following message has been sent: '\(response)'")
                // UI변경은 메인 쓰레드로 동작해야하기 때문에 DispatchQueue 사용
                DispatchQueue.main.async { [unowned self] in
                    textField.text = "" // UITextField 업데이트
                    self.keywordArray.append(text) // UserDefaults 업데이트
                    self.registerKeywordsCollectionView.reloadData() // 키워드 reload
                }
            case .failure(let error):
                print("An error occured \(error)")
                // UI변경은 메인 쓰레드로 동작해야하기 때문에 DispatchQueue 사용
                DispatchQueue.main.async {
                    self.present(simpleAlert(title: "전송 실패", message: "서버 전송에 실패하였습니다.\nmessage: \(error)"), animated: true, completion: nil)
                }
            }
        }
        return true
    }
    
    /**
     키워드를 삭제합니다.
     */
    @objc
    func deleteKeywords(sender: UIButton) {
        let userDefault: UserDefaults = .standard
        guard let text = sender.titleLabel?.text,
              let token = userDefault.string(forKey: "FCMToken") else { return }
        let postRequest = APIRequest(endpoint: .deleteKeywords)
        let startIndex = text.index(text.startIndex, offsetBy: 1)
        var message: Message = [:]
        
        message["token"] = token
        message["keyword"] = String(text[startIndex...])
        
        postRequest.send(message: message) { result in
            switch result {
            case .success(_):
                // UI변경은 메인 쓰레드로 동작해야하기 때문에 DispatchQueue 사용
                DispatchQueue.main.async { [unowned self] in
                    // collectionView의 data를 먼저 삭제 후 데이터 배열 값 삭제
                    self.registerKeywordsCollectionView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
                    self.keywordArray.remove(at: sender.tag)
                    self.registerKeywordsCollectionView.reloadData()
                }
            case .failure(let error):
                switch error {
                case .responseProblem:
                    DispatchQueue.main.async { [unowned self] in
                        self.present(simpleAlert(title: "전송 실패", message: "서버 전송에 실패하였습니다.\n네트워크를 확인해주세요."), animated: true, completion: nil)
                    }
                case .decodingProblem:
                    DispatchQueue.main.async { [unowned self] in
                        let alert = UIAlertController(title: "오류", message: "서버에 등록되어있지 않는 키워드입니다.\n삭제하시겠습니까?", preferredStyle: .alert)
                        // 키워드가 서버에 없을 때 기존 키워드 그냥 삭제할 경우
                        let okAction = UIAlertAction(title:"확인",style:.default) { _ in
                            // collectionView cell 삭제
                            self.registerKeywordsCollectionView.deleteItems(at: [IndexPath.init(row: sender.tag, section: 0)])
                            // 데이터 배열 값 삭제
                            self.keywordArray.remove(at: sender.tag)
                            self.registerKeywordsCollectionView.reloadData()
                        }
                        let cancelAction = UIAlertAction(title:"취소",style:.destructive)
                        alert.addAction(cancelAction)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                default: break
                }
            }
        }
    }
}

//MARK: - CollectionViewCell

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
