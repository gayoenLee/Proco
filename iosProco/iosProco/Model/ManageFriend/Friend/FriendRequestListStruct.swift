//
//  FriendRequestListStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/20.
// 친구관리 - 친구 요청 목록 가져올 때 사용

import Foundation
import Combine

struct FriendRequestListStruct : Codable, Hashable, Identifiable{
    var result: String? = ""
    var idx: Int? = -1
    var nickname: String? = ""
    var profile_photo_path: String? = ""
    var processed : String? = ""
    //identifiable프로토콜 따르기 위해 추가함.
    var id: Int{
        return self.idx ?? -1
    }
}
