//
//  PersonalScheduleModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/15.
// 캘린더 - 내 일정

import SwiftUI
import Foundation


struct PersonalScheduleModel: Identifiable {
    var id = UUID()
    var schedule_idx : Int? = -1
    var title : String = ""
    var content: String? = ""
    var schedule_start_date : Date = Date()
    var schedule_start_time: Date = Date()
}

