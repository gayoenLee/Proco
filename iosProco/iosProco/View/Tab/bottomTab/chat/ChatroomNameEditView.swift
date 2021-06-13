//
//  ChatroomNameEditView.swift
//  proco
//
//  Created by 이은호 on 2021/01/26.
//  채팅방 설정 - 채팅방 이름 변경 화면

import SwiftUI

struct ChatroomNameEditView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var socket : SockMgr
    
    //텍스트필드에 입력값 담기 위한 변수
    @State private var chatroom_name: String = ""
    
    //변경하려는 이름 값이 없는데 확인 버튼을 눌렀을 경우 알림 창
    @State private var show_alert: Bool = false
    //채팅방 이름 변경 완료 후 화면 이동 구분값
    @State private var edit_ok: Bool = false
    
    var body: some View {
        VStack{
            //상단바
            HStack{
                //뒤로 가기 버튼.
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }){
                    Image("left")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                
                Spacer()
                //화면 타이틀
                Text("채팅방 이름 변경")
                    .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/10))
                    .foregroundColor(.proco_black)
                Spacer()
                
                Button(action: {
                    
                    if self.chatroom_name == ""{
                        /*
                         변경하고자 하는 채팅방 이름이 널일 경우
                         1.디비에 업데이트하지 않기.
                         2.확인 버튼을 눌렀을 경우 알림 창 보여주기.
                         */
                        self.show_alert.toggle()
                        print("변경하려는 이름 값이 없음.")
                    }else{
                        //디비에 room name값 업데이트하는 쿼리
                        print("채팅방 이름 변경하려는 방 idx: \(socket.enter_chatroom_idx)")
                        
                        ChatDataManager.shared.update_room_name(chatroom_idx: socket.enter_chatroom_idx, room_name: self.chatroom_name)
                        //채팅방 목록 데이터 모델에도 저장해야 수정 후에 수정한 대로 보임.
                        self.presentation.wrappedValue.dismiss()
                        //self.edit_ok.toggle()
                        
                    }
                }){
                    Text("확인")
                        .padding()
                        .font(.custom(Font.t_extra_bold, size: UIScreen.main.bounds.width/17))
                        .foregroundColor(.proco_white)
                        .overlay(RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundColor(.proco_black))
                }
                .alert(isPresented: self.$show_alert){
                    Alert(title: Text("채팅방 이름 설정") .font(.custom(Font.t_extra_bold, size: UIScreen.main.bounds.width/17))
                            .foregroundColor(.proco_black), message: Text("변경하려는 채팅방 이름을 입력해주세요")
                                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                                .foregroundColor(.proco_black), dismissButton: .default(Text("확인") .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                                                                                            .foregroundColor(.proco_black)))
                }
            }
            HStack{
                //텍스트필드 기본값은 원래 채팅방 이름(왼쪽 placeholder)
                TextField(SockMgr.socket_manager.current_chatroom_info_struct.room_name, text: self.$chatroom_name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                //취소 버튼.
                Button(action: {
                    self.chatroom_name = ""
                }){
                    Image("card_dialog_close_icon")
                        .padding()
                }
            }.padding()
        }
    }
}

