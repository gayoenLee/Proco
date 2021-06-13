//
//  ResponseMakeCardStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
//

import Foundation
import Combine

struct ResponseMakeCardStruct : Codable{
    var result: String
    var card_idx : Int
    var chatroom_idx : Int
    var server_idx : Int
    var tags : [Tags]
    
}

struct Tags : Codable{
    var idx : Int
    var tag_name : String
}
