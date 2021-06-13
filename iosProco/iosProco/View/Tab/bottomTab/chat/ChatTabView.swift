//
//  ChatTabView.swift
//  proco
//
//  Created by 이은호 on 2020/11/23.
//

import SwiftUI

struct ChatTabView: View {

    //친구, 모여 탭 중 1개 선택
    @State var chosen_tab : Int
    
    @ViewBuilder
    var body: some View {
        NavigationView{
            VStack{
        //상단 선택 탭(친구랑 볼래 : 0, 모여 볼래: 1)
        HStack{
            Spacer()
            Button(action: {
                chosen_tab = 0
                print(chosen_tab)
            }){
                if chosen_tab==0{
                    Text("친구랑 볼래")
                        .overlay(Rectangle()
                                    .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/20)
                                    .offset(x: 2, y: 20)
                                    .animation(.easeInOut(duration: 2)))
                }else{
                    Text("친구랑 볼래")
                }
            }
            Spacer()
            Button(action: {
                chosen_tab = 1
                print(chosen_tab)
                
            }){
                if chosen_tab==1{
                    Text("모여 볼래")
                        .overlay(Rectangle()
                                    .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/20)
                                    .offset(x: 10, y: 20))
                    
                }else{
                Text("모여 볼래")
                }
            }
            Spacer()
            Button(action: {
                chosen_tab = 2
                print(chosen_tab)
                
            }){
                if chosen_tab==2{
                    Text("일반")
                        .overlay(Rectangle()
                                    .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/20)
                                    .offset(x: 10, y: 20))
                }else{
                Text("일반")
                }
            }
        }.frame(height: UIScreen.main.bounds.width/5)
                VStack{
        //친구랑 볼래 탭을 택했을 때 값=0, 모여볼래 탭은 값이 1, 일반 채팅방은 2
        if chosen_tab == 0{
            
            FriendChatTab(socket: SockMgr.socket_manager)
            
        }else if chosen_tab == 1{
            
            GatheringChatTab(socket: SockMgr.socket_manager)
        }
        else{
        }
                }
    }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
        }
}
}


