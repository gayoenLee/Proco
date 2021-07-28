//
//  ChatroomSettingView.swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
//

import SwiftUI

struct ChatroomSettingView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var socket : SockMgr
    
    //var chatroom_name : String
    
    //채팅방 이름 변경 화면 이동 구분값.
    @State private var go_edit_name: Bool = false
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
                Text("채팅방 설정")
                    .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/20))
                    .foregroundColor(.proco_black)
                
                Spacer()
                
            }
            .padding()
            //이름 변경하는 화면 이동
            NavigationLink("",destination: ChatroomNameEditView(socket: self.socket).navigationBarHidden(true).navigationBarTitle("", displayMode: .inline), isActive: self.$go_edit_name)
            HStack{
                Text("채팅방 이름")
                    .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/23))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding([.leading])
            //현재 채팅방 이름과 수정하기 버튼.
            HStack{
                //친구, 모임, 일반 모두 채팅방 이름 커스텀 가능.
                HStack{
                    if SockMgr.socket_manager.current_chatroom_info_struct.room_name == ""{
                        Text("채팅방 이름을 설정해보세요")
                            .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.gray)
                    }else{
                        Text(SockMgr.socket_manager.current_chatroom_info_struct.room_name)
                            .font(.custom(Font.n_regular, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.proco_black)
                    }
                    
                    Spacer()
                    
                        Image("pencil")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                    
                }
                .padding()
                .onTapGesture {
                    self.go_edit_name.toggle()
                }
            }
            
            Spacer()
            
        }
        .onAppear{
            print("채팅방 설정 화면 on appear")
        }
    }
}

