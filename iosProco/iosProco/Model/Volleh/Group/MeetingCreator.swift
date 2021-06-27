//
//  MeetingCreator.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
// 모여볼래 참가 신청 목록에 creator에 사용하는 모델

import Foundation

struct MeetingCreator: Codable, Identifiable{
    var id : Int{
        idx!
    }
    var nickname: String? = ""
    var idx: Int? = -1
    var profile_photo_path: String? = ""
    
}
