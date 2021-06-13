//
//  DateScheduleModel.swift
//  proco
//
//  Created by 이은호 on 2021/03/11.
//

import Foundation
import Combine
import SwiftUI


struct DateScheduleModel: Identifiable{
    var id = UUID()
    var schedule_date : Date
    var title : String
    var tag_color: Color
    var type: String
    var is_private : Bool
}

extension DateScheduleModel {
  
    static func mock(withDate schedule_date: Date, title: String, tag_color: Color, type: String, is_private: Bool) -> DateScheduleModel {
        
        //03.03 관심있어요, 좋아요 관련 변수 추가
        DateScheduleModel(schedule_date: schedule_date, title: title, tag_color: tag_color, type: type, is_private: is_private)
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
