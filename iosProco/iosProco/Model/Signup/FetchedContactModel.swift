//
//  FetchedContactModel.swift
//  proco
//
//  Created by 이은호 on 2021/04/08.
//

import Foundation

struct FetchedContactModel:Identifiable {
    var id = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var telephone: String = ""
    var profile_photo_path: String? = ""
    var sent_invite_msg : Bool? = false
}
