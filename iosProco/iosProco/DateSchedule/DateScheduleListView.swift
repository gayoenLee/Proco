//
//  DateScheduleListView.swift
//  proco
//
//  Created by 이은호 on 2021/03/11.
//

import SwiftUI

struct DateScheduleListView: View {
    @ObservedObject var main_vm : CalendarViewModel
    
    
    
    private let timer = Timer.publish(every: DateSchedulePreviewConstants.previewTime,
                                      on: .main, in: .common).autoconnect()
    @State var date_schedule_index = 0

    let date_schedule_model: [DateScheduleModel]
    let numberOfCellsInBlock: Int

    init(date_schedule_model: [DateScheduleModel], height: CGFloat, main_vm: CalendarViewModel) {
        
        self.date_schedule_model = date_schedule_model
        //한 칸에 두개까지 보여주는게 글자 크기가 너무 작아지지 않을 정도인 것 같아 두개로 설정.
        numberOfCellsInBlock = 2
        
        self.main_vm = main_vm
    }
    
    //schedule한개에 저장된 일정 갯수를 구하는 것.
    private var range: Range<Int> {
        let exclusiveEndIndex = date_schedule_index + numberOfCellsInBlock
        guard date_schedule_model.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= date_schedule_model.count else {
            return date_schedule_index..<date_schedule_model.count
        }
        return date_schedule_index..<exclusiveEndIndex
    }
    
    var body: some View {
        date_schedule_list_view
            .animation(.easeInOut)
            .onAppear(perform: setUpVisitsSlideShow)
            .onReceive(timer) { _ in
                self.shiftActivePreviewVisitIndex()
            }
    }
    
    
    private func setUpVisitsSlideShow() {
        if date_schedule_model.count <= numberOfCellsInBlock {

            timer.upstream.connect().cancel()
        }
    }

    private func shiftActivePreviewVisitIndex() {
        let startingVisitIndexOfNextSlide = date_schedule_index + numberOfCellsInBlock
        let startingVisitIndexOfNextSlideIsValid = startingVisitIndexOfNextSlide < date_schedule_model.count
        date_schedule_index = startingVisitIndexOfNextSlideIsValid ? startingVisitIndexOfNextSlide : 0
    }
    
    //날짜 한 칸 뷰
    private var date_schedule_list_view: some View {
        
        VStack(spacing: 0) {
            ForEach(date_schedule_model[range]) { schedule in

                DateScheduleCell(date_schedule_model: schedule)
            
            }
        }
    }
}


