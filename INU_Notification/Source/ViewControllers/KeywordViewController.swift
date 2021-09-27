//
//  KeywordViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/02.
//

import UIKit
import SnapKit

class KeywordViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var registerKeywordsCollectionView: UICollectionView!
    @IBOutlet weak var searchSubView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    private let cellID: String = "registerKeywordCell"
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
    
    
    //MARK: App Cycle Part
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeywordsCollectionView.delegate = self
        registerKeywordsCollectionView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        iconImageView.image = UIImage(named: "logo")
        
        setSearchTextFieldUI()
    }
    
    //MARK: Delegate Part
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ sender: Any?) {
        if let isWhiteSpaceExists = searchTextField.text?.contains(" "),
           isWhiteSpaceExists {
            present(simpleAlert(title: "오류", message: "띄어쓰기는 할 수 없습니다!"), animated: true, completion: nil)
            searchTextField.text = searchTextField.text?.trimmingCharacters(in: .whitespaces)
        }
    }
    
    //MARK: Custom Part
    
    func setSearchTextFieldUI() {
        
        // search textfield border 설정 구간
        searchTextField.borderStyle = .none
        searchSubView.layer.cornerRadius = 20
        searchSubView.layer.borderWidth = 2
        searchSubView.layer.borderColor = UIColor(hex: "#142B6F").cgColor
    }
    
    @IBAction func deleteSearchText(_ sender: Any) {
        searchTextField.text = ""
    }
}

// MARK: - Extension

extension KeywordViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
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
        return KeywordCollectionViewCell.fittingSize(availableHeight: 40, name: keywordArray[indexPath.item])
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
    @objc func deleteKeywords(sender: UIButton) {
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
        
        keywordButton.snp.makeConstraints { make in
            //            make.edges.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(12)
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(9)
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
        keywordButton.titleLabel?.font = UIFont(name: keywordButton.titleLabel?.font.fontName ?? "", size: 16)
        keywordButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        keywordButton.semanticContentAttribute = .forceRightToLeft
        keywordButton.tintColor = .lightGray
        keywordButton.setTitleColor(.black, for: .normal)
    }
}
