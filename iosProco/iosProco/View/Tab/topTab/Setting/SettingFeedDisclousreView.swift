//
//  SettingFeedDisclousreView.swift
//  proco
//
//  Created by 이은호 on 2021/03/24.
//

import SwiftUI

struct SettingFeedDisclousreView: View {
    
    @ObservedObject var main_vm : SettingViewModel
    @State var selected = ""
    
    var body: some View {
        VStack{
            RadioButtons(selected: self.$selected)
            Spacer()
        }
        .onAppear{
            
            //설정 페이지 들어올 때 user info model에 저장했던 calendar public state가져옴.
            if self.main_vm.user_info_model.calendar_public_state == 0{
                self.selected = "전체 공개"
                
            }else if self.main_vm.user_info_model.calendar_public_state == 1{
                
                self.selected = "카드만 공개"
                
            }else{
                self.selected = "비공개"
            }
            
        }
        .onDisappear{
            
            if self.selected == "전체 공개"{
                self.main_vm.user_info_model.calendar_public_state = 0
            }else if self.selected == "카드만 공개"{
                self.main_vm.user_info_model.calendar_public_state = 1
            }else{
                self.main_vm.user_info_model.calendar_public_state = 2
            }
            print("유저가 선택한 공개범위: \(self.main_vm.user_info_model.calendar_public_state)")
            self.main_vm.edit_calendar_disclosure_setting(calendar_public_state: self.main_vm.user_info_model.calendar_public_state)
            
        }
    }
}

struct RadioButtons: View{
    
    @Binding var selected: String
    var menus = ["전체 공개", "카드만 공개", "비공개"]
    
    var sub_menus = ["(모든 일정 공개)", "(개인일정 공개 안함)", "(나만 보기)"]
    
    var body: some View{
        
        VStack(alignment: .leading, spacing: 20){
            
            ForEach(menus, id: \.self){menu in
                
                Button(action: {
                    
                    self.selected = menu
                    print("선택한 범위: \(self.selected)")
                    
                }){
                    HStack{
                        Text(menu)
                            .font(.custom(Font.n_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                        
                        if menu == "전체 공개"{
                            Text("(모든 일정 공개)")
                                .font(.custom(Font.n_bold, size: 13))
                                .foregroundColor(Color.gray)
                        }
                        else if menu == "카드만 공개"{
                            Text("(개인일정 공개 안함)")
                                .font(.custom(Font.n_bold, size: 13))
                                .foregroundColor(Color.gray)
                        }else{
                            Text("(나만 보기)")
                                .font(.custom(Font.n_bold, size: 13))
                                .foregroundColor(Color.gray)
                        }
                        Spacer()
                        
                        ZStack{
                            Circle().stroke(Color.proco_black)
                                .frame(width: 20, height: 20)
                            if self.selected == menu{
                                Circle().fill(Color.proco_black).frame(width: 20, height: 20)
                            }
                        }
                    }
                }
                
            }
        }.padding(.vertical)
        .padding(.horizontal, UIScreen.main.bounds.width/20)
    }
}

