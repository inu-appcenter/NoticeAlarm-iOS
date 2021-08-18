//
//  ViewController.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import UIKit

class MajorSelectViewController: UIViewController {
    
    @IBOutlet weak var completeButton: UIButton!
    
    var majors: [Major] = []
    var majorDictionary: [String: [String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
