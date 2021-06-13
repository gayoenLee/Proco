//
//  AuthenticationData.swift
//  proco
//
//  Created by 이은호 on 2020/12/10.
//

import Foundation


struct AuthenticationData: Decodable{
    let result : String
    let access_token : String
    let refresh_token : String?
    
    enum CodingKeys: String, CodingKey{
        case result = "result"
        case access_token = "access_token"
        case refresh_token = "refresh_token"
    }
}
