//
//  ChatroomDrawer.swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
//

import SwiftUI
import Alamofire
import Combine
import Kingfisher

struct ChatroomDrawer: View {
    @Environment(\.presentationMode) var presentationMode : Binding<PresentationMode>
    
    @ObservedObject var socket : SockMgr
    
    //드로어에서 친구랑 볼래 카드 상세 페이지로 이동시 필요함.
    @StateObject var main_vm :  FriendVollehMainViewmodel
    //모여 볼래 카드 상세 페이지 이동시 필요함.
    @StateObject var group_main_vm :  GroupVollehMainViewmodel
    //친구랑 볼래 카드 상세 페이지로 이동시 사용.
    @State private var see_card_detail : Bool = false
    //모여 볼래 카드 상세 페이지로 이동시 사용.
    @State private var see_card_detail_group : Bool = false
    
    //채팅방에서 나가기 클릭시 한 번 더 물어보기 위해 나타나는 알림창 보여줄 때 사용.
    @State private var alert_go_out: Bool = false
    //채팅화면으로 돌아갈 때 사용.
    @State private var go_main: Bool = false
    
    //드로어 유저 한 명 클릭했을 때 다이얼로그 띄우기
    @Binding var show_profile : Bool
    //드로어에서 유저 한 명 클릭한 idx값 바인딩 -> 채팅룸에서 전달받기 -> 프로필 띄우기
    @Binding var selected_user_idx: Int
    
    //채팅방 주인에게만 추방하기 보여지기 위해 구분값을 주는데 사용.
    @State private var is_my_room : Bool = false
    //추방당한 사람을 메인으로 보내기 위해 이용하는 구분값
    @State private var banished : Bool = false
    
    //친구랑 카드 만들기할 때 화면 이동 구분값
    @State private var lets_make_card: Bool = false
    //친구 카드에 초대하기 할 때 화면 이동 구분값
    @State private var go_to_my_cards: Bool = false
    //친구와 카드 만들 때 만드는 뷰에 넘겨줄 카테고리
    @State var volleh_category_struct = VollehTagCategoryStruct()
    //채팅방 설정 화면으로 이동
    @State private var go_to_setting: Bool = false
    
    //친구, 모임카드 상세페이지 이동시 필요
    @StateObject var calendar_vm = CalendarViewModel()
    
    let my_idx = Int(ChatDataManager.shared.my_idx!)!
    
    @State private var chatroom_idx = String(SockMgr.socket_manager.enter_chatroom_idx)
    
    @State private var alarm_state : Bool = true
    
    @State private var alarm_result = SockMgr.socket_manager.chatroom_alarm_changed
    
