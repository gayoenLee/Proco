//
//  PhoneAuth.swift
//  proco
//
//  Created by 이은호 on 2020/12/03.
// 네트워크 요청 후 json 데이터를 클래스 및 구조체로 변환할 모델

import Foundation

struct PhoneAuthCodable: Codable{
    let phone_num: String
    let type: String
}

