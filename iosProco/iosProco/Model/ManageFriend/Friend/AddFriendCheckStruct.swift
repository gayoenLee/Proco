//
//  AddFriendCheckStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import Foundation
import Combine

struct AddFriendCheckStruct: Codable{
    var result: String? = nil
    var idx: Int? = nil
    var nickname: String? = nil
    var profile_photo_path: String? = nil
}
