//
//  KeywordViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/02.
//

import UIKit

class KeywordViewController: UIViewController {
    
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var selectMajorButton: UIButton!
    @IBOutlet weak var registerKeywordLabel: UILabel!
    @IBOutlet weak var popularKeywordLabel: UILabel!
    @IBOutlet weak var registerKeywordsCollectionView: UICollectionView!
    
    let cellID: String = "registerKeywordCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerKeywordsCollectionView.dataSource = self
        keywordTextField.delegate = self
        
        keywordTextField.placeholder = "키워드를 입력해주세요"
        keywordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        selectMajorButton.setTitle("학과 변경", for: .normal)
        registerKeywordLabel.text = "등록 키워드"
        popularKeywordLabel.text = "인기 키워드"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkMajor()
    }
    
    
    //
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

class KeywordCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var keywordButton: UIButton!
}
