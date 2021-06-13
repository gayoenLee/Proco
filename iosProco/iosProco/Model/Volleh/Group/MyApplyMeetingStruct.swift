//
//  MyApplyMeetingStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
// 모임 신청 목록에 사용하는 데이터 모델

import Foundation
import Combine

struct MyApplyMeetingStruct: Codable, Identifiable{

    var result : String? = ""
    var creator : MeetingCreator? = MeetingCreator()
    var card_idx: Int? = -1
    var kinds: String? = ""
    var apply_user: Int? = 0
    var introduce: String? = ""
    var apply_kinds: String? = ""
    var tags: [Tags]? = []
    var map_lat: String? = ""
    var map_lng: String? = ""
    var expiration_at: String? = ""
    var address: String? = ""
    var title: String? = ""
    var cur_user: Int? = 0
    var card_photo_path : String? = ""
    var lock_state : Int? = 0
    var like_count : Int = 0
    var like_state : Int = 0
    var id: Int{
        return self.card_idx ?? -1
    }
}
