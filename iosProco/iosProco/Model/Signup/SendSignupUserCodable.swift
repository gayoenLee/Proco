//
//  SendSignupUserCodable.swift
//  proco
//
//  Created by 이은호 on 2020/12/08.
//

import Foundation

struct SendSignupUserCodable: Codable{
    var phone: String
    var email: String
    var password: String
    var gender: Int
    var birthday: String
    var nickname: String
    var marketing_yn : String
    var auth_num: String
    var sign_device: String?
    var update_version: String?
    
}
