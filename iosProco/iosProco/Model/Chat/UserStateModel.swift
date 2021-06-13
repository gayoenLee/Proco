//
//  UserStateModel.swift
//  proco
//
//  Created by 이은호 on 2021/01/11.
// 상태 업데이트시에 소켓에 전달할 알릴 친구들 배열을 위함.

import Foundation


struct UserStateModel: Codable{
    var user_idx: Int?
    var state: String?
    var state_data: String?
    var announce_user: [Int]?
}
 
