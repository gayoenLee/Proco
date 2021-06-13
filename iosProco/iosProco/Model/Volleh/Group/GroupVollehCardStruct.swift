//
//  GroupVollehCardStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
//

import Foundation
import SwiftUI
import Combine

struct GroupVollehCardStruct: Codable, Identifiable{
    var result : String? = ""
    var card_idx: Int? = -1
    var title: String? = ""
    var kinds: String? = ""
    var expiration_at: String? = ""
    var address: String? = ""
    var map_lat: String? = ""
    var map_lng: String? = ""
    var cur_user: String? = ""
    var apply_user: String? = ""
    var introduce: String? = ""
    var tags: [FriendVollehTags]? = []
    var creator: Creator? = Creator()
    //수정.삭제 스와이프 구현하기 위해 추가로 넣음.
    var offset : CGFloat? = 0
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.card_idx ?? -1
    }
}
