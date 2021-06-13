//
//  Schedule.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//
import SwiftUI

//일정 1개 보여줄 때 필요한 요소들
struct Schedule: Identifiable {
    var id = UUID()
    var date: Date
    //좋아요 정보
    var like_num : Int? = 0
    var liked_myself: Bool = false
    //좋아요를 클릭했을 때, 취소했을 때 필요함.
    var like_idx: Int? = -1
    var schedule: [ScheduleInfo] = []
}

struct ScheduleInfo: Identifiable{
    var id  = UUID()
    //개인일정의 경우 schedule_idx가 저장됨.
    var card_idx : Int = -1
    //스케줄 종류: 친구,모임, 개인 일정
    var type: String = ""
    //일정 날짜
    var schedule_date: Date = Date()
    //일정 제목
    var schedule_name: String = ""
    //임의로 기본값으로 설정해놓음.
    var tag_color: Color = Color.orange
    //일정 시간(start time = end time)
    var start_time: Date = Date()
    var end_time: Date = Date()
    //태그 중 카테고리 태그
    var category: String = ""
    var tags: [ScheduleTags]? = []
    //모임 - 현재 인원
    var current_people: String = ""
    //모임-  모임 장소
    var location_name: String = ""
    var is_private: Bool = false
    //개인일정의 경우 메모를 추가로 저장해야함.
    var memo: String = ""
}

struct ScheduleTags : Identifiable{
    var idx : Int
    var tag_name : String
    //identifiable프로토콜 따르기 위해 추가
    var id : Int{
        idx
    }
}


extension Schedule{
    
    //일정 1개 뷰 데이터 셋팅해서 뷰 리턴하기
    static func box(withDate card_idx: Int, schedule_date: Date, tags: [ScheduleTags],schedule: [ScheduleInfo], type: String) -> Schedule{

        if type == "friend"{
            return Schedule(date: schedule_date, schedule: schedule)

            
        }else if type == "group"{
            return Schedule(date: schedule_date, schedule: schedule)

        }else{
            return Schedule(date: schedule_date, schedule: schedule)
        }
    }
    //임의로 정보를 날짜별로 넣어주기 위해 실행하는 메소드.
    //TODO [box]를 만들기 위해
    static func boxes(start: Date, end: Date) -> [Schedule]{
        print("boxes 만들기")

        return currentCalendar.generate_schedules(start: start, end: end)
    }
}

//등록할 수 있는 일정 갯수의 범위를 말함.
fileprivate let schedule_range = 1...5

private extension Calendar{
    //TODO 지금은 날짜별 랜덤으로 데이터 임의로 넣어주는 로직임.
    //하드코딩으로 넣어주는 로직이었던 것 같아서 현재 필요 없는 것 같아서 삭제 해도 될 것같음. 확인 필요.
    func generate_schedules(start: Date, end: Date) -> [Schedule]{
        var schedules = [Schedule]()
        
        enumerateDates(startingAfter: start, matching: .everyDay, matchingPolicy: .nextTime){date, _, stop in
            
            if let date = date{
                if date < end{

                    for _ in 0..<Int.random(in: schedule_range){
                        
//                        schedules.append(.box(withDate: date,card_idx: 1, schedule_name: "skdk의 모임", start_time: date, end_time: date, type: .random_type, category: "아무거나", tags: [], current_people: 1, location_name: "서울시 서초구"))
                        
                        //print("스케줄 넣음: \(schedules)")
                    }
                }else {
                    stop = true
                }
            }
        }
        return schedules
    }
}

//아래 2개 : 임의로 카드 타입 지정 위해 만듬. 후에 삭제 할 것. 로직 변경 필요함.
fileprivate let type_list: [String] = ["friend", "group", "mine"]
    
private extension String{
    static var random_type: String{
        let random_name = arc4random_uniform(UInt32(type_list.count))
        return type_list[Int(random_name)]
    }
}
fileprivate extension DateComponents {

    static var everyDay: DateComponents {
        DateComponents(hour: 0, minute: 0, second: 0)
    }
}
