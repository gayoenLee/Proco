//
//  BottonTabView.swift
//  proco
//
//  Created by 이은호 on 2020/12/21.
//

import SwiftUI

struct BottomTabView: View {
   
    @ObservedObject var view_router: ViewRouter
    @ObservedObject var vm: CalendarViewModel = CalendarViewModel()
        
    var body: some View {
        NavigationView{
            VStack {
                Spacer()
                Group{
                    //탭바에 따른 뷰
                    switch view_router.current_page {
                    case .chat_tab:
                        //chatTabView(chosen_tab: 0)
                        ChatMainView()
//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarHidden(true)
                            .onAppear{
                                UITabBar.appearance().barTintColor = .white
                            }
                    case .feed_tab:
                        SimSimFeedPage( main_vm: self.vm, view_router: self.view_router)
                            .onAppear{
                                //내 피드 화면으로 이동시 presentation: , 내 닉네임, 프로필 사진을 저장해놔야 함.
                                vm.calendar_owner.user_idx = SimSimFeedPage.calendar_owner_idx!
                                vm.calendar_owner.profile_photo_path = UserDefaults.standard.string(forKey: "\(vm.calendar_owner.user_idx)_photo") ?? ""
                                let user_idx = UserDefaults.standard.string(forKey: "user_id")
                                vm.calendar_owner.user_nickname = UserDefaults.standard.string(forKey: "\(user_idx)_nickname")!
                                vm.calendar_owner.watch_user_idx = Int(vm.my_idx!)!
                                print("심심피드 탭 클릭: \(vm.calendar_owner)")
                                //다른 화면으로 이동시 하단 탭바 숨기는 것.
                                //UITabBar.appearance().barTintColor = .white
                                }
                            
                    case .friend_volleh:
                        FriendVollehMainView()
//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarHidden(true)
                            .onAppear{
                                print("친구랑볼래온어피어")

                                //UITabBar.appearance().barTintColor = .white
                            }
                    case .people_volleh:
                        GroupVollehMainView()
//                            .navigationViewStyle(StackNavigationViewStyle())

//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarHidden(true)
                            .onAppear{
                                UITabBar.appearance().barTintColor = .white
                            }
                    case .notice_tab:
                        NotiListView()
//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarHidden(true)
                            .onAppear{
                                UITabBar.appearance().barTintColor = .white
                            }
                    case .manage_friend_tab:
                        ManageFriendListView()
                        
                    case .group_chat_room:
                        GatheringChatRoom(socket: socket_manager)
                            .onAppear{
                                print("모임 채팅룸온어피어: \(socket_manager.enter_chatroom_idx)")
                                let my_idx = Int(ChatDataManager.shared.my_idx!)
                                print("서버에 보내기 전에 idx확인: \(String(describing: ChatDataManager.shared.my_idx))")
                                print("채팅방 입장시 user read에 보내는 read last idx: \(ChatDataManager.shared.read_last_message)")
                                
                                ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                                let server_idx = ChatDataManager.shared.user_server_idx
                               
                                let updated_at = ChatDataManager.shared.make_created_at()
                                //서버에 내 user chat model보내기.user read이벤트 보내는 것.
                                socket_manager.enter_friend_card_chat(server_idx:   server_idx, user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, nickname:ChatDataManager.shared.my_nickname!, profile_photo_path: "", read_start_idx: ChatDataManager.shared.read_start_message, read_last_idx: ChatDataManager.shared.read_last_message, updated_at: updated_at, deleted_at: "")
                                
                                //내가 마지막으로 읽은 메세지 최신 메세지idx로 업데이트(나)
                                ChatDataManager.shared.update_user_read(chatroom_idx: socket_manager.enter_chatroom_idx, read_last_idx: ChatDataManager.shared.last_message_idx, user_idx: my_idx!, updated_at: updated_at)
                                
                                //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
                                //채팅 목록 페이지 : 222, 채팅방 안: 333(기본: 111)
                                socket_manager.current_view = 333
                                
                                //메시지별로 안읽은 갯수 표현하기 위해 계산하는 것.
                                if  ChatDataManager.shared.get_read_last_list(chatroom_idx: socket_manager.enter_chatroom_idx){
                                    print("친구랑 볼래에서 채팅방 마지막 메세지 idx 가져옴: \(ChatDataManager.shared.user_read_list)")
                                }
                                
                                //채팅 메세지 데이터 가져오기
                                ChatDataManager.shared.get_message_data(chatroom_idx: socket_manager.enter_chatroom_idx, user_idx: Int(ChatDataManager.shared.my_idx!)!)
                                //안읽은 메세지 계산 메소드.
                                ChatDataManager.shared.calculate_last()
                                
                                //채팅 방 안 유저 정보들 가져와서 데이터 모델에 넣기(드로어에 보여줌)
                                ChatDataManager.shared.read_chat_user(chatroom_idx: socket_manager.enter_chatroom_idx)
                                print("친구 채팅방 onappear 현재 채팅방 idx: \(socket_manager.enter_chatroom_idx)")
                                
                                //현재 채팅방의 주인 idx를 이용해 닉네임 가져와서 상단에 표시하기, 드로어 예외처리에 사용.
                                ChatDataManager.shared.get_creator_nickname(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                                ChatDataManager.shared.read_chatroom(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                print("메세지 : \(SockMgr.socket_manager.chat_message_struct)")
                                print("채팅방 주인: \(socket_manager.creator_nickname)")
                                UITabBar.appearance().barTintColor = .white
                            }
                        
                    case .normal_chat_room:
                        NormalChatRoom(main_vm: FriendVollehMainViewmodel(), group_main_vm: GroupVollehMainViewmodel(), socket: socket_manager)
                            .onAppear{
                                print("일반 채팅룸온어피어: \(socket_manager.enter_chatroom_idx)")
                                let my_idx = Int(ChatDataManager.shared.my_idx!)
                                print("서버에 보내기 전에 idx확인: \(String(describing: ChatDataManager.shared.my_idx))")
                                print("채팅방 입장시 user read에 보내는 read last idx: \(ChatDataManager.shared.read_last_message)")
                                
                                ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                                let server_idx = ChatDataManager.shared.user_server_idx
                               
                                let updated_at = ChatDataManager.shared.make_created_at()
                                //서버에 내 user chat model보내기.user read이벤트 보내는 것.
                                socket_manager.enter_friend_card_chat(server_idx:   server_idx, user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, nickname:ChatDataManager.shared.my_nickname!, profile_photo_path: "", read_start_idx: ChatDataManager.shared.read_start_message, read_last_idx: ChatDataManager.shared.read_last_message, updated_at: updated_at, deleted_at: "")
                                
                                //내가 마지막으로 읽은 메세지 최신 메세지idx로 업데이트(나)
                                ChatDataManager.shared.update_user_read(chatroom_idx: socket_manager.enter_chatroom_idx, read_last_idx: ChatDataManager.shared.last_message_idx, user_idx: my_idx!, updated_at: updated_at)
                                
                                //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
                                //채팅 목록 페이지 : 222, 채팅방 안: 333(기본: 111)
                                socket_manager.current_view = 333
                                
                                //메시지별로 안읽은 갯수 표현하기 위해 계산하는 것.
                                if  ChatDataManager.shared.get_read_last_list(chatroom_idx: socket_manager.enter_chatroom_idx){
                                    print("친구랑 볼래에서 채팅방 마지막 메세지 idx 가져옴: \(ChatDataManager.shared.user_read_list)")
                                }
                                
                                //채팅 메세지 데이터 가져오기
                                ChatDataManager.shared.get_message_data(chatroom_idx: socket_manager.enter_chatroom_idx, user_idx: Int(ChatDataManager.shared.my_idx!)!)
                                //안읽은 메세지 계산 메소드.
                                ChatDataManager.shared.calculate_last()
                                
                                //채팅 방 안 유저 정보들 가져와서 데이터 모델에 넣기(드로어에 보여줌)
                                ChatDataManager.shared.read_chat_user(chatroom_idx: socket_manager.enter_chatroom_idx)
                                print("친구 채팅방 onappear 현재 채팅방 idx: \(socket_manager.enter_chatroom_idx)")
                                
                                //현재 채팅방의 주인 idx를 이용해 닉네임 가져와서 상단에 표시하기, 드로어 예외처리에 사용.
                                ChatDataManager.shared.get_creator_nickname(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                                ChatDataManager.shared.read_chatroom(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                print("메세지 : \(SockMgr.socket_manager.chat_message_struct)")
                                print("채팅방 주인: \(socket_manager.creator_nickname)")
                                UITabBar.appearance().barTintColor = .white
                            }
                        
                    case .chat_room:
                        
                        ChatFriendRoomView(socket: socket_manager)
//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarHidden(true)
                            .onAppear{
                                print("채팅룸온어피어: \(socket_manager.enter_chatroom_idx)")
                                let my_idx = Int(ChatDataManager.shared.my_idx!)
                                print("서버에 보내기 전에 idx확인: \(String(describing: ChatDataManager.shared.my_idx))")
                                print("채팅방 입장시 user read에 보내는 read last idx: \(ChatDataManager.shared.read_last_message)")
                                
                                ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                                let server_idx = ChatDataManager.shared.user_server_idx
                               
                                let updated_at = ChatDataManager.shared.make_created_at()
                                //서버에 내 user chat model보내기.user read이벤트 보내는 것.
                                socket_manager.enter_friend_card_chat(server_idx:   server_idx, user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, nickname:ChatDataManager.shared.my_nickname!, profile_photo_path: "", read_start_idx: ChatDataManager.shared.read_start_message, read_last_idx: ChatDataManager.shared.read_last_message, updated_at: updated_at, deleted_at: "")
                                
                                //내가 마지막으로 읽은 메세지 최신 메세지idx로 업데이트(나)
                                ChatDataManager.shared.update_user_read(chatroom_idx: socket_manager.enter_chatroom_idx, read_last_idx: ChatDataManager.shared.last_message_idx, user_idx: my_idx!, updated_at: updated_at)
                                
                                //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
                                //채팅 목록 페이지 : 222, 채팅방 안: 333(기본: 111)
                                socket_manager.current_view = 333
                                
                                //메시지별로 안읽은 갯수 표현하기 위해 계산하는 것.
                                if  ChatDataManager.shared.get_read_last_list(chatroom_idx: socket_manager.enter_chatroom_idx){
                                    print("친구랑 볼래에서 채팅방 마지막 메세지 idx 가져옴: \(ChatDataManager.shared.user_read_list)")
                                }
                                
                                //채팅 메세지 데이터 가져오기
                                ChatDataManager.shared.get_message_data(chatroom_idx: socket_manager.enter_chatroom_idx, user_idx: Int(ChatDataManager.shared.my_idx!)!)
                                //안읽은 메세지 계산 메소드.
                                ChatDataManager.shared.calculate_last()
                                
                                //채팅 방 안 유저 정보들 가져와서 데이터 모델에 넣기(드로어에 보여줌)
                                ChatDataManager.shared.read_chat_user(chatroom_idx: socket_manager.enter_chatroom_idx)
                                print("친구 채팅방 onappear 현재 채팅방 idx: \(socket_manager.enter_chatroom_idx)")
                                
                                //현재 채팅방의 주인 idx를 이용해 닉네임 가져와서 상단에 표시하기, 드로어 예외처리에 사용.
                                ChatDataManager.shared.get_creator_nickname(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                //드로어에서 카드 정보 보여주기 예외 처리 위해서 채팅방 정보 가져오기
                                ChatDataManager.shared.read_chatroom(chatroom_idx: socket_manager.enter_chatroom_idx)
                                
                                print("메세지 : \(SockMgr.socket_manager.chat_message_struct)")
                                print("채팅방 주인: \(socket_manager.creator_nickname)")
                                UITabBar.appearance().barTintColor = .white
                            }
                    }
                }
                Spacer()
                
                //하단 탭바
                ZStack {
                    Group{
                        HStack {
                            
                            TabBarIcon(view_router: view_router, assigned_page: .friend_volleh, width: 28.64, height: 29.35, systemIconName: "tab_friend_line", tabName: "친구", selected_icon: "tab_friend_fill")
                                .padding(.leading)

                            Spacer()
                            TabBarIcon(view_router: view_router, assigned_page: .people_volleh, width: 26.01, height: 29.35, systemIconName: "tab_grp_line", tabName: "모임", selected_icon: "tab_grp_fill")
                            Spacer()

                            TabBarIcon(view_router: view_router, assigned_page: .feed_tab, width: 33, height: 33.14, systemIconName: "tab_simsim_line", tabName: "피드", selected_icon: "tab_simsim_fill")
                            Spacer()

                            TabBarIcon(view_router: view_router, assigned_page: .chat_tab, width: 29.82, height: 34.69, systemIconName: "tab_chat_line", tabName: "채팅", selected_icon: "tab_chat_fill")
                            Spacer()

                            TabBarIcon(view_router: view_router, assigned_page: .notice_tab, width: 17.39, height: 35.6, systemIconName: "tab_alarm_line", tabName: "알림", selected_icon: "tab_alarm_fill")
                                .padding(.trailing)
 
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.09)
                        .background(Color.tabbar_bg)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
        }
        
    }
}

