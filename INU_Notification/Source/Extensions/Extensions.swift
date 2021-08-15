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
extension MajorSelectViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView.tag {
        case 1:
            return majors.count
        case 2:
            guard let key = collegeTextField.text,
                  let array = majorDictionary[key] else {
                return 1
            }
            return array.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return majors[row].college
        case 2:
            guard let key = collegeTextField.text,
                  let array = majorDictionary[key] else {
                return nil
            }
            return array[row]
        default:
            return "Data Not Found"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch pickerView.tag {
        case 1:
            collegeTextField.text = majors[row].college
            if let array = majorDictionary[majors[row].college] {
                majorTextField.text = array.first
            }
            collegeTextField.resignFirstResponder()
        case 2:
            if let key = collegeTextField.text,
               let array = majorDictionary[key] {
                majorTextField.text = array[row]
                majorTextField.resignFirstResponder()
            }
        default:
            return
        }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        keywordArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? KeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: keywordArray[indexPath.item])
        return cell
    }
    
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
              let token = userDefault.string(forKey: "FCMtoken") else {
            present(simpleAlert(title: "오류", message: "토큰 또는 학과 설정이\n제대로 되어있지 않습니다!"), animated: true, completion: nil)
            return true
        }

        // 이미 등록한 키워드가 존재하는가?
        if keywordArray.firstIndex(where: {$0 == text}) != nil {
            present(simpleAlert(title: "오류", message: "이미 등록된 키워드입니다"), animated: true, completion: nil)
            return true
        }

        // MARK: Send to Server
        // let message: Message = Message(major: major, token: token, keywords: [text])
        // Message 객체가 아니라 Dictionary 타입으로 진행해볼 생각 중
        var message: [String: String] = [:]
        message["major"] = major
        message["token"] = token
        message["keyword"] = text
        let postRequest = APIRequest(endpoint: .addkeywords)


        var capturedKeywordArray = keywordArray
        let capturedKeywordCollectionView = registerKeywordsCollectionView

        // 데이터 전달!
        postRequest.send(message: message) { result in
            switch result {
            case .success(let response):
                print("The following message has been sent: '\(response)'")
                // UI변경은 메인 쓰레드로 동작해야하기 때문에 DispatchQueue 사용
                DispatchQueue.main.async {
                    textField.text = "" // UITextField 업데이트
                    capturedKeywordArray.append(text) // UserDefaults 업데이트
                    capturedKeywordCollectionView?.reloadData() // 키워드 reload
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
}