    //드로어 열리는 값
    @Binding var show_menu : Bool
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View {
        
        ZStack{
            VStack{
                /*
                 일반 채팅방: 카드 정보 보기 버튼x,
                 친구랑 카드 만들기 & 내가 만든 카드에 초대하기o
                 */
                if SockMgr.socket_manager.current_chatroom_info_struct.kinds == "일반"{
                    Group{
                        //친구와 카드 만들기: 카드 만드는 페이지로 이동 > 완료시 동적 링크 채팅방에 보내기
                        make_card_with_friend_btn
                            .padding(.top)
                        
                        
                        //내가 만든 카드에 초대하기 버튼 클릭시 내가 만든 카드 리스트 페이지로 이동, api서버에 내 모든 카드 리스트 가져오는 통신 진행.
                        invite_my_card_btn
                        
                        Divider()
                    }
                    
                }else if SockMgr.socket_manager.current_chatroom_info_struct.kinds == "친구" ||  SockMgr.socket_manager.current_chatroom_info_struct.kinds.contains("모임"){
                    Group{
                        Spacer()
                        watch_card_info_btn
                        Spacer()
                        Divider()
                            .foregroundColor(.gray)
                    }
                }
                //임시채팅방인 경우
                else{
                }
                HStack{
                    Text("대화 상대")
                        .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/18))
                        .foregroundColor(.proco_black)
                        .padding(.leading, UIScreen.main.bounds.width/20)
                    
                    Spacer()
                }
                .padding(.top)
                //추방 당한 사람 메인 뷰로 이동시키기 위함.
                NavigationLink("",destination: FriendVollehMainView().navigationBarTitle("", displayMode: .inline)
                                .navigationBarHidden(true),
                               isActive: self.$banished)
                
                NavigationLink("",destination: ChatMainView().navigationBarTitle("", displayMode: .inline)
                                .navigationBarHidden(true), isActive: self.$go_main)
                Group{
                    //방 참가자들 리스트
                    ScrollView{
                        ForEach(SockMgr.socket_manager.user_drawer_struct){friend in
                            UserRow(socket: socket_manager, friend: friend, show_profile: self.$show_profile, selected_friend_idx: self.$selected_user_idx, show_menu: self.$show_menu)
                            
                        }
                    }
                    
                    Spacer()
                }
                
                Group{
                    //                    //유저 프로필에서 신고하기 클릭시 신고하는 페이지 이동.
                    //                    NavigationLink("",destination:  ReportView(show_report: self.$show_report_view, type: "채팅방회원", selected_user_idx: self.selected_user_idx, main_vm: FriendVollehMainViewmodel(), socket_manager: socket_manager, group_main_vm: self.group_main_vm), isActive: self.$show_report_view)
                    
                    //친구랑 볼래에서 카드 정보 보기클릭시 상세 화면으로 이동(방장만 수정하기 버튼 생성.)
                    NavigationLink("",destination: FriendVollehCardDetail(main_vm: self.main_vm, group_main_vm: self.group_main_vm, socket: socket_manager, calendar_vm: self.calendar_vm).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$see_card_detail)
                    
                    //모여볼래에서 카드 정보 보기 클릭시 상세 화면 이동.
                    NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.group_main_vm, socket: socket_manager, calendar_vm: self.calendar_vm).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true), isActive: self.$see_card_detail_group)
                    
                    //친구와 카드 만들기 클릭시 카드 만드는 화면 이동
                    NavigationLink("",
                                   destination: MakeCardView(main_viewmodel: self.main_vm, tag_category_struct: self.volleh_category_struct).navigationBarTitle("", displayMode: .inline)
                                    .navigationBarHidden(true),
                                   isActive: self.$lets_make_card)
                    
                    //친구 카드에 초대하기 클릭시 내가 만든 모든 카드 리스트 뷰로 이동
                    NavigationLink("",destination: AllMyCardList(socket: SockMgr.socket_manager).navigationBarTitle("", displayMode: .inline)
                                    .navigationBarHidden(true), isActive: self.$go_to_my_cards)
                }
                
                //방 나가기, 설정 버튼
                HStack{
                    exit_chatroom_btn
                    Spacer()
                    chatroom_setting_btn
                    chatroom_alarm_btn
                }
                .padding([.trailing, .bottom])
            }
            .padding()
            //            //유저 1명 프로필 뷰 보여주는 구분값 이 true일 때 다이얼로그 띄워서 보여주는 뷰
            //            if show_profile{
            //                ChatRoomUserProfileView(friend: SockMgr.socket_manager.user_drawer_struct[selected_user_row], show_profile: self.$show_profile, socket: socket_manager, selected_friend_idx: self.$selected_friend_idx, show_report_view: self.$show_report_view)
            //            }
            
        }.animation(.easeInOut)
        .onReceive( NotificationCenter.default.publisher(for: Notification.new_message)){value in
            print("채팅방 드로어에서 노티  받음")
            if let user_info = value.userInfo, let check_banished = user_info["banished"]{
                print("추방 당한 이벤트: \(check_banished)")
                
                if check_banished as! String == "banished"{
                    print("추방 당한 이벤트 true: \(check_banished)")
                    
                    // self.banished = true
                    self.presentationMode.wrappedValue.dismiss()
                    
                }
            }else{
                print("추방 이벤트 아님")
            }
        }
        .onAppear{
            //친구 탭 클릭시 read chatroom으로 가져오는 데이터
            print("드로어에서 채팅방 데이터: \(SockMgr.socket_manager.current_chatroom_info_struct)")
            
            let alarm_info = UserDefaults.standard.string(forKey: "\(my_idx)_chatroom_alarm_\(chatroom_idx)") ?? ""
            if alarm_info == ""{
                self.alarm_state = true
            }else{
                print("드로어에서 채팅방 알림 정보: \(alarm_info)")
                if alarm_info == "0"{
                    self.alarm_state = false
                }else{
                    self.alarm_state = true
                }
            }
            
            
        }
    }
}

