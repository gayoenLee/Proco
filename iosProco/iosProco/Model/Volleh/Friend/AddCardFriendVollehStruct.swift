//
//  AddCardFriendVollehStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/22.
//

import Foundation
import Combine


struct AddCardFriendVollehStruct :Codable{
    var type: String = ""
    var time: String = ""
    var tags: [TagList] = []
    var share_list : [String:String] = [:]
}




