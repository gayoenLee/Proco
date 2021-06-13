//
//  CardLikeUserStruct.swift
//  proco
//
//  Created by 이은호 on 2021/04/11.
//

import Foundation

struct CardLikeUserStruct: Identifiable, Codable{
    
    var id = UUID()
    var idx : Int = -1
    var nickname : String = ""
    var profile_photo_path : String? = ""
    
}
 
