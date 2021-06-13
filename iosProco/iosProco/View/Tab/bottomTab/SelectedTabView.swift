////
////  SelectedTabView.swift
////  proco
////
////  Created by 이은호 on 2020/12/21.
//// 혹시 몰라 남겨둔 클래스
//
//import SwiftUI
//
//struct SelectedTabView: View {
//    @ObservedObject var friend_card_main_viewmodel = FriendVollehMainViewmodel()
//d
//    @Binding var tab_index : Int
//
//    var body: some View{
//
//        Group{
//            TabView{
//                friend_state_list_view(friend_main_viewmodel: self.friend_card_main_viewmodel)
//                    .tabItem{
//                        Image(systemName: "heart.text.square")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
//                        Text("피드")
//                    }
//                friend_state_list_view(friend_main_viewmodel: self.friend_card_main_viewmodel)
//
//                    .tabItem{
//                        Image(systemName: "ellipsis.bubble")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
//
//                        Text("채팅")
//                    }
//                    .padding(.trailing, UIScreen.main.bounds.width/20)
//
//                friend_state_list_view(friend_main_viewmodel: self.friend_card_main_viewmodel)
//                    .tabItem{
//                        Image(systemName: "bell")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
//
//                        Text("알림")
//                    }
//                    .padding(.leading, UIScreen.main.bounds.width/20)
//
//                friend_state_list_view(friend_main_viewmodel: self.friend_card_main_viewmodel)
//                    .tabItem{
//                        Image(systemName: "person")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
//                        Text("마이")
//                    }
//            }
//            .overlay(//가운데 볼래 선택 탭
//                Button(action: {
//                    self.tab_index = 4
//                    //  self.selected_proco_tab.toggle()
//                }){
//                    VStack{
//                        Image(systemName: "command.circle").renderingMode(.original)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
//                    }
//                }
//                .offset(y: UIScreen.main.bounds.width*0.8))
//
//            //상단 메뉴바 아래 여백 생기는 문제 해결 아래 2개 코드
//            .frame(maxHeight:.infinity,  alignment: .top)
//            .navigationBarTitle("", displayMode: .inline)
//        }
//    }
//}
//
