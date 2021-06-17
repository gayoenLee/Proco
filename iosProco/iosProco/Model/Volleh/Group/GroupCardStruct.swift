//
//  GroupCardStruct.swift
//  proco
//
//  Created by 이은호 on 2021/06/03.
//

import Foundation
import SwiftUI
import Combine

struct GroupCardStruct: Codable, Identifiable{
    var result : String? = ""
    var card_idx: Int? = -1
    var title: String? = ""
    var kinds: String? = ""
    var expiration_at: String? = ""
    var address: String? = ""
    var map_lat: String? = ""
    var map_lng: String? = ""
    var cur_user: Int? = -1
    var apply_user: Int? = -1
    var introduce: String? = ""
    var card_photo_path : String? = ""
    var lock_state : Int? = 0
    var like_state : Int? = 0
    var like_count: Int? = 0
    var creator_attend_count : Int? = 0
    var tags: [Tags]? = []
    var creator: Creator? = Creator()
    //수정.삭제 스와이프 구현하기 위해 추가로 넣음.
    var offset : CGFloat? = 0
    var chatroom_idx: String? = ""
    var server_idx: Int? = -1
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        card_idx!
    }
}
