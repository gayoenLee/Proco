//
//  SmallScheduleListView.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI

struct SmallScheduleListView: View {
    
    @ObservedObject var main_vm: CalendarViewModel
    
    private let timer = Timer.publish(every: SmallSchedulePreviewConstants.previewTime,
                                      on: .main, in: .common).autoconnect()
    @State private var smallScheduleIndex = 0
    
    var smallSchedules: [SmallSchedule]
    let numberOfCellsInBlock: Int = 1
    var height: CGFloat
    
    //schedule한개에 저장된 일정 갯수를 구하는 것.
    private var range: Range<Int> {
        let exclusiveEndIndex = smallScheduleIndex + numberOfCellsInBlock
        guard smallSchedules.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= smallSchedules.count else {
            return smallScheduleIndex..<smallSchedules.count
        }
        return smallScheduleIndex..<exclusiveEndIndex
    }

    var body: some View {
        //smallSchedulePreviewList
        VStack{
            VStack(spacing: 0) {
                ForEach(smallSchedules[range]) { schedule in
                   
                    SmallScheduleCell(smallSchedule: schedule, main_vm: self.main_vm)
                }
            }
        }
            .animation(.easeInOut)
            .onAppear{
                //print("날짜 한칸 스케줄 뷰 나타남.: \(smallSchedules)")
            }
            .onReceive(timer) { _ in
                self.shiftActivePreviewVisitIndex()
            }
    }


    private func shiftActivePreviewVisitIndex() {
        let startingVisitIndexOfNextSlide = smallScheduleIndex + numberOfCellsInBlock
        let startingVisitIndexOfNextSlideIsValid = startingVisitIndexOfNextSlide < smallSchedules.count
        smallScheduleIndex = startingVisitIndexOfNextSlideIsValid ? startingVisitIndexOfNextSlide : 0
    }
}
