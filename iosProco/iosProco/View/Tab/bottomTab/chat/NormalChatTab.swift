//
//  NormalChatTab.swift
//  proco
//
//  Created by 이은호 on 2021/01/06.
//

import SwiftUI
import Combine
import SQLite3

struct NormalChatTab: View {
    
   // @ObservedObject var chat_data_mgr : ChatDataManager
    @ObservedObject var socket : SockMgr
    
    @State private var go_to_chat = false
    
    var body: some View {
        VStack{
            NavigationLink("", destination: NormalChatRoom(main_vm: FriendVollehMainViewmodel(), group_main_vm: GroupVollehMainViewmodel(),socket: self.socket).navigationBarHidden(true)
                            .navigationBarTitle(""), isActive: self.$go_to_chat)
            
            ScrollView{
                
                ForEach(socket.normal_chat_model.filter({
                    $0.last_chat != "" && $0.total_member_num >= 1
                })){normal_chat in
                    
                    NormalChatTabRow(normal_chat: normal_chat)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*0.3)
                        .onReceive( NotificationCenter.default.publisher(for: Notification.new_message_in_room_normal)){value in
                            print("일반 채팅방 목록에서 노티피케이션 센터 받음.: \(value)")
                        }
                        .onTapGesture {
                            print("일반 채팅 한 개 탭함")
                            SockMgr.socket_manager.current_view = 333
                            //1.해당 카드의 chatroom_idx를 소켓 클래스의 publish변수에 저장
                            print("일반 채팅방 1개 클릭")
                            socket.enter_chatroom_idx = normal_chat.chatroom_idx
                            
                            //2.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                            ChatDataManager.shared.get_info_for_unread(chatroom_idx: normal_chat.chatroom_idx)
                            
                            //일반 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
                            ChatDataManager.shared.get_last_message_idx(chatroom_idx: normal_chat.chatroom_idx)
                            print("일반 채팅 탭뷰에서 채팅방 1개 클릭 후 채팅룸 idx저장했는지 확인: \(socket.enter_chatroom_idx)")
                            //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                            ChatDataManager.shared.read_chatroom(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                            self.go_to_chat.toggle()
                        }
                }
            }
            //}
            
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear{
            print("------------------------일반 채팅 목록 뷰 나옴--------------------------")
            ChatDataManager.shared.set_room_data(kinds: "일반")
            
        }
        .onDisappear{
            print("-------------------------일반 채팅 목록 뷰 사라짐--------------------")
            socket.normal_chat_model.removeAll()
            
        }
    }
}

//프로필 이미지, 이름, 마지막 채팅 메세지, 시간
struct NormalChatTabRow : View{
    
    var normal_chat : FriendChatRoomListModel
    var last_chat_time: String{
        if normal_chat.chat_time == "" || normal_chat.chat_time == nil{
            return ""
        }else{
            var time : String
            time = String.msg_time_formatter(date_string: normal_chat.chat_time!)
            print("시간 변환 확인: \(time)")
            return time
        }
    }
    
    
    var body: some View{
        
        //카드 1개
        HStack{
            //카드 배경 위에 약속 날짜, 프로필 이미지, 이름, 마지막 채팅 메세지, 시간
            VStack{
                Spacer()
                
                //프로필 이미지
                Image(normal_chat.image == "" ? "main_profile_img" : normal_chat.image == nil  ? "main_profile_img" : normal_chat.image!)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
                    .scaledToFit()
                
                Spacer()
            }
            VStack{
                HStack{
                    //친구 이름...상대방 이름
                    Text(normal_chat.creator_name!)
                        .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                    
                    //채팅방 인원수
                    Text(String(normal_chat.total_member_num))
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/22))
                        .foregroundColor(.gray)
                    //알림버튼
                    Button(action: {
                        
                    }){
                        Image(systemName: "bell.fill")
                    }
                    Spacer()
                    Text(last_chat_time)
                        .font(.custom(Font.n_regular, size: UIScreen.main.bounds.width/28))
                        .foregroundColor(.gray)
                }
                HStack{
                    //마지막 채팅 메시지
                    Text(normal_chat.last_chat ?? "")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    if normal_chat.message_num == "" || normal_chat.message_num == "0"{
                    }else{
                        Text(normal_chat.message_num!)
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/28))
                            .frame(width: UIScreen.main.bounds.width/18, height: UIScreen.main.bounds.width/18, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 50).foregroundColor(.proco_red))
                    }
                }
            }
        }
        .onAppear{
            print("일반 채팅방 데이터 확인: \(normal_chat)")
        }
        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15)
    }
}

