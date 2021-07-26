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
    @State private var show_event_dialog  = false
    @State private var event_result_string = ""
    var body: some View {
        
    VStack{
        
        //상단 제목 라인
        HStack{

            Button(action: {

                self.presentation.wrappedValue.dismiss()

            }, label: {

                Image("left")
                    .resizable()
                    .frame(width: 8.51, height: 17)
            })
            .padding(.leading, UIScreen.main.bounds.width/20)

            Spacer()

            Text("신고하기")
                .font(.custom(Font.t_extra_bold, size: 20))
                .foregroundColor(.proco_black)
                .padding(.trailing, UIScreen.main.bounds.width/20)

            Spacer()

        }
        .padding()
        
        ZStack{
            ReportRadioButtons(type : self.$type ,selected: self.$selected, report_content: self.$report_content)
        }

        Spacer()
        Button(action: {
            
            print("신고 확인 클릭")
            switch self.type{
            case "카드" :
                print("친구 카드 신고일 때\(String(main_vm.selected_card_idx))")
                
                self.main_vm.send_reports(kinds: "카드", unique_idx: String(main_vm.selected_card_idx), report_kinds: self.selected, content: self.report_content)
                
               
                break
            case "모임카드" :
                print("모임 카드 신고일 때 \(String(self.group_main_vm.selected_card_idx))")
                self.group_main_vm.send_reports(kinds: "카드", unique_idx: String(self.group_main_vm.selected_card_idx), report_kinds: self.selected, content: self.report_content)
                

                break
                
            //일반회원신고의 경우 채팅방 회원 kinds 로 보내되 , 채팅방 idx를 음수로 보낸다.
            case "일반회원" :
                print("일반 회원 신고일 때\(socket_manager.enter_chatroom_idx),\(selected_user_idx)")
                let unique_idx = "-1,\(selected_user_idx)"
                self.socket_manager.send_reports(kinds: "채팅방회원", unique_idx: unique_idx, report_kinds: self.selected, content: self.report_content)
                break
            case "채팅방회원" :

                let unique_idx = "\(SockMgr.socket_manager.enter_chatroom_idx),\(selected_user_idx)"
                self.socket_manager.send_reports(kinds: "채팅방회원", unique_idx: unique_idx, report_kinds: self.selected, content: self.report_content)
                break
            default :
                print("없는 경우(에러)")
                break
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
        .alert(isPresented: $show_event_dialog){
            switch event_result_string{
            case "success":
                return Alert(title: Text("신고하기"), message: Text("신고가 접수되었습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                    self.show_report.toggle()

                }))

            case "fail":
                return Alert(title: Text("신고하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    
                }))
            default :
                print("신고하기 결과 예외")
                return
                    Alert(title: Text("신고하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                        
                    }))
                
            
            }
        }

        .padding(.bottom)
    }
    .onReceive(NotificationCenter.default.publisher(for: Notification.event_finished), perform: {value in
        print("신고 완료 받음.: \(value)")
        
        if let user_info = value.userInfo{
            let check_result = user_info["report_result"]
            print("신고 완료 데이터 확인: \(check_result)")
            if check_result as! String == "ok"{
                self.show_event_dialog.toggle()
                self.event_result_string = "success"
            }
            else{
                self.show_event_dialog.toggle()
                self.event_result_string = "fail"
            }
            
        }

    })
    .onAppear{

        print("신고하기 뷰 나타남: \(self.type) , \(SockMgr.socket_manager.enter_chatroom_idx)")
      
        }
    }
    
}

//신고하기 메뉴 뷰
struct ReportRadioButtons: View{
    @Binding var type :String
    @Binding var selected: String
    @Binding var report_content: String
    
    //신고 타입에 따라 메뉴의 내용들이 바뀐다.

    
    var body: some View{
        
        VStack(alignment: .leading, spacing: 20){
            if (type == "카드") || (type == "모임카드"){
                ForEach(card_report_menus, id: \.self){reason in
                    
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
            }else{
                ForEach(person_report_menus, id: \.self){reason in
                    
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
                .frame(minWidth : UIScreen.main.bounds.width*0.9,maxWidth:  UIScreen.main.bounds.width*0.9,minHeight:UIScreen.main.bounds.height*0.1, maxHeight: UIScreen.main.bounds.height*0.4, alignment: .center)
                    
            }
        }.padding(.vertical)
        .padding(.horizontal, UIScreen.main.bounds.width/20)
        .navigationBarTitle("신고하기")
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
//카드 신고일 경우
var card_report_menus : [String] = ["성적인 게시물", "폭력 또는 혐오 게시물", "스팸 또는 불법 게시물", "기타"]

//회원 신고일 경우
var person_report_menus : [String] = ["음란/성인 행위", "불법 정보(도박/사행성)", "기타"]
