//
//  SmallSchedule.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI
import Alamofire
import Combine

let currentCalendar = Calendar.current
let screen = UIScreen.main.bounds

//뷰에 보여줄 때 사용.
struct SmallSchedule : Identifiable {
    var id = UUID()
    var arrivalDate: Date = Date()
    //좋아요 클릭수
    var like_num: Int = 0
   
    //내가 좋아요 클릭했는지 여부
    var clicked_like_myself: Bool = false

    //좋아요 idx
    var like_idx : Int = -1
    var schedule : [SmallScheduleInfo] = []
}

struct SmallScheduleInfo: Identifiable {
    var id = UUID()
    var date : Date = Date()
    var locationName: String = ""
    var tagColor: Color = .black
    //친구인지 모임인지 구분하기 위함.
    var type: String = ""
}

extension SmallSchedule {
  
    static func mock(withDate date: Date, like_num: Int,  clicked_like_myself: Bool,like_idx: Int, schedule_info : [SmallScheduleInfo]) -> SmallSchedule {
        
        //03.03 관심있어요, 좋아요 관련 변수 추가
        SmallSchedule(
            arrivalDate: date,  like_num: like_num, clicked_like_myself: clicked_like_myself, like_idx: like_idx, schedule: schedule_info )
    }
}

fileprivate extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }

}
