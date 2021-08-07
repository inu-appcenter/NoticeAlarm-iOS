//
//  KeywordViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/02.
//

import UIKit

class KeywordViewController: UIViewController {
    
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var keywordTableView: UITableView!
    let cellID: String = "keywordCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keywordTableView.delegate = self
        keywordTableView.dataSource = self
        keywordTextField.delegate = self
        
        keywordTextField.placeholder = "키워드를 입력해주세요"
        keywordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
