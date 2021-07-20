//
//  MyInfoDialog.swift
//  proco
//
//  Created by 이은호 on 2021/06/16.
//

import SwiftUI
import Kingfisher

struct MyInfoDialog: View {
    
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    @Binding var show_friend_info: Bool
    @ObservedObject var socket : SockMgr
    //채팅하기 클릭시 채팅화면으로 이동.
    @State private var go_to_chat: Bool = false
    //피드 화면 이동
    @State private var go_to_feed: Bool = false
    @Binding var state_on : Int
    @Binding var profile_photo_path : String
    
    var body: some View {
        if show_friend_info {
            Rectangle()
                .foregroundColor(Color.black.opacity(0.5))
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        //모달 컨텐츠를 포함하고 있는 큰 사각형. 색깔 투명하게 하기 위함.
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height*0.07)
                        .overlay(MyInfoDialogContents(main_vm: self.main_vm,show_friend_info: self.$show_friend_info, socket: socket, go_to_chat: self.$go_to_chat, go_to_feed: self.$go_to_feed, state_on: self.$state_on, profile_photo_path: self.$profile_photo_path)
                                    .offset(x: UIScreen.main.bounds.width*0.009, y: UIScreen.main.bounds.height * 0.05))
                )
        }
    }
}

struct MyInfoDialogContents : View{
    @ObservedObject var  calendar_vm: CalendarViewModel = CalendarViewModel()
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    @Binding var show_friend_info: Bool
    @ObservedObject var socket : SockMgr
    //일대일 채팅하기 화면 이동 구분값
    @Binding var go_to_chat: Bool
    
    @State private var open_report_view = false
    //피드 화면 이동 구분값
    @Binding var go_to_feed : Bool
    //관심친구 여부
    @State private var interest_friend = false
    //마이페이지 이동
    @State private var go_my_page : Bool = false
    //온오프 상태 버튼
    @Binding var state_on : Int
    @Binding var profile_photo_path : String

    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        VStack{
            HStack{
                Image("profile_close_btn")
                    .resizable()
                    .frame(width: 9, height: 9)
                    .onTapGesture {
                        withAnimation{
                            self.show_friend_info.toggle()
                        }
                    }
                Spacer()
            }
            //일반 채팅방 화면으로 이동.
            NavigationLink("",
                           destination: NormalChatRoom(main_vm: FriendVollehMainViewmodel(), group_main_vm: GroupVollehMainViewmodel(),socket: self.socket),
                           isActive: self.$go_to_chat)
            /////////테스트///////////////
//            NavigationLink("",destination: SimSimFeedPage(main_vm: CalendarViewModel()).navigationBarHidden(true).navigationBarTitle("", displayMode: .inline), isActive: self.$go_to_feed)
            NavigationLink("",destination: TabbarView(view_router: ViewRouter()).navigationBarHidden(true).navigationBarTitle("", displayMode: .inline), isActive: self.$go_to_feed)
            //마이페이지 이동(내 다이얼로그인 경우)
            NavigationLink("",destination: MyPage(main_vm: SettingViewModel()), isActive: self.$go_my_page)
            
            HStack{
                Spacer()
                
                if self.profile_photo_path == "" || self.profile_photo_path == nil{
                    
                    
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Spacer()
                    
                }else{
                    
                    KFImage(URL(string:  self.profile_photo_path))
                        .placeholder{Image("main_profile_img")
                            .resizable()
                            .frame(width: 48, height: 48)
                        }
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
                            
                            Image("main_profile_img")
                                .resizable()
                                .frame(width: 48, height: 48)
                        }
                    Spacer()
                }
            }
            
            HStack{
                Spacer()
                Text(self.main_vm.my_nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                
               
                Spacer()
            }
            .padding(.bottom,UIScreen.main.bounds.width/50)
            
            HStack{
                    
                    Button(action: {
                        
                        self.go_to_feed.toggle()
                        
                    }){
                        HStack{
                            
                            Text("마이페이지")
                                .foregroundColor(Color.proco_black)
                                .font(.custom(Font.t_extra_bold, size: 13))
                        }
                    }
                    .padding(.leading, UIScreen.main.bounds.width/7)
                    
                    //다른 사람 다이얼로그인 경우 심심페이지
                
                Spacer()
                Divider()
                Spacer()
                    
                    Text("상태")
                        .foregroundColor(Color.proco_black)
                        .font(.custom(Font.t_extra_bold, size: 13))
                    
                    Button(action: {
                        
                        //본래 상태가 off였었으므로 on으로 바꿈.
                        if self.state_on == 0{
                            print("on임")
                            self.state_on = 1
                            
                        }else{
                            print("off임")
                            self.state_on = 0
                        }
                        
                        SockMgr.socket_manager.click_on_off(user_idx: Int(self.main_vm.my_idx!)!, state: self.state_on, state_data: "")
                        UserDefaults.standard.set(self.state_on, forKey: "\(self.main_vm.my_idx!)_state")
                        print("내 idx: \(self.main_vm.my_idx!)")
                        print("온오프 버튼 클릭으로 바뀐 상태: \( self.state_on)")
                        
                    }){
                        Text(self.state_on == 0 ? "오프라인" : "온라인")
                            .font(.custom(Font.n_extra_bold, size: 13))
                            .foregroundColor(self.state_on == 0 ? Color.gray : Color.white)
                            .padding(UIScreen.main.bounds.width/30)
                    }
                    .background(self.state_on == 0 ? Color.proco_white : Color.proco_green)
                    .overlay(Capsule()
                                .stroke(self.state_on == 0 ? Color.gray : Color.proco_green, lineWidth: 1.5)
                                
                    )
                    .cornerRadius(25.0)
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                    
                
            }
            .padding(.bottom, UIScreen.main.bounds.width/50)
        }
        .padding(.all, UIScreen.main.bounds.width/40)
        .background(Color.proco_white)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .cornerRadius(15)
        .onAppear{
          
        }
    }
}
