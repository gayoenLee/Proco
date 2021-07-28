//
//  AppliedMeetingListView.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
//

import SwiftUI

struct AppliedMeetingListView: View {
    @StateObject var main_vm : GroupVollehMainViewmodel
    @StateObject var calendar_vm : CalendarViewModel
    
    //다른 사람 모임 카드 상세 페이지 들어갈 때 - 참가 모임
    @State private var go_to_detail: Bool = false
    //신청 후 대기중인 모임 리스트에서 상세 페이지 이동시
    @State private var go_to_wating_detail: Bool = false
    
    var body: some View {
        NavigationView{
            VStack{
            ScrollView{
                VStack{
                    
                    if main_vm.apply_meeting_struct.isEmpty{
                        Text("신청한 모임이 아직 없습니다")
                            .font(.custom(Font.t_extra_bold, size: 16))
                            .foregroundColor(Color.proco_black)
                    }else{
                        HStack{
                            Text("참가모임")
                                .font(.custom(Font.t_extra_bold, size: 16))
                                .foregroundColor(Color.proco_black)
                            Spacer()
                        }
                        .padding([.top, .leading, .bottom])
                        
                        NavigationLink("", destination: GroupVollehCardDetail(main_vm: self.main_vm, socket: SockMgr.socket_manager, calendar_vm: self.calendar_vm), isActive: self.$go_to_detail)
                        
                        ForEach(main_vm.apply_meeting_struct.filter({
                            $0.apply_kinds == "수락됨"
                        })){ card in
                            HStack{
                                RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundColor(.proco_white)
                                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                    .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                                    .overlay(
                                        Button(action: {
                                            // 상세 페이지로 가려는 카드의 idx값을 뷰모델에 저장.
                                            self.main_vm.selected_card_idx = self.main_vm.apply_meeting_struct[self.main_vm.apply_index(item: card)].card_idx!
                                            
                                            self.go_to_detail.toggle()
                                        }){
                                            
                                            ApplyMeetingCard(main_vm: self.main_vm, apply_card: $main_vm.apply_meeting_struct[main_vm.apply_index(item: card)])
                                                .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                                .padding()
                                        })
                            }
                        }
                        
                        Divider()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/30, alignment: .center)
                            .foregroundColor(Color.light_gray)
                        
                        NavigationLink("", destination: GroupVollehCardDetail(main_vm: self.main_vm, socket: SockMgr.socket_manager, calendar_vm: self.calendar_vm), isActive: self.$go_to_wating_detail)
                        
                        HStack{
                            Text("신청모임")
                                .font(.custom(Font.t_extra_bold, size: 16))
                                .foregroundColor(Color.proco_black)
                            Spacer()
                        }
                        .padding([.top, .leading, .bottom])
                        
                        ForEach(main_vm.apply_meeting_struct.filter({
                            $0.apply_kinds == "대기중"
                        })){ card in
                            HStack{
                                RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundColor(.proco_white)
                                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                    .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                                    .overlay(
                                        Button(action: {
                                            // 상세 페이지로 가려는 카드의 idx값을 뷰모델에 저장.
                                            self.main_vm.selected_card_idx = self.main_vm.apply_meeting_struct[self.main_vm.apply_index(item: card)].card_idx!
                                            
                                            self.go_to_wating_detail.toggle()
                                        }){
                                            
                                            ApplyMeetingCard(main_vm: self.main_vm, apply_card: $main_vm.apply_meeting_struct[main_vm.apply_index(item: card)])
                                                .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                                .padding()
                                        }
                                    )}
                        }
                    }
                }
            }
            }
            .onAppear{
                //신청 목록 가져오는 통신
               // self.main_vm.get_my_apply_list()
            }
        }
//        .navigationBarColor(background_img: "meeting_wave_bg")
//        .navigationBarTitle("모임 신청 목록")
    }
}

