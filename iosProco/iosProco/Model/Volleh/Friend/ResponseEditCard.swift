//
//  ResponseEditCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/25.
//

import Foundation

struct ResponseEditCard : Codable{
    var result: String
    var card_idx : String
    var tags : [Tags]
}

