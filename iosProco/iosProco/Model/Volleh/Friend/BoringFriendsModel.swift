//
//  BoringFriendsModel.swift
//  proco
//
//  Created by 이은호 on 2021/04/27.
// 오늘 심심기간인 친구들

import Foundation


struct BoringFriendsModel : Codable, Identifiable{
    var id : Int {
        idx
    }
    var result : String? = ""
    var idx : Int
    var nickname : String
    var profile_photo_path : String? = ""
    var state: Int
    var kinds : String
}
