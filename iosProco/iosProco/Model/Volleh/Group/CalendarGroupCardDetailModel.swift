//
//  CalendarGroupCardDetailModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/16.
//

import Foundation

struct CalendarGroupCardDetailModel{
    var card_idx: Int = -1
    var title: String = ""
    var expiration_at: String = ""
    var address: String = ""
    var map_lat: Int = 0
    var map_lng: Int = 0
    var cur_user: String = ""
    var apply_user: String = ""
    var introduce: String = ""
    var tags: [ScheduleTags] = []
    var creator: Creator = Creator()
}
