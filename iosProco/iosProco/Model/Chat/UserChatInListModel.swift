//
//  UserChatInListModel.swift
//  proco
//
//  Created by 이은호 on 2021/01/06.
//

import Foundation
import Combine

struct UserChatInListModel : Codable, Identifiable{
    var id = UUID()
    var idx: Int = 999
    var nickname: String = ""
    var profile_photo_path : String? = ""
}
