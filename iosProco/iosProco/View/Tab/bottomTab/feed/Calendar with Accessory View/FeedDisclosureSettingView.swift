//
//  FeedDisclosureSettingView.swift
//  proco
//
//  Created by 이은호 on 2021/06/22.
// 캘린더에서 설정 버튼 클릭해서 알림 설정할 때 나오는 뷰

import SwiftUI

struct FeedDisclosureSettingView: View {
    
    @ObservedObject var main_vm : CalendarViewModel
    @State var selected = ""
    @State private var got_data : Bool = false
    
    var body: some View {
        VStack{
         
            RadioButtons(selected: self.$selected)
            Spacer()
            
        }
        .onAppear{

            //설정 페이지 들어올 때 user info model에 저장했던 calendar public state가져옴.
            if self.main_vm.user_info_model.calendar_public_state == 1{
                self.selected = "전체 공개"
                print("전체 공개임")
            }else if self.main_vm.user_info_model.calendar_public_state == 2{
                
                self.selected = "카드만 공개"
                print("카드만 공개임")

            }else{
                self.selected = "비공개"
                print("비공개임")

            }
        }
        .onDisappear{
            
            if self.selected == "전체 공개" && self.main_vm.user_info_model.calendar_public_state != 1{
                print("이전 값과 달라서 편집 통신")
                self.main_vm.user_info_model.calendar_public_state = 1
                self.main_vm.edit_calendar_disclosure_setting(calendar_public_state: self.main_vm.user_info_model.calendar_public_state)
                
            }else if self.selected == "카드만 공개" &&  self.main_vm.user_info_model.calendar_public_state != 2{
                print("이전 값과 달라서 편집 통신")

                self.main_vm.user_info_model.calendar_public_state = 2
                self.main_vm.edit_calendar_disclosure_setting(calendar_public_state: self.main_vm.user_info_model.calendar_public_state)
                
            }else if self.selected == "비공개" &&   self.main_vm.user_info_model.calendar_public_state != 0{
                print("이전 값과 달라서 편집 통신")

                self.main_vm.user_info_model.calendar_public_state = 0
                self.main_vm.edit_calendar_disclosure_setting(calendar_public_state: self.main_vm.user_info_model.calendar_public_state)
                
            }
            print("유저가 선택한 공개범위: \(self.main_vm.user_info_model.calendar_public_state)")
            
            
        }
    }
}

