//
//  PlusScheduleButtonView.swift
//  proco
//
//  Created by 이은호 on 2021/03/15.
//

import SwiftUI

struct PlusScheduleButtonView: View {
    //스케줄 추가하는 뷰로 이동할 때 사용하는 구분값.
    @Binding var add_schedule: Bool
    @StateObject var main_vm: CalendarViewModel
    
    var body: some View {
        
        VStack{
            
            Button(action: {
                
                print("일정 추가하기 버튼 클릭")
                self.add_schedule = true
                
            }){
                Image("plus_yellow_btn")
                    .resizable()
                    .frame(width: 51.75, height: 51.75)
            }
        }
    }
}
