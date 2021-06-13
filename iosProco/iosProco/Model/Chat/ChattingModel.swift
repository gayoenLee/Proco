//
//  ChattingModel.swift
//  proco
//
//  Created by 이은호 on 2021/01/03.
//

import Foundation

struct  ChattingModel: Codable {
    var idx: Int
    var chatroom_idx: Int
    var user_idx: Int
    var content: String
    var kinds: String
    var created_at: String
    var front_created_at: CLong
}
