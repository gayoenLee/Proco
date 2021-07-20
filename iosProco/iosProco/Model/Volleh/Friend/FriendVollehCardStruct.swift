//
//  FriendVollehCardStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine

struct FriendVollehCardStruct :Codable, Identifiable{
    var result : String? = ""
    var card_idx: Int? = -1
    var kinds: String? = ""
    var expiration_at: String? = ""
    var lock_state: Int = 0
    var like_count: Int = 0
    var like_state: Int = 0
    var tags: [FriendVollehTags]? = []
    var creator: Creator? = Creator()
    var share_list : [ShareList]? = []
    //수정.삭제 스와이프 구현하기 위해 추가로 넣음.
    var offset : CGFloat? = 0.0
    //관심친구 여부
    var is_favor_friend : Int? = 0
    //identifiable프로토콜 따르기 위해 추가함.
    var id : Int{
        card_idx!
    }
}

struct FriendVollehTags: Codable, Identifiable{
   
    var idx: Int? = -1
    var tag_name: String? = ""
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.idx ?? -1
    }
}

struct Creator: Codable, Hashable, Identifiable{
    var idx: Int! = -1
    var nickname: String = ""
    var profile_photo_path: String? = ""
    var id:Int{
        idx
    }
}
