//
//  MeetingCardLocationModel.swift
//  proco
//
//  Created by 이은호 on 2021/05/02.
//

import Foundation

struct MeetingCardLocationModel : Codable{
    var id = UUID()
    var location_name : String = ""
    var map_lat : Double = 0.0
    var map_lng : Double = 0.0
}
 