extension ChatroomDrawer{
    
    var exit_chatroom_btn : some View{
        
        //나가기 버튼
        Button(action: {
            print("읽음 처리 위한 user read list: \(ChatDataManager.shared.user_read_list)")
            //나갈 거냐고 한 번 더 묻는 알림창
            self.alert_go_out.toggle()
        }){
            Image("out_room_btn")
            //                    .resizable()
            //                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
        }
        .alert(isPresented: self.$alert_go_out){
            Alert(title: Text("채팅방 나가기"), message: Text("채팅방을 나가시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                let user_idx = UserDefaults.standard.string(forKey: "user_id")
                let nickname = UserDefaults.standard.string(forKey: "nickname")
                print("가져온 닉네임 확인: \(String(describing: nickname))")
                print("드로어에서 나가는 방 종류 확인: \(SockMgr.socket_manager.current_chatroom_info_struct.kinds)")
                //확인 눌렀을 때 통신 시작
                socket.exit_room(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, idx: my_idx, nickname:nickname! ,profile_photo_path: "", kinds: SockMgr.socket_manager.current_chatroom_info_struct.kinds)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    if socket_manager.chatroom_exit_ok{
                        print("채팅방 나가기 됨.")
                        //화면 닫기 이벤트
                        self.go_main.toggle()
                    }
                }
            }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                self.alert_go_out.toggle()
            }))
        }
    }
    
    var chatroom_setting_btn: some View{
        //채팅방 설정버튼 - 채팅방 나가기, 채팅방 이름 변경 가능
        HStack{
            NavigationLink("",destination: ChatroomSettingView(socket: SockMgr.socket_manager).navigationBarHidden(true).navigationBarTitle("", displayMode: .inline), isActive: self.$go_to_setting)
            
            Button(action: {
                
                print("채팅방 설정 버튼 클릭")
                self.go_to_setting.toggle()
            }){
                Image("setting_btn")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
            }
            .padding(.trailing, UIScreen.main.bounds.width/20)
        }
    }
    
    var chatroom_alarm_btn : some View{
        HStack{
            Button(action: {
                if self.alarm_state{
                    print("알림이 켜져있을 때 끄는 것")
                    SockMgr.socket_manager.chatroom_alarm_setting_event(chatroom_idx: Int(chatroom_idx)!, state: 0)
                    
                }else{
                    print("알림이 켜져있을 때 켜는 것")
                    SockMgr.socket_manager.chatroom_alarm_setting_event(chatroom_idx: Int(chatroom_idx)!, state: 1)
                    
                }
                print("채팅방 알림 버튼 클릭")
            }, label: {
                Image(self.alarm_state == true ? "chatroom_alarm" : "chatroom_alarm_off")
                
            })
            .onReceive(NotificationCenter.default.publisher(for: Notification.alarm_changed), perform: { value in
                print("알림 설정 결과 받음: \(value)")
                
                if let user_info = value.userInfo, let check_result = user_info["alarm_changed"]{
                    
                    print("알림 설정 결과 받음: \(check_result)")
                    
                    if check_result as! String == "chat_room"{
                        
                        let state = user_info["state"] as! String
                        
                        if state == "0" {
                            
                            UserDefaults.standard.set("0", forKey: "\(ChatDataManager.shared.my_idx!)_chatroom_alarm_\(chatroom_idx)")
                            
                            self.alarm_state = false
                            
                        }else{
                            UserDefaults.standard.set("1", forKey: "\(ChatDataManager.shared.my_idx!)_chatroom_alarm_\(chatroom_idx)")
                            self.alarm_state = true
                        }
                    }
                }
            })
        }
    }
    
    var watch_card_info_btn: some View{
        
        HStack{
            Image(SockMgr.socket_manager.current_chatroom_info_struct.kinds == "친구" ? "drawer_card_friend" : SockMgr.socket_manager.current_chatroom_info_struct.kinds.split(separator: " ")[1] == "모임" ? "drawer_card_group" : "")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
            
            Button(action: {
                print("드로어에서 카드 주인 정보 데이터 있는지 확인: 내 닉네임: \(String(describing: ChatDataManager.shared.my_nickname)) 주인 닉네임 : \(SockMgr.socket_manager.creator_nickname), 주인 idx: \(SockMgr.socket_manager.creator_idx)")
                
                //메인에서 카드 상세 페이지 갈 때, 드로어에서 상세 페이지 갈 때 구분하기 위해 아래 값을 변경하는 것.
                SockMgr.socket_manager.is_from_chatroom = true
                
                //방장이 카드 편집시 채팅방에서 편집한다는 것을 알리기 위함.
                socket_manager.edit_from_chatroom = true
                
                //친구랑 볼래일 경우와 모여볼래일 경우 상세 페이지가 다르므로 페이지 이동 구분을 다르게 함.
                if SockMgr.socket_manager.current_chatroom_info_struct.kinds == "친구"{
                    //카드 정보 상세 페이지에서 상세 데이터 가져오는 통신시 필요한 카드 idx
                    main_vm.selected_card_idx = SockMgr.socket_manager.current_chatroom_info_struct.card_idx
                    print("카드 정보보려는 카드 Idx: \(main_vm.selected_card_idx)")
                    
                    self.see_card_detail.toggle()
                    
                }else{
                    //이걸 설정해줘야 카드 상세페이지에서 해당 카드의 정보 가져오는 통신 가능.
                    group_main_vm.selected_card_idx = SockMgr.socket_manager.current_chatroom_info_struct.card_idx
                    
                    self.see_card_detail_group.toggle()
                }
                print("카드 정보 보기 클릭시 socket enter chatroom idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
            }){
                Text("카드 정보 보기")
                    .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/15))
                    .foregroundColor(.proco_black)
            }
            Spacer()
        }
    }
    
    var make_card_with_friend_btn: some View{
        HStack{
            
            
            Text("친구와 약속 만들기")
                .font(.custom(Font.n_extra_bold, size:  UIScreen.main.bounds.width/15))
                .foregroundColor(.proco_black)
            
            Spacer()
            
            Image("right_light")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
        }
        .onTapGesture {
            //카드 만드는 페이지에서 드로어, 메인에서 카드 만드는 것 구분해서 카드 만들기 완료시 동적 링크 생성 구분값 나누기 위함.
            socket_manager.is_from_chatroom = true
            self.lets_make_card.toggle()
        }
        .padding([.top,.leading, .trailing])
        
    }
    
    var invite_my_card_btn : some View{
        HStack{
            
            Text("내 약속에 초대하기")
                .font(.custom(Font.n_extra_bold, size:  UIScreen.main.bounds.width/15))
                .foregroundColor(.proco_black)
            Spacer()
            
            Image("right_light")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/30, height: UIScreen.main.bounds.width/30)
            
        }
        .onTapGesture {
            
            SockMgr.socket_manager.is_from_chatroom = true
            SockMgr.socket_manager.detail_to_invite = true
            SockMgr.socket_manager.is_dynamic_link = false
            
            //SockMgr.socket_manager.get_all_my_cards()
            self.go_to_my_cards.toggle()
        }
        .padding([.top,.leading, .trailing])
    }
    
}

