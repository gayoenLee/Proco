//
//  PlusScheduleButtonView.swift
//  proco
//
//  Created by 이은호 on 2021/03/15.
//

import SwiftUI

struct PlusScheduleButtonView: View {
    //스케줄 추가하는 뷰로 이동할 때 사용하는 구분값.
    @State private var add_schedule: Bool = false
    @StateObject var main_vm: CalendarViewModel
    
    var body: some View {
        
        VStack{
            //스케줄 추가하는 화면으로 이동시킴.
            NavigationLink("",destination: AddScheduleView(main_vm: self.main_vm, back_to_calendar: self.$add_schedule).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$add_schedule)
                //binding이용해서 스케줄 추가 완료시 false로 변경시킨 후 현재 화면으로 다시 돌아오게 함.
                .isDetailLink(false)
            
            Button(action: {
                
                print("일정 추가하기 버튼 클릭")
                self.add_schedule.toggle()
                
            }){
                Image("plus_yellow_btn")
                    .resizable()
                    .frame(width: 51.75, height: 51.75)
            }
        }
    }
}
