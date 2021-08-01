//
//  AppliedMeetingListView.swift
//  proco
//
//  Created by 이은호 on 2020/12/29.
//

import SwiftUI

struct AppliedMeetingListView: View {
    @Environment(\.presentationMode) var presentationMode : Binding<PresentationMode>

    @ObservedObject var main_vm : GroupVollehMainViewmodel = GroupVollehMainViewmodel()
    
    //다른 사람 모임 카드 상세 페이지 들어갈 때 - 참가 모임
    @State private var go_to_detail: Bool = false
    
    var body: some View {

            VStack{
                
                HStack{
                    Button(action: {
                        print("돌아가기 클릭")
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image("left")
                            .resizable()
                            .frame(width: 8.51, height: 17)
                    }
                    .frame(width: 45, height: 45)

                    Spacer()
                    
                    Text("모임 신청 목록")
                        .font(.custom(Font.n_extra_bold, size: 22))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                }.padding(.trailing)
                
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
                        
                        if main_vm.apply_meeting_struct.filter({
                            
                            $0.apply_kinds == "수락됨"
                        
                        }).count <= 0 {
                            Text("참가하는 모임이 없습니다.")
                                .font(.custom(Font.n_regular, size: 15))
                                .foregroundColor(.gray)
                                .padding([.top, .bottom])
                        }
                        
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
                                           // self.main_vm.selected_card_idx = card.card_idx!
                                            
                                            self.go_to_detail = true
                                        }){
                                            
                                            ApplyMeetingCard(main_vm: self.main_vm, apply_card: card)
                                                .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                                .padding()
                                        })
                            }
                        }
                        
                        Divider()
                            .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width/30, alignment: .center)
                            .foregroundColor(Color.light_gray)
                        
                        HStack{
                            Text("신청모임")
                                .font(.custom(Font.t_extra_bold, size: 16))
                                .foregroundColor(Color.proco_black)
                            Spacer()
                        }
                        .padding([.top, .leading, .bottom])
                        
                        if main_vm.apply_meeting_struct.filter({
                            $0.apply_kinds == "대기중"
                        }).count <= 0 {
                            Text("신청 대기중인 모임이 없습니다.")
                                .font(.custom(Font.n_regular, size: 15))
                                .foregroundColor(.gray)
                                .padding([.top, .bottom])
                        }
                        
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
                                            
                                            print("신청한 모임 카드 상세 페이지 이동: \(card)")
                                            // 상세 페이지로 가려는 카드의 idx값을 뷰모델에 저장.
                                            self.main_vm.selected_card_idx = card.card_idx!
                                            
                                            self.go_to_detail = true
                                        }){
                                            
                                            ApplyMeetingCard(main_vm: self.main_vm, apply_card: card)
                                                .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width/2.5)
                                                .padding()
                                        }
                                    )}
                        }
                    }
                }
            }
                NavigationLink("", destination: GroupVollehCardDetail(main_vm: self.main_vm, socket: SockMgr.socket_manager, calendar_vm: CalendarViewModel()), isActive: self.$go_to_detail)
            }
            .navigationBarHidden(true)
            .navigationBarTitle("", displayMode: .inline)
            .onAppear{
                //신청 목록 가져오는 통신
                self.main_vm.get_my_apply_list()
            }
        
    }
}