struct UserRow : View{
    
    @ObservedObject var socket : SockMgr
    var friend : UserInDrawerStruct
    //친구 1명 선택했을 때 프로필 뷰 나타내기 위해 사용하는 구분값.
    @Binding var show_profile : Bool
    
    //선택한 친구의 user idx
    @Binding var selected_friend_idx: Int
    
    //드로어 열리는 값
    @Binding var show_menu : Bool
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        
        VStack{
            HStack{
                if friend.profile_photo == "" || friend.profile_photo == nil{
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                }else{
                    Image(friend.profile_photo!)
                        .resizable()
                        .overlay(
                            Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
                
                Text(friend.nickname!)
                    .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/15))
                    .foregroundColor(.proco_black)
                Spacer()
                
                //클릭시 프로필 화면
            }.onTapGesture {
                
                self.selected_friend_idx = friend.user_idx!
                print("프로필 한 개 클릭 선택한 사람 인덱스: \(selected_friend_idx)")
                //self.show_menu = false
                //프로필 뷰 보여주기
                self.show_profile.toggle()
            }
        }
        .padding([.top])
    }
}
//프로필 다이얼로그
struct ChatRoomUserProfileView: View{
    
    var friend : UserInDrawerStruct
    @Binding var show_profile : Bool
    @ObservedObject var socket : SockMgr
    @State private var check_banish: Bool = false
    //선택한 친구의 user idx
    @Binding var selected_friend_idx: Int
    
