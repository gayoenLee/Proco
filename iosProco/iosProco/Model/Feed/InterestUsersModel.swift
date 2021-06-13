//
//  InterestUsersModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
//

import Foundation


struct InterestUsersModel: Codable,Identifiable{
    var idx : Int
    var nickname: String
    var profile_photo_path: String? = ""
    var id: Int{
        idx
    }
    
}
