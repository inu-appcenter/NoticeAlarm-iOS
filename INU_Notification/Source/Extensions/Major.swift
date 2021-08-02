//
//  Major.swift
//  INU_Notification
//
//  Created by 홍승현 on 2021/07/29.
//

import Foundation

/// json을 파싱받을 단과별 학과 관련 구조체
struct Major: Codable {
    let college: String
    let major: [String]
}
