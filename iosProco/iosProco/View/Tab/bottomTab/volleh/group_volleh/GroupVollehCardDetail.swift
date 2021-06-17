//
//  GroupVollehCardDetail.swift
//  proco
//
//  Created by 이은호 on 2020/11/30.
//

import SwiftUI
import Combine
import Kingfisher

struct GroupVollehCardDetail: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var main_vm: GroupVollehMainViewmodel
    @StateObject var socket : SockMgr
    
    
    //드로어에서 카드 수정하기 화면으로 이동.
    @State private var go_edit_from_chat: Bool = false
    //메인 모여 볼래에서 카드 수정하기 화면으로 이동.
    @State private var go_edit_from_main: Bool = false
    
    //신청자 ,참가자 목록 뷰로 이동하기
    @State private var go_people_list : Bool = false
    
    //드로어 - 내 카드에 초대하기 - 본래 채팅방으로 이동할 때 사용.
    @State private var go_back_chatroom: Bool = false
    
    //캘린더에서 상세페이지로 넘어온 경우가 생겨서 캘린더 뷰모델 필요
    @StateObject var calendar_vm: CalendarViewModel
    
    //신고하기 클릭시 모달창 띄우는데 사용.
    @State private var show_report_view = false
    
    @State private var expiration_at : String = ""
    @State private var meeting_time : String = ""
    //모임 참가 신청 통신 완료시 alert창 띄우는데 switch문 case에 넣어줄 값
    @State private var apply_ok : String = ""
    //모임 참가 신청 통신 완료시 alert창 띄우기
    @State private var apply_result : Bool = false
    
    //동적링크 통해 들어온 경우 참여하기 클릭 후 채팅방으로 이동시키기 위함.
    @State private var go_invited_room : Bool = false
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    //카드 정보가 없거나 만료됐을 때 no result 알림창
    @State private var show_no_result : Bool = false
    //카드 주최자 프로필 다이얼로그 띄우기
    @State private var show_creator_dialog : Bool = false
    
    //주최자 클릭시 다이얼로그를 띄우는데 이때 필요한 값..state로 안해도 되지만 다이얼로그 뷰 클래스를 여러 곳에서 함께 쓰기 위해 어쩔수 없이 state변수 만들어서 값 넘김.
    @State private var creator_state_on : Int? = 0
    
    //이용규칙 뷰 보여주는 구분값
    @State private var show_proco_rules : Bool = false
    
    //지도 위치 세부 뷰 띄우는 구분값
    @State private var show_location_detail : Bool  = false
    @State private var detail_info = false

    var body: some View {
        NavigationView{
        VStack{
            
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    Group{
                        //상단 돌아가기, 제목, 수정하기 버튼 탭
                        HStack{
                            //돌아가기 버튼
                            Image("left")
                                .resizable()
                                .frame(width: 10, height: 17)
                                .padding(.leading, UIScreen.main.bounds.width/20)
                                .onTapGesture {
                                    withAnimation{
                                        self.presentation.wrappedValue.dismiss()
                                        //self.show_current_view.toggle()
                                    }
                                }
                            
                            Spacer()
                            /*
                             수정 하기 버튼
                             - 주인만 가능.
                             - 드로어에서 넘어온 경우, 메인에서 상세 페이지로 넘어온 경우
                             */
                            if Int(self.main_vm.my_idx!) == self.main_vm.card_detail_struct.creator!.idx{
                                
                            Button(action: {
                                
                                self.main_vm.selected_card_idx =  main_vm.my_card_detail_struct.card_idx!
                                print("메인에서 상세 페이지로 들어온 후 카드 정보 수정하기 이동. card idx: \(self.main_vm.selected_card_idx)")
                                
                                //self.main_vm.get_detail_card()
                                
                                self.go_edit_from_main.toggle()
                            }){
                                Image(systemName: "pencil.circle")
                                    .padding()
                            }
                            }
                        }
                    }
                    .padding(.top, UIScreen.main.bounds.width/20)
                    
                    Spacer()
                    report_btn
                    Group{
                        
                        HStack{
                            card_category_and_title
                            Spacer()
                            card_like
                        }
                        card_tags
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(.light_gray)
                            .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.2)
                            .overlay(
                                host_info
                            )
                        
                        Spacer()
                        
                        //날짜
                        date_view
                        //시간
                        time_view
                    }
                    HStack{
                        NavigationLink(destination: ApplyPeopleListView(main_vm: self.main_vm, show_view: $go_people_list) .navigationBarTitle("", displayMode: .inline)
                                        .navigationBarHidden(true), isActive: self.$go_people_list){
                            
                            apply_people_list_title
                            
                        }.simultaneousGesture(TapGesture().onEnded{
                            //참가자, 신청자 리스트 가져오는 통신 - 드로어에서 볼 경우, 메인에서 볼 경우 모두 진행.
                            if SockMgr.socket_manager.is_from_chatroom{
                                print("is from chatroom true일 때 신청자 목록 페이지 이동 클릭")
                                self.main_vm.selected_card_idx = SockMgr.socket_manager.current_chatroom_info_struct.card_idx
                                print("채팅방 드로어에서 참가자, 신청자 리스트 가져올 경우")
                                // self.main_vm.get_apply_people_list()
                                
                                //캘린더에서 왔을 경우 신청자 참가자 통신
                            }else if calendar_vm.from_calendar{
                                print("캘린더에서 왔을 경우")
                                self.main_vm.selected_card_idx = calendar_vm.group_card_detail_model.card_idx
                                //self.main_vm.get_apply_people_list()
                                
                            }else{
                                //수락, 거절 버튼 예외처리 위해 메소드 실행.
                                self.main_vm.find_owner()
                                print("드로어 아닌 메인에서 참가자, 신청자 리스트 가져올 경우")
                                self.main_vm.get_apply_people_list()
                            }
                            //self.go_people_list = true
                        })
                    }
                    
                    Group{
                        if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                            if self.main_vm.my_card_detail_struct.kinds! == "오프라인 모임"{
                                location
                            }
                        }else{
                            if self.main_vm.card_detail_struct.kinds! == "오프라인 모임"{
                                location
                            }
                        }
                        
                        //세부사항 부분
                        meeting_introduce
                        
                        //프로코 이용 규칙
                        Divider()
                            .frame(width: UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.width/30, alignment: .center)
                        proco_rules
                        
                        //동적링크를 통해 들어와서 참여하기 클릭시 채팅방으로 이동시키는 것.
                        NavigationLink("",destination: GatheringChatRoom(socket: SockMgr.socket_manager).navigationBarHidden(true)
                                        .navigationBarTitle(""), isActive: self.$go_invited_room)
                        
                        //드로어에서 카드 상세 페이지 -> 카드 수정 화면 이동
                        NavigationLink("",
                                       destination: EditGroupCard( main_vm: self.main_vm ).navigationBarTitle("", displayMode: .inline)
                                        .navigationBarHidden(true),
                                       isActive: self.$go_edit_from_chat)
                        
                        //드로어 - 초대하기 - 채팅방으로 다시 이동
                        NavigationLink("",
                                       destination: NormalChatRoom(main_vm: FriendVollehMainViewmodel(), group_main_vm: self.main_vm,socket: self.socket).navigationBarTitle("", displayMode: .inline)
                                        .navigationBarHidden(true),
                                       isActive: self.$go_back_chatroom)
                        
                        apply_btn
                            .alert(isPresented: self.$apply_result){
                                switch self.apply_ok{
                                case "ok":
                                    return  Alert(title: Text("참가 신청"), message: Text("참가 신청이 완료됐습니다."), dismissButton: .default(Text("확인")))
                                case "fail":
                                    return  Alert(title: Text("참가 신청"), message: Text("참가 신청을 다시 시도해주세요."), dismissButton: .default(Text("확인")))
                                default:
                                    return  Alert(title: Text("참가 신청"), message: Text("참가 신청을 다시 시도해주세요."), dismissButton: .default(Text("확인")))
                                }
                            }
                            .onReceive(NotificationCenter.default.publisher(for: Notification.apply_meeting_result)){value in
                                print("참가 신청 완료 노티 받음")
                                if let user_info = value.userInfo, let data = user_info["apply_meeting_result"]{
                                    if data as! String == "ok"{
                                        
                                        self.apply_ok = "ok"
                                        print("ok통신 : \(self.apply_ok)")
                                        
                                    }else{
                                        
                                        self.apply_ok = "fail"
                                        print("fail통신: \(self.apply_ok)")
                                    }
                                    self.apply_result = true
                                }
                            }
                    }
                }.padding()
            }
        }
        .sheet(isPresented: self.$show_proco_rules){
            TermContentsView(url: "https://withproco.com/tos.html?view=tos#tos_items_11")
        }
        .sheet(isPresented: self.$show_location_detail){
           MapDetailInfoView(vm: self.main_vm)
        }
        .onAppear{
            print("-------------------------------상세 페이지 나타남 동적링크에서 왔는지: \(socket.is_dynamic_link), 선택한 카드idx: \(self.main_vm.selected_card_idx)------------------------")
            if socket.is_dynamic_link{
                
                self.main_vm.selected_card_idx = self.socket.selected_card_idx
                print("동적링크에서 들어온 경우 카드 idx: \(self.main_vm.selected_card_idx)")
            }
            //이걸 해야 지도 데이터 부분에서 분기처리가 됨.
            self.main_vm.is_just_showing = true
            
            self.main_vm.get_group_card_detail(card_idx: self.main_vm.selected_card_idx)
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onDisappear{
            print("-------------------------------상세 페이지 사라짐------------------------")
            //이렇게 해야 메인에서 다른 카드 상세 페이지 갈 때 데이터 중복 안됨.
            main_vm.my_card_detail_struct.creator!.idx = -1
            
            //카드 만들기에서 이값들을 초기화하면 지도 뷰로 이동했다가 다시 돌아갈경우 문제 발생해서 여기에서 없앰
//            self.main_vm.user_selected_tag_set.removeAll()
//            self.main_vm.user_selected_tag_list.removeAll()
//            self.main_vm.card_name = ""
//            self.main_vm.card_date = Date()
//            self.main_vm.card_time = Date()
//            self.main_vm.input_introduce = ""
        }
        // 이 알림이 띄워지는지 테스트해봐야함.
        .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
            print("모임카드 상세 데이터 통신 완료 노티 받음")
            
            if let user_info = value.userInfo, let data = user_info["get_group_card_detail_finish"]{
                print("친구카드 상세 데이터 통신 완료 받았음: \(data)")
                
                if data as! String == "no result"{
                    
                    self.show_no_result = true
                }else{
                    print("맵 데이터 상세페이지에서 확인: \(main_vm.map_data)")
                    if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                        
                        self.expiration_at = String.kor_date_string(date_string: self.main_vm.my_card_detail_struct.expiration_at!)
                        
                        self.meeting_time = String.msg_time_formatter(date_string: self.main_vm.my_card_detail_struct.expiration_at!)
                        
                    }else{
                        
                        self.expiration_at = String.kor_date_string(date_string: self.main_vm.card_detail_struct.expiration_at!)
                        self.meeting_time = String.msg_time_formatter(date_string: self.main_vm.card_detail_struct.expiration_at!)
                        
                    }
                    print("날짜 확인: \(self.expiration_at)")
                }
            }else{
                print("친구 메인에서 오늘 심심기간 설정 서버 통신 후 노티 응답 실패: .")
            }
        }
        //카드 상세 정보 가져왔을 때 no result인 경우 띄우는 알림창
        .alert(isPresented: self.$show_no_result, content: {
            Alert(title: Text("알림"), message: Text("찾을 수 없는 정보입니다."), dismissButton: .default(Text("확인"), action: {
                self.presentation.wrappedValue.dismiss()
            }))
        })
        .overlay(FriendStateDialog(main_vm: FriendVollehMainViewmodel(),group_main_vm: self.main_vm, show_friend_info: self.$show_creator_dialog, socket: SockMgr.socket_manager, state_on: self.$creator_state_on, is_friend : false, is_from_chatroom: false))
        }
    }
}

