//
//  LikeUserListModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/12.
// 캘린더 좋아요한 사람들 목록 모델

import Foundation

struct LikeUserListModel: Codable,Identifiable{
    var id = UUID()
    var idx : Int = -1
    var nickname: String = ""
    var profile_photo_path: String? = ""
}
