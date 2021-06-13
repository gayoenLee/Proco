//
//  UserInDrawerStruct.swift
//  proco
//
//  Created by 이은호 on 2021/01/17.
//

import Foundation

struct UserInDrawerStruct: Codable, Identifiable{
    var id = UUID()
    var nickname : String? = ""
    var profile_photo: String? = ""
    var state: String? = ""
    var user_idx: Int? = -1
    var deleted_at: String? = ""
}
