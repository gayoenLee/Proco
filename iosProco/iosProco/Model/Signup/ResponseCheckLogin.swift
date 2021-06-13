//
//  ResponseCheckLogin.swift
//  proco
//
//  Created by 이은호 on 2020/12/09.
//

import Foundation



struct ResponseCheckLogin: Codable{
    
    var result: String
    var access_token: String?
    var refresh_token: String?
    var idx: Int?
    var nickname: String?
}
