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
    
    var majors: [Major] = []
    var majorDictionary: [String: [String]] = [:]
    let cellID = "MajorSelectCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        layer.borderColor = UIColor(hex: "14286F").cgColor
    }

    func configure(name: String?) {
        guard let name = name else { return }
        collegeButton.setTitle("\(name)", for: .normal)
        collegeButton.setTitleColor(.black, for: .normal)
    }
}
