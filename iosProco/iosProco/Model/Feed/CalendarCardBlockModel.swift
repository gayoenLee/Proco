//
//  CalendarCardBlockModel.swift
//  proco
//
//  Created by 이은호 on 2021/02/28.
//

import Foundation

struct CalendarCardBlockModel: Identifiable{
    var id = UUID()
    var result: String? = ""
    var friend : FriendCardBlockModel = FriendCardBlockModel()
    //모임같은 경우 본래 만들었던 모델 활용.
    var meeting: [GroupCardStruct] = []
}

struct FriendCardBlockModel: Identifiable{
    var id = UUID()
    var public_type: [FriendCardBlockPublicModel] = []
    var private_type: [FriendCardBlockPrivateModel] = []
}
//캘린더에 보여줄 카드 - block단어 붙여서 구별하도록함.
struct FriendCardBlockPublicModel: Identifiable, Codable{
    var id = UUID()
    var card_idx: Int? = -1
    var kinds: String? = ""
    var expiration_at: String? = ""
    var lock_state: Int = 0
    var like_count: Int = 0
    var like_state: Int = 0
    var creator: Creator? = Creator()
    var tags: [Tags] = []
}

struct FriendCardBlockPrivateModel: Identifiable{
    var id = UUID()
    var idx: Int? = -1
    var expiration_at: String? = ""
}

