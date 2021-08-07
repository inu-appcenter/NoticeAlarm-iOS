//
//  Utils.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/08/03.
//

import UIKit

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
