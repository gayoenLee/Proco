//
//  ProcoMonthlyCalendarView.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
// 우리 기획에서 사용하지 않는 뷰 - 삭제할 것.

import SwiftUI
import ProcoCalendar

struct ProcoMonthlyCalendarView: View {
    
    //라이브러리와 연결된 뷰모델
    @ObservedObject private var calendarManager: MonthlyCalendarManager

    //날짜 한 칸 일정 리스트 데이터
    let smallSchedulesByDay: [Date: [SmallSchedule]]
    //!!!
    let schedule_by_day : [Date : [DateScheduleModel]]
    
    //날짜 한 칸 관심있어요 데이터
    let small_interest_by_day : [Date: [SmallInterestModel]]
    
    init(ascSmallSchedules: [SmallSchedule], ascSchedules: [Schedule], initialMonth: Date?, ascDateSchedules: [DateScheduleModel], ascSmallInterest: [SmallInterestModel]) {
    
        let configuration = CalendarConfiguration(calendar: currentCalendar,
                                                  startDate: ascDateSchedules.first!.schedule_date,
                                                  endDate: ascDateSchedules.last!.schedule_date)
        calendarManager = MonthlyCalendarManager(configuration: configuration,
                                                 initialMonth: initialMonth, go_mypage: false, previousMonth: Date())
        smallSchedulesByDay = Dictionary(grouping: ascSmallSchedules, by: { currentCalendar.startOfDay(for: $0.arrivalDate) })
        
        //!!!
        schedule_by_day = Dictionary(grouping: ascDateSchedules, by:{ currentCalendar.startOfDay(for: $0.schedule_date)})
        
        //날짜 한 칸 관심있어요
        small_interest_by_day = Dictionary(grouping: ascSmallInterest, by: {currentCalendar.startOfDay(for: $0.date!)})
        
        calendarManager.datasource = self
        calendarManager.delegate = self
    }
    
    var body: some View {
        VStack{
            ZStack(alignment: .top) {
            MonthlyCalendarView(calendarManager: calendarManager)
        }
            Spacer()
        }
    }
    
}

extension ProcoMonthlyCalendarView: MonthlyCalendarDataSource {
    
    func calendar(backgroundColorOpacityForDate date: Date) -> Double {
        let startOfDay = currentCalendar.startOfDay(for: date)
        return Double((schedule_by_day[startOfDay]?.count ?? 0) + 3) / 15.0
    }
    
    func calendar(canSelectDate date: Date) -> Bool {
        let day = currentCalendar.dateComponents([.day], from: date).day!
        return day != 4
    }
   
    
    func calendar(viewForSelectedDate date: Date, dimensions size: CGSize) -> AnyView {
        //start of day : 날짜들
        let startOfDay = currentCalendar.startOfDay(for: date)
        print("프로코먼슬리 캘린더뷰에서 일정 확인: \(smallSchedulesByDay[startOfDay])")
        return SmallScheduleListView(main_vm: CalendarViewModel(), smallSchedules: smallSchedulesByDay[startOfDay] ?? [], height: size.height).erased
    }
    
    func calendar(viewForSmallInterest date: Date, dimensions size: CGSize) -> AnyView {
        let startOfDay = currentCalendar.startOfDay(for: date)
        
        return SmallInterestView(main_vm: CalendarViewModel(), small_intrest_model: small_interest_by_day[startOfDay] ?? [], height: size.height).erased
    }
}

extension ProcoMonthlyCalendarView: MonthlyCalendarDelegate {
    
    func calendar(didSelectDay date: Date) {
        print("Selected date: \(date)")
    }
    
    func calendar(willDisplayMonth date: Date, previousMonth: Date) {
        print("Will show month: \(date), previous month: \(previousMonth)")
    }
    //심심기간 설정 완료시 실행할 메소드
    func calendar(didEditBoringPeriod selections: [Date], end: Bool){
        print("기간 설정 완료: selections: \(selections), end여부: \(end)")
    }
    
}
