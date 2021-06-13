//
//  ManageFriendStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/13.
// 친구 관리 - 그룹 멤버들(친구)의 데이터 모델

import Foundation

struct ManageFriendStruct : Identifiable, Hashable, Codable {
    var id = UUID()
    var show_selected_friend: [String]
}

