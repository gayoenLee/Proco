//
//  NotiListModel.swift
//  proco
//
//  Created by 이은호 on 2021/06/01.
// 알림탭 리스트 모델

import Foundation

struct NotiListModel : Codable, Identifiable{
    var result: String? = ""
    var idx : Int? = -1
    var id: Int{
        idx ?? -1
    }
    var unique_idx : Int? = -1
    var kinds: String? = ""
    //노티의 주인공(모임명, 메세지 보낸 사람, 친구 신청한 사람 등)
    var content_indicator: String? = ""
    //노티 내용
    var content: String? = ""
    var created_at: String? = ""
    //프로필 사진 경로
    var image_path: String? = ""
}
