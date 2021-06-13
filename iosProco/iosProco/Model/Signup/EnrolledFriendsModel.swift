//
//  EnrolledFriendsModel.swift
//  proco
//
//  Created by 이은호 on 2021/04/08.
//

import Foundation

struct EnrolledFriendsModel : Identifiable {
    var id = UUID()
    var idx : Int
    var nickname : String
    var profile_photo_path: String
    var phone_number: String
    var sent_rquest: Bool? = false
}
