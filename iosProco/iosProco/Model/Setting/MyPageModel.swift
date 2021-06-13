//
//  MyPageModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/24.
//

import Foundation

struct MyPageModel: Codable{

    var nickname: String = ""
    var password_modify_at : String = ""
    var card_notify_state: Int = -1
    var chat_notify_state : Int = -1
    var password : String = ""
    var calendar_public_state : Int = -1
    var feed_notify_state: Int = -1
    var idx : Int = -1
    var phone_number: String = ""
    var profile_photo_path: String? = ""

}
