//
//  ProcoYearlyCalendarView.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import ProcoCalendar
import SwiftUI

struct ProcoYearlyCalendarView: View {

    @ObservedObject private var calendarManager: YearlyCalendarManager

    let visitsByDay: [Date: [SmallSchedule]]

    init(ascVisits: [SmallSchedule], initialYear: Date?) {
        let configuration = CalendarConfiguration(calendar: currentCalendar,
                                                  startDate: ascVisits.first!.arrivalDate,
                                                  endDate: ascVisits.last!.arrivalDate)
        calendarManager = YearlyCalendarManager(configuration: configuration,
                                                 initialYear: initialYear)
        visitsByDay = Dictionary(grouping: ascVisits, by: { currentCalendar.startOfDay(for: $0.arrivalDate) })

        calendarManager.delegate = self
    }

    var body: some View {
        ZStack {
            YearlyCalendarView(calendarManager: calendarManager)

        }
    }

}

extension ProcoYearlyCalendarView: YearlyCalendarDelegate {

    func calendar(didSelectMonth date: Date) {
        print("Selected month: \(date)")
    }

    func calendar(willDisplayYear date: Date) {
        print("Will show year: \(date)")
    }

}

