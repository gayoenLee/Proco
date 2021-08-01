//
//  ResponseMakeCardStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
// 카드 만들기 후 response모델

import Foundation
import Combine

struct ResponseMakeCardStruct : Codable{
    var result: String? = ""
    var card_idx : Int? = -1
    var chatroom_idx : Int? = -1
    var server_idx : Int? = -1
    var tags : [Tags]? = []
    var card_photo_path : String? = ""

}

struct Tags : Codable{
    var idx : Int
    var tag_name : String
}


//모임 카드 편집 후 response
struct ResponseEditGroupCardStruct : Codable{
    var result : String? = ""
    var tags : [Tags]? = []
    var card_photo_path : String? = ""
    
}
