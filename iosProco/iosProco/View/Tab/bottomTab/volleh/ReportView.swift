//
//  ReportView.swift
//  proco
//
//  Created by 이은호 on 2021/03/28.
//

import SwiftUI
import SocketIO

struct ReportView: View {
    @Environment(\.presentationMode) var presentation

    @Binding var show_report : Bool
    //채팅방에서 신고하는지, 카드를 신고하는지 onappear에서 타입을 받아서 예외처리.
    @State var type : String
    //채팅방 회원 신고의 경우 선택한 유저 idx가  필요함.
    @State var selected_user_idx: Int
    //신고하려는 타입.
    @State var selected = ""
    //기타 내용.
    @State var report_content = ""
    @ObservedObject var main_vm : FriendVollehMainViewmodel
    @ObservedObject var socket_manager : SockMgr
    @ObservedObject var group_main_vm: GroupVollehMainViewmodel
    
    //채팅방에서 온 경우, 카드에서 온 경우 구분해서 화면 이동시킬 때 사용.
    @State private var report_ok_card = false
    @State private var report_ok_chatroom = false
    
    var body: some View {
        
    VStack{
        
        //상단 제목 라인
//        HStack{
//
//            Button(action: {
//
//                self.presentation.wrappedValue.dismiss()
//
//            }, label: {
//
//                Image("left")
//                    .resizable()
//                    .frame(width: 8.51, height: 17)
//            })
//            .padding(.leading, UIScreen.main.bounds.width/20)
//
//            Spacer()
//
//            Text("신고하기")
//                .font(.custom(Font.t_extra_bold, size: 20))
//                .foregroundColor(.proco_black)
//                .padding(.trailing, UIScreen.main.bounds.width/20)
//
//            Spacer()
//
//        }
//        .padding()
        
        ZStack{
            ReportRadioButtons(selected: self.$selected, report_content: self.$report_content)
        }

        Spacer()
        Button(action: {
            print("신고 확인 클릭")
            if self.type == "카드"{
                print("친구 카드 신고일 때")
                
            self.main_vm.send_reports(kinds: "카드", unique_idx: String(main_vm.selected_card_idx), report_kinds: self.selected, content: self.report_content)
                
                //신고 결과에 따른 알림
                main_vm.request_result_alert_func(main_vm.request_result_alert)
                
            }else if self.type == "모임카드"{
              print("모임 카드 신고일 때")
                self.group_main_vm.send_reports(kinds: "카드", unique_idx: String(self.group_main_vm.selected_card_idx), report_kinds: self.selected, content: self.report_content)
                
                //신고 결과에 따른 알림
                self.group_main_vm.request_result_alert_func(self.group_main_vm.request_result_alert)
                
            }else{
                
                print("채팅방 회원 신고일 때")
                let unique_idx = "\(socket_manager.enter_chatroom_idx),\(selected_user_idx)"
                self.socket_manager.send_reports(kinds: "채팅방회원", unique_idx: unique_idx, report_kinds: self.selected, content: self.report_content)
            }
        }){
            Text("확인")
                .font(.custom(Font.t_extra_bold, size: 15))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.proco_white)
                .background(Color.proco_black)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
        }
        .alert(isPresented: $main_vm.show_result_alert){
            switch main_vm.request_result_alert{
            case .success:
                return Alert(title: Text("신고하기"), message: Text("신고가 접수되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                    self.show_report.toggle()

                }))

            case .fail:
                return Alert(title: Text("신고하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    
                }))
            }
        }
        .padding(.bottom)
    }.onAppear{
        print("신고하기 뷰 나타남: \(self.type)")
        }
    }
}

struct ReportRadioButtons: View{
    
    @Binding var selected: String
    @Binding var report_content: String
    
    var body: some View{
        VStack(alignment: .leading, spacing: 20){
            
            ForEach(report_menus, id: \.self){reason in
                
                Button(action: {
                    print("신고 내용 클릭: \(reason)")
                    self.selected = reason
                    
                }){
                    HStack{
                        Text(reason)
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(Color.proco_black)
                        
                        Spacer()
                        
                        HStack{
                            if self.selected == reason{
                                Image("checked_small")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                            }else{
                                Image("check_small")
                                    .resizable()
                                    .frame(width: 10, height: 10)
                            }
                        }
                    }
                }
            }
            
            if selected == "기타"{
            
            HStack(alignment: .firstTextBaseline, spacing: 20){
                
            Text("신고내용")
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(Color.proco_black)
                
                Spacer()
            }
            
            TextEditor(text: $report_content)
                .font(.system(size: 20, weight: .regular, design: .default))
                      .clipShape(RoundedRectangle(cornerRadius: 12))
                      .shadow(radius: 12)
                      .foregroundColor(.black)
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width, alignment: .center)
                            
            }
        }.padding(.vertical)
        .padding(.horizontal, UIScreen.main.bounds.width/20)
        .navigationBarTitle("신고하기")
    }
}

var report_menus = ["성적인 게시물", "폭력 또는 혐오 게시물", "스팸 또는 불법 게시물", "기타"]

