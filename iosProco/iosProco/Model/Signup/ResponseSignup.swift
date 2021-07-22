//
//  ResponseSignup.swift
//  proco
//
//  Created by 이은호 on 2020/12/08.
//

import Foundation

struct ResponseSignup: Codable{
    var result : String
    var access_token: String
    var refresh_token: String
    var idx: Int
    var nickname: String
    var profile_photo_path : String?
    
}
