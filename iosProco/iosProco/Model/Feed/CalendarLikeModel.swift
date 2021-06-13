//
//  CalendarLikeModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/03.
// 달력 - 좋아요 정보 조회 api문서 137번째 줄

import Foundation

struct CalendarLikeModel: Identifiable{
    var id = UUID()
    var like_checked_date: [LikeUserCheckedModel] = []
    var calendar_like_count: [CalendarLikeCountModel] = []
}
//내가 클릭한 좋아요 날짜 정보
struct LikeUserCheckedModel: Identifiable{
    var id = UUID()
    var idx : Int = -1
    var like_checked_date: String = ""
}
//해당 날짜에 대한 좋아요 정보
struct CalendarLikeCountModel: Identifiable{
    var id = UUID()
    var like_checked_date: String = ""
    var like_count: Int = -1
}
