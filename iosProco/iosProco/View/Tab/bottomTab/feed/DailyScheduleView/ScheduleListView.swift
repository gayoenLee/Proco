//
//  ScheduleListView.swift
//  proco
//
//  Created by 이은호 on 2021/02/25.
//

import SwiftUI

struct ScheduleListView: View {
    
    private let timer = Timer.publish(every: SchedulePreviewConstants.previewTime,
    on: .main, in: .common).autoconnect()
    //일정 리스트의 index초기화
     @State var schedule_index = 0
     
    let schedules : [Schedule]
    
     //한 번에 보여줄 리스트 갯수(타이머 돌아가기 때문에 모든 리스트보여줄 필요 없음)
     let numberOfCellsInBlock: Int = 2
    
    @ObservedObject var main_vm : CalendarViewModel
    
    var height: CGFloat
    //일정 한 개 클릭시 상세 페이지로 이동하는 구분값.
    @State private var show_detail: Bool = false

    //일정 보여줄 범위를 설정하는 것.
    private var range: Range<Int> {
        //일정의 마지막 인덱스
        let exclusiveEndIndex = schedule_index + numberOfCellsInBlock
        //일정들의 갯수가 한 셀에 보여지는 갯수
        guard schedules.count > numberOfCellsInBlock &&
            exclusiveEndIndex <= schedules.count else {
            return schedule_index..<schedules.count
        }
        return schedule_index..<exclusiveEndIndex
    }
    
    var body: some View {
        VStack(alignment: .leading){
        schedule_like_preview
            .padding([.leading])
        schedule_preview_list
            .animation(.easeInOut)
            .onAppear(perform: setUpScheduleSlideShow)
            .onReceive(timer) { _ in
                self.shiftActivePreviewScheduleIndex()
            }
            .onDisappear{
                print("상세 페이지 뷰의 일정 리스트 사라짐.")
                if !main_vm.from_calendar{
                    print("상세페이지 이동시 on disappear")
                main_vm.schedule_state_changed = true
                }
            }
        }
        
    }
    
    private func setUpScheduleSlideShow() {
        if schedules.count <= numberOfCellsInBlock {
         
            timer.upstream.connect().cancel()
        }
        if !main_vm.from_calendar{
            print("상세페이지 이동시 appear")

        main_vm.schedule_state_changed = false
        }
        
        print("일정 상세 페이지에서 받은 데이터:\(schedules)")
    }

    private func shiftActivePreviewScheduleIndex() {
        
        let startingScheduleIndexOfNextSlide = schedule_index + numberOfCellsInBlock
        let startingScheduleIndexOfNextSlideIsValid = startingScheduleIndexOfNextSlide < schedules.count
        schedule_index = startingScheduleIndexOfNextSlideIsValid ? startingScheduleIndexOfNextSlide : 0
    }
    
    //좋아요는 일정 리스트 갯수와 상관없이 한 번만 보여주면 되므로 첫번째 일정의 좋아요 값을 가져온다.
    private var schedule_like_preview: some View{
        VStack(spacing: 0){
            //0보다 클 때 조건을 걸어줘야 일정이 없을 경우 index out of range오류 나지 않음.
            if schedules.count > 0{
                ScheduleLikeView(schedule: schedules[0], main_vm: self.main_vm)
            }
        }
    }

    private var schedule_preview_list: some View {
        
        VStack(spacing: 0) {
            //여기에서 schedules는 일자별로 일정 리스트를 말함.
            ForEach(schedules[range]){ schedule in
                ScheduleCell(main_vm: self.main_vm, schedule_info: schedule.schedule)
            }
        }
    }
}
