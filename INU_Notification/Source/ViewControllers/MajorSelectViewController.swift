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
}

