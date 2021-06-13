//
//  GroupDetailStruct.swift
//  proco
//
//  Created by 이은호 on 2020/12/16.
// 그룹 상세 페이지 데이터 클래스로 그룹에 속한 친구 리스트가 온다.

import Foundation
import Combine

struct GroupDetailStruct : Codable, Identifiable{
    var id :Int{
        idx!
    }
    var result: String? = ""
    var idx: Int? = -1
    var nickname : String? = ""
    var profile_photo_path : String? = ""
    
}
