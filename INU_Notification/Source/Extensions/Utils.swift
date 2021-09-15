//
//  Utils.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/03.
//

import UIKit

typealias Message = [String:String]

/**
 json을 파싱받을 단과별 학과 관련 구조체.
 각 college에 따른 major가 포함되어있다.
 - college: 단과대학을 나타냅니다.
 - major: 학과를 나타내며 단과대학에 의존적입니다.
 */
struct Major: Codable {
    let college: String
    let major: [String]
}

/**
 공지를 보여줄 때 필요한 구조체
 
 title: 공지 제목입니다.
 
 url: 공지`url`이 들어가 있습니다.
 
 
- Note:
    공지가 올라온 시간이나 일부 내용도 넣고싶은데 안될 듯 ㅜ

 */
struct Notice: Codable {
    let title: String
    let url: String
}


/**
    단순한 Alert 창인 AlertController를 리턴하는 메소드입니다.
    title 에는 알림 제목이, message에는 알림 내용이 들어갑니다.
 
    - Parameters:
        - title: 알람의 제목이 되는 공간입니다.
        - message: 알림의 주 내용을 작성하는 공간입니다.
 
    - Returns: 간단하게 제작된 UIAlertController를 반환합니다.
 
 */
func simpleAlert(title:String, message msg:String) -> UIAlertController {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    let okAction = UIAlertAction(title:"확인",style:.default)
    let cancelAction = UIAlertAction(title:"취소",style:.cancel)
    
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    return alert
}
