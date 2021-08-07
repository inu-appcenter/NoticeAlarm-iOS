//
//  Extensions.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

// MARK: MajorSelectViewController
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

// MARK: KeywordViewController
extension KeywordViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        keywordArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        cell.textLabel?.text = keywordArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            keywordArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        /// textField에 `text`가 작성되어있는가?
        guard let text = textField.text, text != "" else {
            present(simpleAlert(title: "오류", message: "키워드를 입력해주세요!"), animated: true, completion: nil)
            return true
        }
        
        // 이미 등록한 키워드가 존재하는가?
        if keywordArray.firstIndex(where: {$0 == text}) != nil {
            present(simpleAlert(title: "오류", message: "이미 등록된 키워드입니다"), animated: true, completion: nil)
            return true
        }
        
        keywordArray.append(text)
        textField.text = ""
        keywordTableView.reloadData()
        
        
        
        // UserDefaults 읽어서 서버로 보내자
        
        
        return true
    }
}
