//
//  CardInvitaionView.swift
//  proco
//
//  Created by 이은호 on 2021/02/03.
// 친구와 카드 만들기 초대장

import SwiftUI

struct CardInvitaionView: View {
    @ObservedObject var socket : SockMgr
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    
    //노티를 받은 후 친구 채팅방으로 이동할 때 사용.
    @State private var go_to_room: Bool = false
    //노티를 받은 후 모임 채팅방으로 이동할 때 사용
    @State private var go_to_group_room: Bool = false
    
    //새로 채팅방을 만든 사람의 idx
    @State private var creator_idx = -1
    
    var body: some View {
        VStack{
            Image(systemName: "hare")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2, alignment: .center)
                .padding()
            
            HStack{
                //각각 채팅 초대 수락 후 친구, 모임 채팅방으로 이동하는 것.
                NavigationLink("",destination: ChatFriendRoomView(socket: socket).navigationBarHidden(true)
                                .navigationBarTitle(""), isActive: self.$go_to_room)
                NavigationLink("",destination: GatheringChatRoom(socket: SockMgr.socket_manager).navigationBarHidden(true)
                                .navigationBarTitle(""), isActive: self.$go_to_group_room)
                
                if self.creator_idx != Int(ChatDataManager.shared.my_idx!){
                    
                    /*
                     수락 버튼 클릭시
                     1.api 서버에 참여 요청 통신
                     2.채팅서버에 수락 이벤트 보내기 - api 서버 result ok 받은 후
                     */
                    Button(action: {
                        
                        let chatroom_idx = SockMgr.socket_manager.invite_chatroom_idx
                        print("수락 클릭: \(chatroom_idx)")

                        //참가 수락하는 api 서버 통신 -> ok 오면 채팅서버에 수락 이벤트 보냄.
                        socket_manager.accept_dynamic_link(chatroom_idx: chatroom_idx)
                        
                        /*
                         서버에서 수락 이벤트가 완료됐다고 알려줬을 때
                         1.유저 데이터 꺼내오기
                         2.읽음 처리 위해 마지막 메세지 idx 가져오기
                         3.채팅방으로 이동시킨다.-> notification center에서 on receive이용.
                         */
                        if SockMgr.socket_manager.server_invite_accepted{
                            
                            print("서버에서 데이터 저장 완료 후 server invite accepted뷰에서 트루 받음")
                            //1.chat_user테이블에서 데이터 꺼내오기(채팅방입장시 user read이벤트 보낼 때 사용.)
                            ChatDataManager.shared.get_info_for_unread(chatroom_idx: chatroom_idx)
                            //2.
                            ChatDataManager.shared.get_last_message_idx(chatroom_idx: chatroom_idx)
                            
                        }
                    }, label: {
                        Text("수락")
                    })
                    .padding()
                    .onReceive(NotificationCenter.default.publisher(for: Notification.dynamic_link_move_view), perform: { value in
                        print("참여 수락 완료 이벤트 받음: \(value)")
                        
                        if let user_info = value.userInfo, let check_result = user_info["dynamic_link_move_view"]{
                            
                            let kind = user_info["kind"]  as! String
                            print("참여 수락 완료 이벤트 받음: \(check_result)")
                            if kind == "친구"{
                                print("친구 카드에 초대한 경우 뷰 이동 노티 받음")
                                self.go_to_room.toggle()
                            }else{
                                print("모임 카드에 초대한 경우 뷰 이동 노티 받음")
                                self.go_to_group_room.toggle()
                            }

                        }

                    })

                }
            }
        }
        .onAppear{
            print("---------------------카드 초대장 뷰 나타남---------------------")
            //카드 초대장의 수락, 거절 버튼은 카드를 만든 사람한테 안보이게 하기 위해 카드 만든 사람 idx 가져오기
            print("새로 만들어진 채팅방 idx SockMgr: \(SockMgr.socket_manager.invite_chatroom_idx)")
            ChatDataManager.shared.read_chatroom(chatroom_idx: SockMgr.socket_manager.invite_chatroom_idx)
            
            
           // self.main_vm.get_card_detail(card_idx: self.main_vm.selected_card_idx)
            
            self.creator_idx = socket.current_chatroom_info_struct.creator_idx
            print("채팅방 주인 idx: \(self.creator_idx)")
        }
    }
}

