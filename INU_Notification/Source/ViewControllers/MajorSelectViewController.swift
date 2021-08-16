//
//  ViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

class MajorSelectViewController: UIViewController {
    
    @IBOutlet weak var collegeTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!
    @IBOutlet weak var completeButton: UIButton!
    
    var collegePickerView: UIPickerView = UIPickerView()
    var majorPickerView: UIPickerView = UIPickerView()
    
    var majors: [Major] = []
    var majorDictionary: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collegeTextField.inputView = collegePickerView
        majorTextField.inputView = majorPickerView
        
        collegePickerView.delegate = self
        collegePickerView.dataSource = self
        collegePickerView.tag = 1
        
        majorPickerView.delegate = self
        majorPickerView.dataSource = self
        majorPickerView.tag = 2
        
        collegeTextField.placeholder = "단과대학을 선택해주세요"
        majorTextField.placeholder = "단과선택 후 학과를 선택해주세요"
        
        collegeTextField.textAlignment = .center
        majorTextField.textAlignment = .center
        
        completeButton.setTitle("완료", for: .normal)
        
        let jsonDecoder: JSONDecoder = JSONDecoder()
        guard let dataAsset: NSDataAsset = NSDataAsset(name: "INU") else {
            return
        }
        
        do {
            majors = try jsonDecoder.decode([Major].self, from: dataAsset.data)
            for major in majors {
                majorDictionary[major.college] = major.major
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func setMajor(_ sender: Any) {
        guard let college = collegeTextField.text, college != "",
              let major = majorTextField.text, major != "" else {
            present(simpleAlert(title: "오류", message: "학과를 정확하게 선택해주세요"), animated: true, completion: nil)
            return
        }
        
        let userDefault: UserDefaults = .standard
        guard let token = userDefault.string(forKey: "FCMToken") else { return }
        let postRequest = APIRequest(endpoint: .editMajor)
        var message: Message = [:]
        
        message["token"] = token
        message["major"] = major
        
        postRequest.send(message: message) { result in
            switch result {
            case .success(let response):
                print("The following message has been sent(editMajor): '\(response)'")
                UserDefaults.standard.set(major, forKey: "major")
                DispatchQueue.main.async { [self] in
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print("An error occured(editMajor) \(error)")
                DispatchQueue.main.async { [self] in
                    self.present(simpleAlert(title: "전송 실패", message: "서버 전송에 실패하였습니다.\nmessage: \(error)"), animated: true, completion: nil)
                }
            }
        }
    }
}
