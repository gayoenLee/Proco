//
//  CalendarOwnerModel.swift
//  proco
//
//  Created by 이은호 on 2021/05/17.
//

import Foundation

struct CalendarOwnerModel : Codable{
    var user_idx: Int = -1
    var profile_photo_path : String = ""
    var user_nickname : String = ""
    //캘린더를 보는 사람(주인과 다를 수 있음.)
    var watch_user_idx : Int = -1
}
