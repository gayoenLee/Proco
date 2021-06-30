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
    @ObservedObject var group_main_vm: GroupVollehMainViewmodel
    @ObservedObject var  calendar_vm: CalendarViewModel

    @Binding var show_friend_info: Bool
    @ObservedObject var socket : SockMgr
    //채팅하기 클릭시 채팅화면으로 이동.
    @State private var go_to_chat: Bool = false
    //피드 화면 이동
    @State private var go_to_feed: Bool = false
    @Binding var state_on : Int?
    //친구, 모임 모두에서 다이얼로그를 사용해서 구분하기 위함.
    var is_friend : Bool
    //신고하기 클릭시 신고하는 팝업창 띄우기
    @State private var show_report_view : Bool = false
    //채팅방 목록에서 회원 클릭 후 다이얼로그에서만 신고 가능함.
    var is_from_chatroom : Bool
    
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
                        .overlay(FriendStateDialogContents(calendar_vm: self.calendar_vm, main_vm: self.main_vm,group_main_vm: self.group_main_vm, show_friend_info: self.$show_friend_info, socket: socket, go_to_chat: self.$go_to_chat, go_to_feed: self.$go_to_feed, state_on: self.$state_on, is_friend: self.is_friend, show_report_view: self.$show_report_view, is_from_chatroom: is_from_chatroom)
                                    .offset(x: UIScreen.main.bounds.width*0.009, y: UIScreen.main.bounds.height * 0.05))
                )
        }
    }
}


struct FriendStateDialogContents : View{
    @ObservedObject var  calendar_vm: CalendarViewModel
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @ObservedObject var group_main_vm: GroupVollehMainViewmodel
    
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
    @Binding var state_on : Int?
    //친구, 모임 모두에서 다이얼로그를 사용해서 구분하기 위함.
    var is_friend : Bool
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 25)
    @Binding var show_report_view : Bool
    var is_from_chatroom : Bool
    
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
                
                //채팅방 목록 안에서만 유저 신고 가능.
                if is_from_chatroom{
                HStack{
                Image("context_menu_icon")
                    .resizable()
                    .frame(width: 3, height: 15)
                }
                    .contextMenu{
                        Button(action: {
                           print("신고하기 클릭")
                            self.show_report_view = true
                            
                        }){
                            Text("신고하기")
                        }
                    }
                }
            }
            .padding([.leading, .trailing])
            
            //일반 채팅방 화면으로 이동.
            NavigationLink("",
                           destination: NormalChatRoom(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(),socket: self.socket),
                           isActive: self.$go_to_chat)
            
            NavigationLink("",destination: SimSimFeedPage(main_vm: self.calendar_vm, view_router: ViewRouter()), isActive: self.$go_to_feed)
            
            //마이페이지 이동(내 다이얼로그인 경우)
            NavigationLink("",destination: MyPage(main_vm: SettingViewModel()), isActive: self.$go_my_page)
            
            HStack{
                Spacer()
                
                if !self.is_friend{
                    if group_main_vm.creator_info.profile_photo_path == "" || group_main_vm.creator_info.profile_photo_path == nil{
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Spacer()
                        
                    }else{
                        
                        KFImage(URL(string:  group_main_vm.creator_info.profile_photo_path!))
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
                }else{
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
            }
            
            HStack{
                Spacer()
                
                if self.is_friend{
                Text(self.main_vm.friend_info_struct.nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                    
                }else{
                    
                    Text(self.group_main_vm.creator_info.nickname!)
                        .font(.custom(Font.n_bold, size: 15))
                        .foregroundColor(.proco_black)
                }
                
                if is_friend{
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
                
            }
                Spacer()
            }
            .padding(.bottom,UIScreen.main.bounds.width/50)
            
            HStack{
                //내 다이얼로그인 경우 마이페이지 버튼
                if is_friend && Int(self.main_vm.my_idx!) == self.main_vm.friend_info_struct.idx!{
                    
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
                        print("다른 사람 피드 보기 버튼 클릭")
                        //캘린더를 보려는 사람의 idx = 내 idx 저장.
                        if is_friend{
                          print("친구인 경우")
                            calendar_vm.calendar_owner.watch_user_idx = Int(calendar_vm.my_idx!)!
                            print("캘린더 보는 유저 idx: \(calendar_vm.calendar_owner.watch_user_idx), \(Int(calendar_vm.my_idx!)!)")
                            
                            calendar_vm.calendar_owner.profile_photo_path = main_vm.friend_info_struct.profile_photo ?? ""
                            
                            calendar_vm.calendar_owner.user_idx = main_vm.friend_info_struct.idx!
                            print("캘린더 주인 idx: \(main_vm.friend_info_struct.idx!)")
                            print("캘린더 주인 데이터 넣은 것 확인: \(calendar_vm.calendar_owner)")
                            
                            SimSimFeedPage.calendar_owner_idx = main_vm.friend_info_struct.idx!
                            
                            //친구가 아닌 경우는 모임에서 다이얼로그를 클릭한 경우
                        }else{
                            print("친구가 아닌 경우 피드 보기 버튼 클릭: \(group_main_vm.creator_info)")
                            
                            calendar_vm.calendar_owner.watch_user_idx = Int(group_main_vm.my_idx!)!
                            calendar_vm.calendar_owner.profile_photo_path = group_main_vm.creator_info.profile_photo_path ?? ""
                            calendar_vm.calendar_owner.user_nickname = group_main_vm.creator_info.nickname!
                            calendar_vm.calendar_owner.user_idx = group_main_vm.creator_info.idx!
                            SimSimFeedPage.calendar_owner_idx = group_main_vm.creator_info.idx!
                                                        
                        }
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
                
                //모임 참여자들의 프로필 클릭시 심심풀이 보기만 보여짐.
                if is_friend{
                    
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
                        
                        SockMgr.socket_manager.click_on_off(user_idx: Int(self.main_vm.my_idx!)!, state: self.state_on!, state_data: "")
                        
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
            }
            .padding(.bottom, UIScreen.main.bounds.width/50)
        }
        .padding(.all, UIScreen.main.bounds.width/40)
        .background(Color.proco_white)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .cornerRadius(15)
        .onAppear{
            if is_friend{
            print("친구 한 명 다이얼로그 나옴: \(self.main_vm.friend_info_struct)")
            self.interest_friend = self.main_vm.friend_info_struct.kinds == "관심친구" ? true : false
            self.state_on = self.main_vm.friend_info_struct.state!
            }
        }
        .sheet(isPresented: self.$show_report_view) {
            ReportView(show_report: self.$show_report_view, type: "", selected_user_idx: -1, main_vm: self.main_vm, socket_manager: SockMgr(), group_main_vm: GroupVollehMainViewmodel())
        }
    }
}

