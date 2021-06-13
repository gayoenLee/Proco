//
//  CalendarFriendCardDetailModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/16.
//

import Foundation

struct CalendarFriendCardDetailModel{
    var id = UUID()
    var card_idx: Int = -1
    var expiration_at: String? = ""
    var tags: [ScheduleTags]? = []
    var creator: Creator? = Creator()
}
