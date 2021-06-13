//
//  GetFriendListStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/14.
// AddGroupViewmodel, GroupDetailViewmodel에서 사용.
// 사용하는 경우 : 그룹에 속한 친구들 데이터 가져올 때.

import Foundation
import Combine

struct GetFriendListStruct : Codable, Hashable, Identifiable{
    var result: String? = nil
    //idx인데 identifiable 프로토콜 따르기 위해 id로 바꿈
    var idx: Int? = nil
    var nickname: String? = nil
    var profile_photo: String? = nil
    var state: Int? = nil
    var kinds : String = ""
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.idx ?? -1
    }
}
