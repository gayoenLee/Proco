//
//  CheckPhoneAuthCodable.swift
//  proco
//
//  Created by 이은호 on 2020/12/04.
//

import Foundation

struct CheckPhoneAuthCodable: Codable{
    let phone_num: String
    let auth_num: String
    let type: String
}
