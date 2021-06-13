//
//  ApplyUserStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/28.
//

import Foundation

struct ApplyUserStruct: Codable, Identifiable{
    var id = UUID()
    var result: String? = ""
    var idx: Int? = -1
    var nickname: String? = ""
    var level: Int? = -1
    var profile_photo_path: String? = ""
    var kinds: String? = ""
    
}
