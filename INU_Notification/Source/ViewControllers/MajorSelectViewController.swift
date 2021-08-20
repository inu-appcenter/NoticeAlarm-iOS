//
//  ViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

class MajorSelectViewController: UIViewController {
    
    @IBOutlet weak var selectCollectionView: UICollectionView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!
    
    var majors: [Major] = []
    var majorDictionary: [String: [String]] = [:]
    var isCollegeSelect: Bool = false
    var selectedButtonText: String?
    let cellID = "MajorSelectCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completeButton.isEnabled = false // 초기에는 버튼 비활성화
        completeButton.backgroundColor = UIColor(hex: "CCCCCC")
        
        selectCollectionView.dataSource = self
        
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
    @IBAction func saveMajor(_ sender: Any) {
        guard let text = selectedButtonText else { return }
        
        // 단과대학을 선택했으면 nil이 나오지 않으므로 if문 내부로 들어감
        if let _ = majorDictionary[text] {
            isCollegeSelect = true
            
            // UI part
            mainLabel.text = "학과를 선택해주세요"
            completeButton.setTitle("완료", for: .normal)
            completeButton.isEnabled = false
            completeButton.backgroundColor = UIColor(hex: "CCCCCC")
            selectCollectionView.reloadData()
            
        } else { // 학과를 선택했을 경우
            let userDefault: UserDefaults = .standard
            guard let token = userDefault.string(forKey: "FCMToken"),
                  let majorButtonText = selectedButtonText else { return }
            
            let index = majorButtonText.index(majorButtonText.endIndex, offsetBy: -3)
            let postRequest = APIRequest(endpoint: .editMajor)
            var message: Message = [:]
            let major: String
            if majorButtonText[index...] == "(야)" {
                major = String(majorButtonText[..<index]) // `(야)`를 없앰
            } else {
                major = majorButtonText
            }
            
            message["token"] = token
            message["major"] = major
            print(major)
            
            postRequest.send(message: message) { result in
                switch result {
                case .success(let response):
                    print("The following message has been sent(editMajor): '\(response)'")
                    UserDefaults.standard.set(major, forKey: "major")
                    DispatchQueue.main.async { [unowned self] in
                        self.dismiss(animated: true, completion: nil)
                    }
                case .failure(let error):
                    print("An error occured(editMajor) \(error)")
                    DispatchQueue.main.async { [unowned self] in
                        self.present(simpleAlert(title: "전송 실패", message: "서버 전송에 실패하였습니다.\nmessage: \(error)"), animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

class MajorSelectCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collegeButton: UIButton!
    
    /**
     Cell에 UIButton을 추가 및 레이아웃을 설정해주는 역할을 합니다.
     */
    //    private func setupView() {
    //        contentView.addSubview(collegeButton)
    //        collegeButton.snp.makeConstraints { maker in
    //            maker.edges.equalToSuperview().inset(10)
    //        }
    //    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor(hex: "142B6F").cgColor
    }
    
    func configure(name: String?) {
        guard let name = name else { return }
        collegeButton.setTitle("\(name)", for: .normal)
        collegeButton.setTitleColor(.black, for: .normal)
    }
}