extension GroupVollehCardDetail{
    
    var accept_invitation_btn: some View{
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
            
            Text("참여하기")
                .font(.custom(Font.t_extra_bold, size: 15))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.proco_white)
                .background(Color.main_orange)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
        })
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: Notification.dynamic_link_move_view), perform: { value in
            print("참여 수락 완료 이벤트 받음: \(value)")
            
            if let user_info = value.userInfo, let check_result = user_info["dynamic_link_move_view"]{
                
                let kind = user_info["kind"]  as! String
                print("참여 수락 완료 이벤트 받음: \(check_result)")
                if kind == "친구"{
                    print("친구 카드에 초대한 경우 뷰 이동 노티 받음")
                    self.go_invited_room.toggle()
                    
                }else{
                    print("모임 카드에 초대한 경우 뷰 이동 노티 받음")
                    
                }
            }
        })
    }
    
    var apply_btn : some View{
        
        VStack{
            /*
             내가 만든 카드가 아닐 경우에만 참가 신청 버튼 보여주기
             - 캘린더에서 넘어온 경우에는 x
             드로어에서 넘어온 경우, 카드에 초대하기 버튼 클릭
             - 흐름: 동적링크 생성-> 메세지 보내기 이벤트
             - 주의 : 친구 채팅방 카드이므로 소켓 매니저 클래스의 which_type_room변수를 GROUP로 만들기.
             */
            
            if self.main_vm.my_nickname == self.main_vm.creator_name{
                Button(action: {
                    
                    socket_manager.which_type_room = "GROUP"
                    
                    let chatroom_idx = SockMgr.socket_manager.invite_chatroom_idx
                    print("모여볼래로 초대하려는 채팅방 idx: \(chatroom_idx), 카드 idx: \(main_vm.my_card_detail_struct.card_idx!)")
                    
                    //동적링크 생성 - kinds, card idx, chatroom idx
                    //                        SockMgr.socket_manager.make_dynamic_link(chatroom_idx: chatroom_idx, link_img: "tab.grp.fill", card_idx: main_vm.my_card_detail_struct.card_idx!, kinds: self.main_vm.my_card_detail_struct.kinds!)
                    
                    let meeting_date = self.main_vm.my_card_detail_struct.expiration_at
                    let converted_date = String.kor_date_string(date_string: meeting_date!)
                    let meeting_time = self.main_vm.my_card_detail_struct.expiration_at
                    let converted_time = String.time_to_kor_language(date: meeting_time!)
                    
                    SockMgr.socket_manager.make_invite_link(chatroom_idx: chatroom_idx, card_idx: main_vm.my_card_detail_struct.card_idx!, kinds: "친구", meeting_date: converted_date, meeting_time: converted_time)
                    
                    //본래의 일반 채팅방 화면으로 이동.
                    self.go_back_chatroom = true
                    print("go_back_chatroom: \(self.go_back_chatroom)")
                }){
                    Text("초대하기")
                        .padding()
                        .foregroundColor(Color.proco_white)
                        .frame(maxWidth: .infinity)
                }
            }else{
                Button(action: {
                    print("참가 신청 버튼 클릭")
                    self.main_vm.apply_group_card(card_idx: self.main_vm.selected_card_idx)
                    //참가 신청 확인 모달 띄우기
                     main_vm.result_alert(main_vm.alert_type)
                }){
                    
                    Text("참가 신청")
                        .font(.custom(Font.t_regular, size: 17))
                        .padding()
                        .foregroundColor(.proco_white)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.main_green)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                //.disabled(main_vm.appply_end)
            }
        }
    }
    var report_btn : some View{
        HStack{
            Spacer()
            
            Button(action: {
                print("신고하기 클릭")
                
                //kinds: 카드, unique_idx : 카드 idx, report_kinds: string, content
                //신고하기 모달창 띄우기
                self.show_report_view.toggle()
            }){
                HStack{
                    Image("report_icon")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                        .foregroundColor(Color.orange)
                        .background(Color.white)
                    Text("신고")
                        .font(.custom(Font.n_bold, size: 15))
                        .foregroundColor(.proco_black)
                }
            }
            .sheet(isPresented: self.$show_report_view) {
                ReportView(show_report: self.$show_report_view, type: "카드", selected_user_idx: -1, main_vm: FriendVollehMainViewmodel(), socket_manager: SockMgr(), group_main_vm: self.main_vm)
            }
        }
    }
    
    var card_category_and_title : some View{
        
        HStack{
            VStack{
                HStack{
                    if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                        
                        if main_vm.my_card_detail_struct.tags!.count > 0{
                            Capsule()
                                .foregroundColor(main_vm.my_card_detail_struct.tags![0].tag_name == "사교/인맥" ?  .proco_yellow : main_vm.my_card_detail_struct.tags![0].tag_name == "게임/오락" ? .proco_pink : main_vm.my_card_detail_struct.tags![0].tag_name == "문화/공연/축제" ? .proco_olive : main_vm.my_card_detail_struct.tags![0].tag_name == "운동/스포츠" ? .proco_green : main_vm.my_card_detail_struct.tags![0].tag_name == "취미/여가" ? .proco_mint : main_vm.my_card_detail_struct.tags![0].tag_name == "스터디" ? .proco_blue : .proco_red)
                                .frame(width: 100, height: 35)
                                .overlay(
                                    Text(main_vm.my_card_detail_struct.tags![0].tag_name)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .font(.custom(Font.t_extra_bold, size: 15))
                                        .foregroundColor(.proco_white)
                                )
                        }
                    }else{
                        if main_vm.card_detail_struct.tags!.count > 0{
                            Capsule()
                                .foregroundColor(main_vm.card_detail_struct.tags![0].tag_name == "사교/인맥" ?  .proco_yellow : main_vm.card_detail_struct.tags![0].tag_name == "게임/오락" ? .proco_pink : main_vm.card_detail_struct.tags![0].tag_name == "문화/공연/축제" ? .proco_olive : main_vm.card_detail_struct.tags![0].tag_name == "운동/스포츠" ? .proco_green : main_vm.card_detail_struct.tags![0].tag_name == "취미/여가" ? .proco_mint : main_vm.card_detail_struct.tags![0].tag_name == "스터디" ? .proco_blue : .proco_red)
                                .frame(width: 110, height: 50)
                                .overlay(
                                    Text(main_vm.card_detail_struct.tags![0].tag_name)
                                        .font(.custom(Font.t_extra_bold, size: 15))
                                        .foregroundColor(.proco_white)
                                        .padding(.trailing, UIScreen.main.bounds.width/60) )
                        }
                    }
                    Spacer()
                }
                .padding(.leading)
                
                HStack{
                    //내 카드인 경우
                    if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                        
                        Text("\(main_vm.my_card_detail_struct.title!)")
                            .font(.custom(Font.n_bold, size: 22))
                            .foregroundColor(Color.proco_black)
                    }else{
                        Text("\(main_vm.card_detail_struct.title!)")
                            .font(.custom(Font.n_bold, size: 22))
                            .foregroundColor(Color.proco_black)
                    }
                    Spacer()
                }
                .padding(.leading)
            }
        }
    }
    
    var card_like : some View{
        VStack{
            Spacer()
            HStack{
                Button(action: {
                    
                    //내 카드인 경우
                    if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                        if self.main_vm.my_card_detail_struct.like_state == 0{
                            
                            print("모임 카드 좋아요 클릭")
                            self.main_vm.send_like_card(card_idx: self.main_vm.my_card_detail_struct.card_idx!)
                            
                        }else{
                            print("모임 카드 좋아요 취소")
                            self.main_vm.cancel_like_card(card_idx: self.main_vm.my_card_detail_struct.card_idx!)
                        }
                        //다른 사람 카드인 경우
                    }else{
                        if self.main_vm.card_detail_struct.like_state == 0{
                            
                            print("모임 카드 좋아요 클릭")
                            self.main_vm.send_like_card(card_idx: self.main_vm.card_detail_struct.card_idx!)
                            
                        }else{
                            print("모임 카드 좋아요 취소")
                            self.main_vm.cancel_like_card(card_idx: self.main_vm.card_detail_struct.card_idx!)
                        }
                    }
                    
                }){
                    HStack{
                    //내 카드인 경우
                    if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                        
                        Image(main_vm.my_card_detail_struct.like_state == 0 ? "heart" : "heart_fill")
                            .resizable()
                            .frame(width: 20, height: 18)
                        
                    }else{
                        Image(main_vm.card_detail_struct.like_state == 0 ? "heart" : "heart_fill")
                            .resizable()
                            .frame(width: 20, height: 18)
                    }
                        if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                            
                            Text( self.main_vm.my_card_detail_struct.like_count ?? 0 > 0 ? "좋아요\(main_vm.my_card_detail_struct.like_count!)" : "")
                                .font(.custom(Font.n_extra_bold, size: 10))
                                .foregroundColor(Color.proco_black)
                            
                        }else{
                            Text( self.main_vm.card_detail_struct.like_count ?? 0 > 0 ? "좋아요\(main_vm.card_detail_struct.like_count!)" : "")
                                .font(.custom(Font.n_extra_bold, size: 10))
                                .foregroundColor(Color.proco_black)
                            
                        }
                    }
                }
            }
            Spacer()
            
        }
        .padding([.leading, .bottom])
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("내 카드 좋아요 클릭 통신 완료 받음.: \(value)")
            
            if let user_info = value.userInfo{
                let check_result = user_info["clicked_like"]
                print("내 카드 좋아요 데이터 확인: \(check_result)")
                
                if check_result as! String == "ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("카드 좋아요 클릭한 idx: \(card_idx)")
                    
                    var clicked_card : Bool = false
                    //내 카드에 좋아요 클릭한건지 확인
                    clicked_card =  self.main_vm.my_card_detail_struct.card_idx == card_idx
                    
                    if clicked_card {
                        self.main_vm.my_card_detail_struct.like_count! += 1
                        self.main_vm.my_card_detail_struct.like_state = 1
                        //친구 카드를 좋아요 클릭한 경우
                    }else{
                        
                        self.main_vm.card_detail_struct.like_count! += 1
                        self.main_vm.card_detail_struct.like_state = 1
                    }
                    
                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    var clicked_card : Bool = false
                    //내 카드에 좋아요 클릭한건지 확인
                    clicked_card =  self.main_vm.my_card_detail_struct.card_idx == card_idx
                    
                    if clicked_card {
                        self.main_vm.my_card_detail_struct.like_count! -= 1
                        self.main_vm.my_card_detail_struct.like_state = 0
                        //친구 카드를 좋아요 클릭한 경우
                    }else{
                        
                        self.main_vm.card_detail_struct.like_count! -= 1
                        self.main_vm.card_detail_struct.like_state = 0
                    }
                }
            }
        })
    }
    
    var card_tags : some View{
        HStack{
            
            ForEach(main_vm.user_selected_tag_list.indices, id: \.self){ index in
                if index == 0{
                    
                }else{
                    HStack{
                        Image("tag_sharp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                        
                        Text("\(main_vm.user_selected_tag_list[index])")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(.proco_black)
                            .padding([.trailing], UIScreen.main.bounds.width/20)
                    }
                }
            }
            Spacer()
        }
        .padding(.leading)
    }
    
    var host_info : some View{
        
        HStack{
            
            //내 카드인 경우
            if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                HStack{
                    //내 프로필
                    if main_vm.my_card_detail_struct.creator?.profile_photo_path  == "" || main_vm.my_card_detail_struct.creator?.profile_photo_path == nil{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                            .cornerRadius(50)
                            .scaledToFit()
                            .padding([.leading], UIScreen.main.bounds.width/30)
                        
                    }else{
                        
                        KFImage(URL(string: (self.main_vm.my_card_detail_struct.creator?.profile_photo_path!)!))
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
                    
                    VStack{
                        Text("주최자")
                            .font(.custom(Font.t_regular, size: 10))
                            .foregroundColor(.proco_black)
                        
                        
                        Text("\(main_vm.my_card_detail_struct.creator!.nickname)")
                            .font(.custom(Font.t_regular, size: 16))
                            .foregroundColor(.proco_black)
                    }
                    Spacer()
                    Text(main_vm.my_card_detail_struct.creator_attend_count ?? 0 > 0 ? "프로코 모임을 \(main_vm.my_card_detail_struct.creator_attend_count!)회 참여해봤어요!" : "모임 주최 스타트")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.proco_black)
                    
                }
            }else{
                HStack{
                    //내 프로필
                    Image(main_vm.card_detail_struct.creator?.profile_photo_path == "" || main_vm.my_card_detail_struct.creator?.profile_photo_path == nil ? "main_profile_img" : main_vm.my_card_detail_struct.creator?.profile_photo_path! as! String)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .cornerRadius(50)
                        .scaledToFit()
                        .padding([.leading], UIScreen.main.bounds.width/30)
                    
                    VStack{
                        Text("주최자")
                            .font(.custom(Font.t_regular, size: 10))
                            .foregroundColor(.proco_black)
                        
                        
                        Text("\(main_vm.card_detail_struct.creator!.nickname)")
                            .font(.custom(Font.t_regular, size: 16))
                            .foregroundColor(.proco_black)
                    }
                    Spacer()
                    Text(main_vm.card_detail_struct.creator_attend_count ?? 0 > 0 ? "프로코 모임을 \(main_vm.card_detail_struct.creator_attend_count!)회 참여해봤어요!" : "모임 주최 스타트")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.proco_black)
                        .padding(.trailing)
                }
            }
        }
        .padding(.trailing)
        .onTapGesture {
            
            self.main_vm.creator_info.nickname! = main_vm.card_detail_struct.creator!.nickname
            self.main_vm.creator_info.profile_photo_path! = main_vm.card_detail_struct.creator?.profile_photo_path ?? ""
            self.main_vm.creator_info.idx = main_vm.card_detail_struct.creator!.idx
            
            //주최자 프로필 다이얼로그 띄우는 것
            self.show_creator_dialog = true
        }
    }
    
    var meeting_introduce : some View{
        VStack(alignment: .leading){
            HStack{
                Text("모임 소개")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                
                Spacer()
            }
            .padding(.bottom)
            
            //내 카드인 경우
            if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                
                Text("\(self.main_vm.my_card_detail_struct.introduce ?? "")")
                    .font(.custom(Font.n_bold, size: 13))
                    .foregroundColor(Color.proco_black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                //.background(Color.gray.opacity(0.5))
            }else{
                
                Text("\(self.main_vm.card_detail_struct.introduce ?? "")")
                    .font(.custom(Font.n_bold, size: 13))
                    .foregroundColor(Color.proco_black)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                //.background(Color.gray.opacity(0.5))
                
            }
        }
        .padding([.leading, .top])
    }
    
    var date_view : some View{
        HStack{
            Text("날짜")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)
                .padding(.leading)
            
            Spacer()
            
            Text("\(self.expiration_at)")
                .font(.custom(Font.n_bold, size: 17))
                .foregroundColor(.proco_black)
        }
        .padding([.bottom, .top])
    }
    
    var time_view : some View{
        HStack{
            Text("시간")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)
                .padding(.leading)
            
            Spacer()
            
            Text("\(self.meeting_time)")
                .font(.custom(Font.n_bold, size: 17))
                .foregroundColor(.proco_black)
        }
        .padding([.bottom])
    }
    
    var apply_people_list_title : some View{
        
        HStack{
            Text("신청자 / 참여자 목록")
                .font(.custom(Font.t_extra_bold, size: 16))
                .foregroundColor(.proco_black)
                .padding(.leading)
            
            Spacer()
            
            Image("right")
                .resizable()
                .frame(width:7.64, height: 15.27 )
        }
        .padding([.trailing, .bottom])
        
    }
    
    var location : some View{
        VStack{
            HStack{
                Text("장소")
                    .font(.custom(Font.t_extra_bold, size: 16))
                    .foregroundColor(.proco_black)
                    .padding(.leading)
                Spacer()
            }
            HStack{
                Image("marker_icon")
                    .resizable()
                    .frame(width: 16, height: 19)
                    .padding(.leading)
                //내 카드인 경우
                if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                    Text("\(main_vm.my_card_detail_struct.address!)")
                        .font(.custom(Font.n_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                }else{
                    Text("\(main_vm.card_detail_struct.address!)")
                        .font(.custom(Font.n_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                }
                Spacer()
            }
            
            Rectangle()
                .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*0.5, alignment: .center)
                .foregroundColor(Color.gray)
                .overlay(MyWebView(vm: self.main_vm, url: "https://withproco.com/map/map.html?device=ios"))
                .onTapGesture {
                    //큰 지도 뷰 띄우기
                    self.show_location_detail = true
                }
            
//            NavigationLink("",destination: MapDetailInfoView(vm: self.main_vm), isActive: self.$show_location_detail)
        }
    }
    
    var proco_rules : some View{
        VStack{
            Group{
            HStack{
                Text("프로코 이용 규칙")
                    .font(.custom(Font.n_extra_bold, size: 20))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding([.leading, .bottom])
            
            HStack{
                Text("프로코에서 다음 사항은 금지됩니다.")
                    .font(.custom(Font.n_extra_bold, size: 11))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding([.leading, .bottom])
            
            HStack{
                Text("위반 시 제재를 받을 수 있습니다(영구정지 또는 서비스 이용제한)")
                    .font(.custom(Font.n_bold, size: 11))
                    .foregroundColor(.proco_black)
                Spacer()
            }
            .padding([.leading, .bottom])
            }
            HStack{
                Rectangle()
                    .foregroundColor(.main_green)
                    .frame(width: UIScreen.main.bounds.width*0.35, height: UIScreen.main.bounds.width/17)
                    .overlay(
                        Text("성적인 주제의 대화, 성드립")
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: 11))
                    )
                Spacer()
            }
            .padding(.leading)
            
            HStack{
                Rectangle()
                    .foregroundColor(.main_green)
                    .frame(width: UIScreen.main.bounds.width*0.49, height: UIScreen.main.bounds.width/20)
                    .overlay(
                        Text("불쾌감을 줄 수 있는 사진이나 닉네임 사용")
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: 10))
                    )
                Spacer()
            }
            .padding(.leading)
            
            HStack{
                Rectangle()
                    .foregroundColor(.main_green)
                    .frame(width: UIScreen.main.bounds.width*0.42, height: UIScreen.main.bounds.width/20)
                    .overlay(
                        Text("모임의 목적 또는 주제와 무관한 행동")
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: 10))
                    )
                Spacer()
            }
            .padding(.leading)
            
            HStack{
                Rectangle()
                    .foregroundColor(.main_green)
                    .frame(width: UIScreen.main.bounds.width*0.14, height: UIScreen.main.bounds.width/20)
                    .overlay(
                        Text("욕설 및 비방")
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: 10))
                    )
                Spacer()
            }
            .padding(.leading)
            
            HStack{
                Rectangle()
                    .foregroundColor(.main_green)
                    .frame(width: UIScreen.main.bounds.width*0.12, height: UIScreen.main.bounds.width/20)
                    .overlay(
                        Text("무단 불참")
                            .foregroundColor(.proco_white)
                            .font(.custom(Font.n_bold, size: 10))
                    )
                Spacer()
            }
            .padding([.leading, .bottom])
            
            HStack{
                Text("자세한 내용은 프로코 이용규칙을 확인해주세요")
                    .foregroundColor(.proco_black)
                    .font(.custom(Font.n_bold, size: 10))
                
                Spacer()
            }
            .padding([.leading, .bottom])
            
            HStack{
                
                Button(action: {
                    print("이용규칙 웹뷰 보기 클릭")
                    self.show_proco_rules = true
                }){
                    Text("프로코 이용규칙")
                        .foregroundColor(.proco_black)
                        .font(.custom(Font.n_extra_bold, size: 14))
                }
            }
                Spacer()
            }
            .padding([.leading, .bottom])
        }
    }




