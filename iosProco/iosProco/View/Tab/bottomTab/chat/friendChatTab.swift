//
//  FriendChatTab.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//
//채팅 메인 페이지 - 친구랑 볼래 채팅탭
import SwiftUI
import Combine
import SQLite3

struct FriendChatTab: View {
    
    @ObservedObject var socket : SockMgr
    
    //채팅방 한 개 클릭시 채팅화면으로 이동시키기 위한 구분값
    @State private var go_to_chat = false
    
    var body: some View {
        
        VStack{
            NavigationLink("", destination: ChatFriendRoomView( socket: socket).navigationBarHidden(true)
                            .navigationBarTitle(""), isActive: self.$go_to_chat)
            
            ScrollView{
                ForEach(SockMgr.socket_manager.friend_chat_model){friend_chat in
                    
                    //채팅방 1개 클릭시 채팅창 화면으로 이동
                    FriendChatTabRow(friend_chat: friend_chat)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*0.3)
                        .onReceive( NotificationCenter.default.publisher(for: Notification.new_message_in_room)){value in
                            print("친구랑 볼래 채팅방 목록에서 노티피케이션 센터 받음.: \(value)")
                        }
                        .onTapGesture {
                            //1.해당 카드의 chatroom_idx를 소켓 클래스의 publish변수에 저장
                            print("친구랑 볼래 채팅방 1개 클릭")
                            socket.enter_chatroom_idx = friend_chat.chatroom_idx
                            
                            //2.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                            ChatDataManager.shared.get_info_for_unread(chatroom_idx: friend_chat.chatroom_idx)
                            //친구랑 볼래 - 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
                            ChatDataManager.shared.get_last_message_idx(chatroom_idx: friend_chat.chatroom_idx)
                            print("친구 채팅 탭뷰에서 채팅방 1개 클릭 후 채팅룸 idx저장했는지 확인: \(socket.enter_chatroom_idx)")
                            //1개 채팅방 정보 저장.
                            //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                            ChatDataManager.shared.read_chatroom(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                            self.go_to_chat.toggle()
                        }
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear{
            print("-------------------------친구 채팅 목록 뷰 나옴----------------------")
            ChatDataManager.shared.set_room_data(kinds: "친구")
            print("친구 채팅방 목록 데이터 확인: \(SockMgr.socket_manager.friend_chat_model)")
            
        }
        .onDisappear{
            print("-------------------------친구 채팅 목록 뷰 사라짐--------------------")
            socket.friend_chat_model.removeAll()
        }
    }
    
}
//프로필 이미지, 이름, 마지막 채팅 메세지, 시간, 태그3개
struct FriendChatTabRow : View{
    
    var friend_chat : FriendChatRoomListModel
    var last_chat_time: String{
        if friend_chat.chat_time == "" || friend_chat.chat_time == nil{
            return ""
        }else{
        var time : String
        time = String.msg_time_formatter(date_string: friend_chat.chat_time!)
        print("시간 변환 확인: \(time)")
        return time
        }
    }
    
    var promise_day : String{
        String.dot_form_date_string(date_string: friend_chat.promise_day!)
    }
    //채팅방 알림 설정
    var room_alarm_state : Bool{
        let alarm_state = UserDefaults.standard.string(forKey: "\(ChatDataManager.shared.my_idx!)_chatroom_alarm_\(friend_chat.chatroom_idx)")
        
        if alarm_state == "" || alarm_state == "1"{
            return true
        }else{
            return false
        }
    }
    var body: some View{
        
        //카드 1개
        HStack{
            VStack{
                Spacer()
                //프로필 이미지
                Image(friend_chat.image=="" ? "main_profile_img" : friend_chat.image == nil ? "main_profile_img" : friend_chat.image!)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
                    .scaledToFit()

                Spacer()
            }
          
            //카드 배경 위에 약속 날짜, 프로필 이미지, 이름, 마지막 채팅 메세지, 시간
            VStack{
                HStack{
                    Text(promise_day)
                        .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/27))
                        .foregroundColor(.proco_black)
                    
                    Spacer()
                    
                    Text(last_chat_time)
                        .font(.custom(Font.n_regular, size: UIScreen.main.bounds.width/28))
                        .foregroundColor(.gray)
 
                }
                HStack{
            
                    Text(self.friend_chat.room_name == ""  ? "\(String(describing: self.friend_chat.creator_name!))님과의 약속" : friend_chat.room_name!)
                        .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/20))
                        .foregroundColor(.proco_black)
                    
                    //채팅방 인원
                    Text(String(friend_chat.total_member_num))
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/22))
                        .foregroundColor(.gray)
                    
                    //채팅방 알림(꺼놓은 경우에만 보여주기)
                    if self.room_alarm_state == false{
                     Button(action: {
                     }){
                        Image("chatroom_alarm_off")
                     }
                    }
                    Spacer()
                }
                        HStack{
                            
                                //마지막 채팅 메시지
                            Text(friend_chat.last_chat == "" ? "채팅 내역이 없습니다.": friend_chat.last_chat!)
                                    .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/28))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            
                            Spacer()
                            
                            //안읽은 메세지 갯수가 없을 때는 보여주지 않는다.
                            if friend_chat.message_num == "" || friend_chat.message_num == "0"{
                                
                            }else{
                                Text(friend_chat.message_num!)
                                    .foregroundColor(.proco_white)
                                    .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/28))
                                    .frame(width: UIScreen.main.bounds.width/18, height: UIScreen.main.bounds.width/18, alignment: .center)
                                    .background(RoundedRectangle(cornerRadius: 50).foregroundColor(.proco_red))
                            }
                        }
                    
                }
            }
        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15)
    }
}