    //신고하기 클릭시 나타날 모달창
    @Binding var show_report_view :Bool
    let my_idx = Int(ChatDataManager.shared.my_idx!)
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50)) |> RoundCornerImageProcessor(cornerRadius: 25)
    @Binding var go_feed: Bool
    @ObservedObject var calendar_vm : CalendarViewModel
    @Binding var go_private_chatroom : Bool
    @Binding var show_context_menu : Bool
    
    var body: some View{
        
        ZStack{
            //다이얼로그 바탕 화면
            Rectangle()
                .fill(Color.black)
                .opacity(0.5)
            
            
            VStack{
                
                HStack{
                    //프로필 닫기
                    Button(action: {
                        withAnimation {
                            self.show_profile.toggle()
                        }
                        
                    }) {
                        Image("profile_close_btn")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                    
                    .padding(.leading,UIScreen.main.bounds.width/30)
                    if Int(ChatDataManager.shared.my_idx!) != friend.user_idx!{
                        HStack{
                            Spacer()
                            Button(action: {
                                
                                print("추방하기, 신고하기 액션시트 띄우기 클릭")
                                self.show_context_menu = true
                            }){
                                Image("context_menu_btn")
                                    .resizable()
                                    .frame(width: 4, height: 15)
                                    .padding([.leading,.trailing],UIScreen.main.bounds.width/20)
                                
                            }
                        }
                        
                        .actionSheet(isPresented: self.$show_context_menu){
                            ActionSheet(title: Text("\(friend.nickname!)님을"), message: Text(""), buttons: //방장에게만 보이는 버튼(닉네임으로 비교)
                                            Int(ChatDataManager.shared.my_idx!) == SockMgr.socket_manager.creator_idx ? [ .default(Text("추방하기"), action: {
                                                //추방하시겠습니까 알람 띄우기
                                                self.check_banish.toggle()
                                                //추방할 사람의 유저 모델 정보 가져오기
                                                print("추방하려는 사람의 idx: \(selected_friend_idx)")
                                            }), .default(Text("신고하기"), action: {
                                                //선택한 친구의 idx를 manage_viewmodel에 저장해 나중에 그룹에 추가하는 통신시 사용
                                                self.show_profile.toggle()
                                                print("신고!!\(self.selected_friend_idx)")
                                                
                                                self.show_report_view.toggle()
                                            }), .cancel(Text("취소"))] : [.default(Text("신고하기"), action: {
                                                //선택한 친구의 idx를 manage_viewmodel에 저장해 나중에 그룹에 추가하는 통신시 사용
                                                //self.show_profile.toggle()
                                                print("신고!!\(self.selected_friend_idx)")
                                                self.show_report_view = true
                                            }), .cancel(Text("취소"))])
                        }
                        .alert(isPresented: $check_banish){
                            Alert(title: Text("추방하기"), message: Text("추방하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                                print("추방 확인 클릭")
                                self.check_banish = false
                                self.show_profile = false
                                
                                //추방하려는 사람의 정보 가져오기
                                ChatDataManager.shared.get_user_info(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, user_idx: selected_friend_idx)
                                
                                //내 유저 모델 가져오기
                                ChatDataManager.shared.get_my_user_info(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, user_idx: my_idx!)
                                
                                SockMgr.socket_manager.banish_user(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, my_idx: my_idx!, my_nickname: ChatDataManager.shared.my_nickname!, my_profile_photo_path: SockMgr.socket_manager.my_profile_photo, op_idx: SockMgr.socket_manager.banish_user_info.idx, op_nickname: SockMgr.socket_manager.banish_user_info.nickname, op_profile_photo_path: SockMgr.socket_manager.banish_user_info.profile_photo_path ?? "")
                                
                            }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                                self.check_banish.toggle()
                            }))
                        }
                    }
                }
                .padding([.leading, .trailing],UIScreen.main.bounds.width/30)
                .padding(.top, UIScreen.main.bounds.width/20)
                HStack{
                    NavigationLink("",destination: SimSimFeedPage(main_vm: self.calendar_vm, view_router: ViewRouter()), isActive: self.$go_feed)
                    NavigationLink("",destination:  NormalChatRoom(main_vm: FriendVollehMainViewmodel() ,group_main_vm: GroupVollehMainViewmodel(),socket: SockMgr.socket_manager), isActive: self.$go_private_chatroom)
                }.frame(width: 5, height: UIScreen.main.bounds.width/30, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                //프로필 이미지
                HStack{
                    Spacer()
                    if friend.profile_photo == "" || friend.profile_photo == nil{
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }else{
                        KFImage(URL(string: friend.profile_photo!))
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
                    }
                    
                    Spacer()
                }
                
                //이름
                HStack{
                    Spacer()
                    Text(friend.nickname!)
                        .font(.custom(Font.n_bold, size: 15))
                        .foregroundColor(.proco_black)
                    Spacer()
                }
                .padding(.bottom,UIScreen.main.bounds.width/50)
                //채팅하기, 심심풀이 보기, 추방하기 버튼
                HStack{
                    Button(action: {
                        
                        calendar_vm.calendar_owner.user_idx = friend.user_idx!
                        calendar_vm.calendar_owner.profile_photo_path = friend.profile_photo ?? ""
                        calendar_vm.calendar_owner.user_nickname = friend.nickname!
                        calendar_vm.calendar_owner.watch_user_idx = Int(ChatDataManager.shared.my_idx!)!
                        SimSimFeedPage.calendar_owner_idx = friend.user_idx!
                        self.go_feed = true
                        
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
                    .padding(.leading, UIScreen.main.bounds.width/7)
                    Spacer()
                    Divider()
                    Spacer()
                    Button(action: {
                        print("채팅하기 클릭한 친구 정보: \(friend)")
                        ChatDataManager.shared.check_chat_already(my_idx: Int(ChatDataManager.shared.my_idx!)!, friend_idx: friend.user_idx!, nickname: friend.nickname!)
                        
                        self.go_private_chatroom = true
                    })
                    {
                        HStack{
                            
                            Image("profile_chat_btn")
                                .resizable()
                                .frame(width: 17, height: 19)
                            
                            Text("채팅하기")
                                .foregroundColor(Color.proco_black)
                                .font(.custom(Font.t_extra_bold, size: 13))
                        }
                        .padding(.trailing, UIScreen.main.bounds.width/7)
                    }
                }
                .padding(.bottom,UIScreen.main.bounds.width/50)
                
            }
            .frame(minWidth: UIScreen.main.bounds.width*0.9, idealWidth: UIScreen.main.bounds.width*0.9, maxWidth: UIScreen.main.bounds.width*0.9, minHeight: UIScreen.main.bounds.width*0.4, idealHeight: UIScreen.main.bounds.width*0.51, maxHeight: UIScreen.main.bounds.width*0.7, alignment: .top)
            .fixedSize(horizontal: true, vertical: true)
            .background(RoundedRectangle(cornerRadius: 27)
                            .fill(Color.white.opacity(1)))
            .overlay(RoundedRectangle(cornerRadius: 27).stroke(Color.black, lineWidth: 1))
            
        }
        .padding(.all, UIScreen.main.bounds.width/40)
    }
}








