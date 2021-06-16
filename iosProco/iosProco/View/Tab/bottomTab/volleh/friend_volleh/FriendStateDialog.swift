//
//  FriendStateDialog.swift
//  proco
//
//  Created by 이은호 on 2020/12/30.
//

import SwiftUI
import Kingfisher

struct FriendStateDialog: View {
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @Binding var show_friend_info: Bool
    @ObservedObject var socket : SockMgr
    //채팅하기 클릭시 채팅화면으로 이동.
    @State private var go_to_chat: Bool = false
    //피드 화면 이동
    @State private var go_to_feed: Bool = false
    @Binding var state_on : Int
    
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
                        .overlay(FriendStateDialogContents(main_vm: self.main_vm,show_friend_info: self.$show_friend_info, socket: socket, go_to_chat: self.$go_to_chat, go_to_feed: self.$go_to_feed, state_on: self.$state_on)
                                    .offset(x: UIScreen.main.bounds.width*0.009, y: UIScreen.main.bounds.height * 0.05))
                )
        }
    }
}


struct FriendStateDialogContents : View{
    @ObservedObject var  calendar_vm: CalendarViewModel = CalendarViewModel()
    @ObservedObject var main_vm: FriendVollehMainViewmodel
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
                           destination: NormalChatRoom(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(),socket: self.socket),
                           isActive: self.$go_to_chat)
            
            NavigationLink("",destination: SimSimFeedPage(main_vm: CalendarViewModel()), isActive: self.$go_to_feed)
            //마이페이지 이동(내 다이얼로그인 경우)
            NavigationLink("",destination: MyPage(main_vm: SettingViewModel()), isActive: self.$go_my_page)
            
            HStack{
                Spacer()
                
                if main_vm.friend_info_struct.profile_photo == "" || main_vm.friend_info_struct.profile_photo == nil{
                    
                    
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Spacer()
                    
                }else{
                    
                    KFImage(URL(string:  main_vm.friend_info_struct.profile_photo!))
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
                Text(self.main_vm.friend_info_struct.nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                
                //내 다이얼로그인 경우 관심친구 아이콘 보여주지 않는다.
                if Int(self.main_vm.my_idx!) == main_vm.friend_info_struct.idx{
                    
                }else{
                    
                    Button(action: {
                        if self.interest_friend == false{
                            
                            self.main_vm.set_interest_friend(f_idx: self.main_vm.friend_info_struct.idx!, action: "관심친구")
                            print("관심친구 지정하기 클릭")
                            
                        }else{
                            print("관심친구 해제하기 클릭")
                            
                            self.main_vm.set_interest_friend(f_idx: self.main_vm.friend_info_struct.idx!, action: "관심친구해제")
                        }
                    }){
                        Image(self.interest_friend == true ? "star_fill" : "star")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.set_interest_friend), perform: {value in
                        
                        print("관심친구 설정 완료 노티 받음")
                        if let user_info = value.userInfo, let check_result = user_info["set_interest_friend"]{
                            print("알림 설정 결과 받음: \(check_result)")
                            if check_result as! String == "set_ok_관심친구"{
                                
                                self.main_vm.friend_info_struct.kinds = "관심친구"
                                self.interest_friend = true
                                
                            }else{
                                
                                self.main_vm.friend_info_struct.kinds = "친구상태"
                                self.interest_friend = false
                            }
                        }
                    })
                }
                Spacer()
            }
            .padding(.bottom,UIScreen.main.bounds.width/50)
            
            HStack{
                //내 다이얼로그인 경우 마이페이지 버튼
                if Int(self.main_vm.my_idx!) == self.main_vm.friend_info_struct.idx!{
                    
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
                }else{
                    
                    Button(action: {
                        //캘린더를 보려는 사람의 idx = 내 idx 저장.
                        calendar_vm.calendar_owner.watch_user_idx = Int(main_vm.my_idx!)!
                        
                        print("친구 idx 확인: \(main_vm.friend_info_struct)")
                        SimSimFeedPage.calendar_owner_idx = main_vm.friend_info_struct.idx!
                        self.go_to_feed.toggle()
                        
                    }){
                        HStack{
                            
                            Image("profile_calendar")
                                .resizable()
                                .frame(width: 17, height: 19)
                            
                            Text("심심풀이 보기")
                                .foregroundColor(Color.proco_black)
                                .font(.custom(Font.t_extra_bold, size: 13))
                        }
                    }
                    .padding(.leading, UIScreen.main.bounds.width/20)
                    
                }
                Spacer()
                Divider()
                Spacer()
                
                if Int(self.main_vm.my_idx!) == self.main_vm.friend_info_struct.idx!{
                    
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
                          
                    }
                    .background(self.state_on == 0 ? Color.proco_white : Color.proco_green)
                    .overlay(Capsule()
                                .stroke(self.state_on == 0 ? Color.gray : Color.proco_green, lineWidth: 1.5)
                                
                    )
                    .cornerRadius(25.0)
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                    
                }else{
                    
                    Button(action: {
                        print("일대일 채팅하기 클릭 내 idx: \(Int(main_vm.my_idx!)!), 친구: \(main_vm.friend_info_struct.idx!)")
                        ChatDataManager.shared.check_chat_already(my_idx: Int(main_vm.my_idx!)!, friend_idx: main_vm.friend_info_struct.idx!)
                        self.go_to_chat.toggle()
                        
                    }){
                        HStack{
                            
                            Image("profile_chat_btn")
                                .resizable()
                                .frame(width: 17, height: 19)
                            
                            Text("채팅하기")
                                .foregroundColor(Color.proco_black)
                                .font(.custom(Font.t_extra_bold, size: 13))
                        }
                    }
                    .padding(.trailing, UIScreen.main.bounds.width/10)
                }
            }
            .padding(.bottom, UIScreen.main.bounds.width/50)
        }
        .padding(.all, UIScreen.main.bounds.width/40)
        .background(Color.proco_white)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .cornerRadius(15)
        .onAppear{
            print("친구 한 명 다이얼로그 나옴: \(self.main_vm.friend_info_struct)")
            self.interest_friend = self.main_vm.friend_info_struct.kinds == "관심친구" ? true : false
            self.state_on = self.main_vm.friend_info_struct.state!
        }
    }
}

