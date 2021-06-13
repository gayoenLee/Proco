//
//  BoredDaysModel.swift
//  proco
//
//  Created by 이은호 on 2021/02/28.
// 캘린더 - 심심기간 가져올 때 사용하는 데이터 모델

import Foundation
import Combine
import SwiftUI


struct BoredDaysModel: Codable,Identifiable{
    var id :Int{
        return self.id ?? -1
    }
    var result : String? = ""
    var bored_dates:[BoredDatesModel] = []
    var bored_days_count: [BoredDaysCountModel]? = []
    var bored_check_dates: [BoredCheckDatesModel]? = []
}

struct BoredDatesModel: Codable,Identifiable{
    var bored_date: String? = ""
    var bored_date_days: String? = ""
    var id: Int{
        return self.id ?? -1
    }
}

struct BoredDaysCountModel: Codable,Identifiable{
    var interest_checked_date: String? = ""
    var interest_count: Int? = -1
    var id: Int{
        return self.id ?? -1
    }
}

struct BoredCheckDatesModel: Codable,Identifiable{
    var idx: Int? = -1
    var checked_dates: String? = ""
    var id: Int{
        return self.id ?? -1
    }
}

//03.04추가
extension BoredDaysModel{
    
    static func make_interest_mock(bored_dates_model: [BoredDatesModel], bored_days_count: [BoredDaysCountModel], bored_check_dates: [BoredCheckDatesModel]) -> BoredDaysModel{
        
        print("make buttons메소드 들어옴.")
        return BoredDaysModel(bored_dates: bored_dates_model, bored_days_count: bored_days_count, bored_check_dates: bored_check_dates)
    }
}


fileprivate let colorAssortment: [Color] = [.turquoise, .forestGreen, .darkPink, .darkRed, .lightBlue, .salmon, .military]

private extension Color {

    static var randomColor: Color {
        let randomNumber = arc4random_uniform(UInt32(colorAssortment.count))
        return colorAssortment[Int(randomNumber)]
    }

}

private extension Color {

    static let turquoise = Color(red: 24, green: 147, blue: 120)
    static let forestGreen = Color(red: 22, green: 128, blue: 83)
    static let darkPink = Color(red: 179, green: 102, blue: 159)
    static let darkRed = Color(red: 185, green: 22, blue: 77)
    static let lightBlue = Color(red: 72, green: 147, blue: 175)
    static let salmon = Color(red: 219, green: 135, blue: 41)
    static let military = Color(red: 117, green: 142, blue: 41)

}

fileprivate extension Color {

    init(red: Int, green: Int, blue: Int) {
        self.init(red: Double(red)/255, green: Double(green)/255, blue: Double(blue)/255)
    }

}

fileprivate extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }

}
