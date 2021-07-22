//
//  FriendVollehCardDeatil.swift
//  proco
//
//  Created by 이은호 on 2020/12/24.
//

import Foundation
import SwiftUI
import Combine

struct FriendVollehCardDetailModel: Codable{
    var result: String? = ""
    var card_idx: Int? = -1
    var kinds: String? = ""
    var expiration_at: String? = ""
    var lock_state: Int? = 0
    var like_count: Int? = 0
    var like_state: Int? = 0
    var tags: [Tags]? = []
    var share_list: [ShareList]? = []
    var creator : Creator? = Creator()
    //관심친구 여부
    var is_favor_friend: Int? = 0
    //카드 참가 유저 수
    var cur_user : Int? = 1
}
