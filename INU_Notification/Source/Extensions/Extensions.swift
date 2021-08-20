//
//  Extensions.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

// MARK: - UIColor
extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
            
        }
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0, alpha: alpha)
    }
}

// MARK: - Bundle
extension Bundle {
    
    public var icon: UIImage? {
        
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last
        {
            return UIImage(named: icon)
        }
        
        return nil
    }
}

// MARK: - MajorSelectViewController
extension MajorSelectViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let college = selectedButtonText,
           let dic =  majorDictionary[college] {
            return dic.count
        } else {
            return majors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? MajorSelectCollectionViewCell else {
            return UICollectionViewCell()
        }
        var name: String?
        if isCollegeSelect, let text = selectedButtonText {
            name = majorDictionary[text]?[indexPath.item]
        } else {
            name = majors[indexPath.item].college
        }
        
        cell.configure(name: name)
        cell.collegeButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return cell
    }
    
    // 셀의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.contentSize
    }
    
    // 셀 선택했을 때 동작되는 Action코드
    @objc
    func tapButton(sender: UIButton) {
        selectedButtonText = sender.titleLabel?.text
        completeButton.isEnabled = true
        completeButton.backgroundColor = UIColor(hex: "142B6F")
    }
}

// MARK: - KeywordViewController
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
