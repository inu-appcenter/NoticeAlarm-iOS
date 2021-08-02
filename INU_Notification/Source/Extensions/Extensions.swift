//
//  Extensions.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

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
