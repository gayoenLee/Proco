//
//  LikeAndInterestModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/03.
//

import Foundation

struct LikeAndInterestModel: Identifiable{
    var id = UUID()
    var date: Date
    var interest_num: Int
    var clicked_myself: Bool
}
