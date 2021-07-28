//
//  GatheringChatTab.swift
//  proco
//
//  Created by 이은호 on 2020/11/25.
//

import SwiftUI
import Combine
import SQLite3
import Kingfisher

struct GatheringChatTab: View {
    
    @ObservedObject var socket : SockMgr
    //채팅방 한 개 클릭시 채팅화면으로 이동시키기 위한 구분값
    @State private var go_to_chat = false
    
    var body: some View {
        VStack{

            NavigationLink("", destination: GatheringChatRoom( socket: socket).navigationBarHidden(true)
                            .navigationBarTitle(""), isActive: self.$go_to_chat)
            ScrollView{
                ForEach(socket.group_chat_model){gathering_chat in
                    GatheringChatRow(gathering_chat: gathering_chat)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*0.3)
                        .onReceive( NotificationCenter.default.publisher(for: Notification.new_message_in_room)){value in
                            print("모여 볼래 채팅방 목록에서 노티피케이션 센터 받음.: \(value)")
                            
                        }
                        .onTapGesture {
                            SockMgr.socket_manager.current_view = 333

                            //1.해당 카드의 chatroom_idx를 소켓 클래스의 publish변수에 저장
                            socket.enter_chatroom_idx = gathering_chat.chatroom_idx
                            print("모여 볼래 채팅방 1개 클릭 채팅방 idx: \(socket.enter_chatroom_idx)")
                            
                            //2.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                            ChatDataManager.shared.get_info_for_unread(chatroom_idx: gathering_chat.chatroom_idx)
                            //모여 볼래 - 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
                            ChatDataManager.shared.get_last_message_idx(chatroom_idx: gathering_chat.chatroom_idx)
                            print("모임 채팅 탭뷰에서 채팅방 1개 클릭 후 채팅룸 idx저장했는지 확인: \(socket.enter_chatroom_idx)")
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
            print("-------------------------그룹 채팅 목록 뷰 나옴------------------------")
            ChatDataManager.shared.set_room_data(kinds: "모임")
            print("그룹 채팅 목록 데이터 확인: \(SockMgr.socket_manager.group_chat_model)")
            
            if ViewRouter.get_view_router().fcm_destination == "normal_chat_room"{
                SockMgr.socket_manager.current_view = 333
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                //1.해당 카드의 chatroom_idx를 소켓 클래스의 publish변수에 저장
                socket.enter_chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
                print("모여 볼래 채팅방 1개 클릭 채팅방 idx: \(socket.enter_chatroom_idx)")
                
                //2.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                ChatDataManager.shared.get_info_for_unread(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                //모여 볼래 - 채팅방 읽음 처리 위해서 해당 채팅방의 마지막 메세지의 idx 가져오기(채팅방 1개 클릭시 입장하기 전에)
                ChatDataManager.shared.get_last_message_idx(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                print("모임 채팅 탭뷰에서 채팅방 1개 클릭 후 채팅룸 idx저장했는지 확인: \(socket.enter_chatroom_idx)")
                //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                ChatDataManager.shared.read_chatroom(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                self.go_to_chat.toggle()
                }
                
                
            }
            
        }
        .onDisappear{
            print("-------------------------그룹 채팅 목록 뷰 사라짐--------------------")
            socket.group_chat_model.removeAll()
        }
    }
}


struct GatheringChatRow : View{
    
    var gathering_chat : FriendChatRoomListModel
    var last_chat_time: String{
        if gathering_chat.chat_time == "" || gathering_chat.chat_time == nil{
            return ""
        }else{
            var time : String
            time = String.msg_time_formatter(date_string: gathering_chat.chat_time!)
            print("시간 변환 확인: \(time)")
            return time
        }
    }
    
    var promise_day: String{
        if gathering_chat.promise_day != "" || gathering_chat.promise_day != nil{
        return String.dot_form_date_string(date_string: gathering_chat.promise_day!)
        }else{
            return ""
        }
    }
    
    //채팅방 알림 설정
    var room_alarm_state : Bool{
        let alarm_state = UserDefaults.standard.string(forKey: "\(ChatDataManager.shared.my_idx!)_chatroom_alarm_\(gathering_chat.chatroom_idx)")
        
        //알람 꺼진 상태일 때
        if alarm_state == "0"{
            return false
        }else{
            return true
        }
    }
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        
        //카드 1개
        HStack{
            //카드 배경 위에 티켓 이미지, 모임 이름, 마지막 채팅 메세지, 시간, 알림
            VStack{
                Spacer()
                //모임 이미지
                if gathering_chat.image == "" || gathering_chat.image == nil{
                    Image("meeting_default_img")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
                        .scaledToFit()
                    
                }else{
                    
                    KFImage(URL(string: gathering_chat.image!))
                        .loadDiskFileSynchronously()
                        .cacheMemoryOnly()
                        .fade(duration: 0.25)
                        .setProcessor(img_processor)
                        .onProgress{receivedSize, totalSize in
                            print("on progress: \(receivedSize), \(totalSize)")
                        }
                        .onSuccess{result in
                            print("성공 : \(result)")
                        }
                        .onFailure{error in
                            print("실패 이유: \(error)")
                        }
                }
                Spacer()
            }
            
            VStack{
                HStack{
                    Text("\(promise_day)약속")
                        .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/27))
                        .foregroundColor(.proco_black)
                    Spacer()
                }
                
                
                //모임 이름, 인원수, 알림아이콘, 메세지시간포함
                HStack{
                    //모임 이름
                    Text(gathering_chat.room_name!)
                        .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/23))
                        .foregroundColor(.proco_black)
                    //모임 인원
                    Text(String(gathering_chat.total_member_num))
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/23))
                        .foregroundColor(.gray)
                    
                    //즐겨찾기, 알림 버튼(알림을 꺼놓은 경우에만 보여줌)
                    if self.room_alarm_state == false{
                        Button(action: {
                            
                        }){
                            Image("chatroom_alarm_off")
                            
                        }
                    }
                    Spacer()
                    
                }
                //마지막 채팅메세지, 안읽은 갯수
                HStack{
                    
                    if gathering_chat.last_chat == "" || gathering_chat == nil{
                        
                        Text("채팅 내역이 없습니다.")
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }else{
                        //마지막 채팅 메시지
                        Text(gathering_chat.last_chat!)
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    Text(last_chat_time)
                        .font(.custom(Font.n_regular, size: UIScreen.main.bounds.width/32))
                        .foregroundColor(.gray)
                    
                    //안읽은 메세지 갯수가 없을 때는 보여주지 않는다.
                    if gathering_chat.message_num == "" || gathering_chat.message_num == "0"{
                        
                    }else{
                        //모임 채팅방의 안읽은 메세지 수
                        Text(gathering_chat.message_num!)
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/32))
                            .frame(width: UIScreen.main.bounds.width/18, height: UIScreen.main.bounds.width/18, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 50).foregroundColor(.proco_red))
                    }
                }
                
            }
        }
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.15)
    }
    
}



