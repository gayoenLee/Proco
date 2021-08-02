//
//  ChatMainView.swift
//  proco
//
//  Created by 이은호 on 2021/01/07.
//

import SwiftUI
import UserNotifications

struct ChatMainView: View {
    
    @State private var selectedTab = SockMgr.socket_manager.selected_tab
    
    var body: some View {
        NavigationView{
            VStack {
                TopNavBar(page_name: "채팅")
                ChatTabs(tabs: .constant(["일반", "친구", "모임"]),
                         selection: $selectedTab,
                         underlineColor: selectedTab == 0 ? .proco_black : selectedTab == 1 ? .main_orange : .main_green) { title, isSelected in
                    HStack{
                        if title == "친구"{
                            Image(isSelected == true ? "friend_chat_tab_title_active" : "friend_chat_tab_title_inactive")
                                .resizable()
                                .frame(width: 46, height: 40)
                        }
                        else if title == "모임"{
                            
                            if isSelected == true{
                                
                                Image("group_chat_tab_title_active" )
                                    .resizable()
                                    .frame(width: 62, height: 40)

                            }else{
                                
                                Image("group_chat_tab_title_inactive")
                                    .resizable()
                                    .frame(width: 46, height: 40)

                            }
                          
                        }else{
                            Image(isSelected == true ? "normal_chat_tab_title_active" : "normal_chat_tab_title_inactive")
                                .resizable()
                                .frame(width: 32, height: 21)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width*0.25, height: UIScreen.main.bounds.width*0.15)
                }
                if selectedTab == 1{
                    FriendChatTab(socket: SockMgr.socket_manager)
                }else if selectedTab == 2{
                    GatheringChatTab(socket: SockMgr.socket_manager)
                }else{
                    NormalChatTab(socket: SockMgr.socket_manager)
                }
                Spacer()
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .onAppear{
                
                selectedTab = SockMgr.socket_manager.selected_tab
                //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
                //채팅 목록 페이지 : 222, 채팅방 안: 333(기본: 111)
                SockMgr.socket_manager.current_view = 222
                //노티피케이션 권한 묻기
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){(_, _)in
                }
            }
            .onDisappear{
                if SockMgr.socket_manager.current_view != 333{
                SockMgr.socket_manager.current_view = 111
                }
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct ChatMainView_Previews: PreviewProvider {
    
    static var previews: some View {
        ChatMainView()
    }
}
