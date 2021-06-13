//
//  FriendVollehCardDetail.swift
//  proco
//
//  Created by 이은호 on 2021/01/20.
// 상세페이지 데이터 모델 : 나, 친구 상관 없이 friend_volleh_card_detail

import SwiftUI
import Kingfisher
import SwiftyJSON

struct FriendVollehCardDetail: View {
    @Environment(\.presentationMode) var presentation
    
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    @StateObject var main_vm: FriendVollehMainViewmodel
    @ObservedObject var group_main_vm: GroupVollehMainViewmodel
    
    @ObservedObject var socket : SockMgr
    //일대일 채팅하기 화면 이동 구분값
    @State private var go_to_chat: Bool = false
    //드로어에서 카드 수정하기 화면으로 이동.
    @State private var go_edit_from_chat: Bool = false
    //메인 친구랑 볼래에서 카드 수정하기 화면으로 이동.
    @State private var go_edit_from_main: Bool = false
    //1.21추가한 것.
    @State var volleh_category_struct = VollehTagCategoryStruct()
    @State private var go_back_chatroom: Bool = false
    
    @ObservedObject var calendar_vm: CalendarViewModel
    
    //신고하기 버튼 클릭시 나타나는 모달창 띄우는데 사용하는 구분값
    @State private var show_report_view = false
    
    //내가 좋아요를 클릭했는지 여부
    @State private var clicked_like  = false
    //좋아요한 사람들 목록 뷰로 이동
    @State private var go_like_people_list = false
    @State private var expiration_at = ""
    
    //피드 페이지로 이동
    @State private var go_to_feed : Bool = false
    
    //동적링크에서 들어온 경우 참여하기 이벤트 통신 후 채팅방으로 이동시켜야 함.
    @State private var go_invited_room : Bool = false
    @State private var no_result_alert : Bool = false
    
    var body: some View{
        
        VStack{
            top_nav_bar
            //약속날짜
            HStack{
                Spacer()
                card_meeting_day
            }
            Spacer()
            Group{
                //카드 주인의 프로필 사진, 이름
                owner_profile
                HStack{
                    category_tag
                    //현재 카드에 참가한 유저 수
                    cur_user
                }
                //태그
                HStack{
                    Spacer()
                    ForEach(self.main_vm.user_selected_tag_list.indices, id: \.self){tag in
                        //index 0태그는 카테고리이므로 빼고 보여준다.
                        if tag == 0{
                            
                        }else{
                            HStack{
                                Image("tag_sharp")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                
                                Text("\(self.main_vm.user_selected_tag_list[tag])")
                                    .font(.custom(Font.n_bold, size: 15))
                                    .foregroundColor(.proco_black)
                            }
                        }
                    }
                    Spacer()
                }
                
                //좋아요
                HStack{
                    Spacer()
                    like_icon
                    Spacer()
                }
                Spacer()
            }
            
            //동적링크를 통해 초대된 채팅방으로 이동
            NavigationLink("",destination: ChatFriendRoomView(socket: socket).navigationBarHidden(true)
                            .navigationBarTitle(""), isActive: self.$go_invited_room)
            
            //친구 카드 주인과 1대1 채팅방 화면으로 이동.
            NavigationLink("",
                           destination: NormalChatRoom(main_vm:  self.main_vm,group_main_vm: self.group_main_vm,socket: SockMgr.socket_manager).navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true),
                           isActive: self.$go_to_chat)
            
            //드로어에서 카드 상세 페이지 -> 카드 수정 화면 이동
            NavigationLink("",
                           destination: EditCardView(main_viewmodel: self.main_vm, tag_category_struct: volleh_category_struct ).navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true),
                           isActive: self.$go_edit_from_chat)
            
            //메인에서 카드 상세 페이지 -> 카드 수정 화면 이동
            NavigationLink("",
                           destination: EditCardView(main_viewmodel: self.main_vm, tag_category_struct: volleh_category_struct ).navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true),
                           isActive: self.$go_edit_from_main)
            //피드 페이지 이동
            NavigationLink("",destination: SimSimFeedPage(main_vm: self.calendar_vm), isActive: self.$go_to_feed)
            Group{
                //캘린더에서 넘어온 경우에는 채팅, 피드 버튼이 보이지 않음.
                if calendar_vm.from_calendar{
                }
                //동적링크를 통해 들어온 경우 참여하기 버튼.
                else if socket.is_dynamic_link{
                    accept_invitaion_btn
                }
                else{
                    HStack{
                        //확인 버튼 클릭 - 일반 채팅방으로 돌아감
                        NavigationLink("",destination: NormalChatRoom(main_vm: self.main_vm, group_main_vm: self.group_main_vm,socket: SockMgr.socket_manager).navigationBarHidden(true).navigationBarTitle("", displayMode: .inline), isActive: self.$go_back_chatroom)
                        /*
                         드로어에서 넘어온 경우, 카드에 초대하기 버튼 클릭
                         - 흐름: 동적링크 생성-> 메세지 보내기 이벤트
                         - 주의 : 친구 채팅방 카드이므로 소켓 매니저 클래스의 which_type_room변수를 FRIEND로 만들기.
                         */
                        if socket.detail_to_invite{
                            invite_btn
                            
                        }else{
                            bottom_menu_btns
                        }
                    }
                    .padding()
                }
            }
        }.padding()
        .sheet(isPresented:self.$go_like_people_list){
            LikePeopleListView(card_idx: self.main_vm.selected_card_idx, main_vm: self.main_vm)
        }
        .onAppear{
            print("-----------------친구랑 볼래 카드 상세 화면 카드 idx:\(main_vm.selected_card_idx) , 동적링크인지 여부 : \(socket.is_dynamic_link)")
        
            //동적링크의 경우 뷰모델에 카드 idx저장이 안돼서 소켓매니저 클래스에 저장해놓음.
            if socket.is_dynamic_link{
                print("동적링크에서 상세페이지로 들어온 경우")
                self.main_vm.selected_card_idx = self.socket.selected_card_idx
            }
            
            self.main_vm.get_card_detail(card_idx: self.main_vm.selected_card_idx)
            print("친구 데이터 확인: \(main_vm.friend_info_struct)")
            
        }
        .onDisappear{
            print("-------------------친구랑 볼래 카드 상세 화면 사라짐--------------------")
            //이렇게 해야 메인에서 다른 카드 상세 페이지 갈 때 데이터 중복 안됨.
            main_vm.my_card_detail_struct.creator!.idx = -1
            
            //채팅방에서 상세 페이지로 넘어온 경우 true값으로 이 페이지로 들어왔으므로 나갈 때 다시 초기화.
            //여기에서 하면 오류 남.
            //socket.is_from_chatroom = false
            
            //친구 내 카드에 초대하기 -> 상세 페이지로 이동해온 경우 다시 초기화
            socket.detail_to_invite = false
            
            //캘린더에서 넘어온 경우 true로 해줬던 값 다시 바꿔주기
            calendar_vm.from_calendar = false
        }
        //카드 상세 정보 가져왔을 때 no result인 경우 띄우는 알림창
        .alert(isPresented: self.$no_result_alert, content: {
            Alert(title: Text("알림"), message: Text("찾을 수 없는 정보입니다."), dismissButton: .default(Text("확인")))
        })
        .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
            print("친구카드 상세 데이터 통신 완료 노티 받음")
            if let user_info = value.userInfo, let data = user_info["get_friend_card_detail_finish"]{
                print("친구카드 상세 데이터 통신 완료 받았음: \(data)")
                
                if data as! String == "no result"{
                    print("해당 카드 없거나 만료된 카드인 경우")
                    //알림 띄우기
                    self.no_result_alert = true
                }else{
                self.expiration_at = String.dot_form_date_string(date_string: data as! String)
                print("날짜 확인: \(self.expiration_at)")
                }
            }else{
                print("친구 메인에서 오늘 심심기간 설정 서버 통신 후 노티 응답 실패: .")
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


private extension FriendVollehCardDetail{
    
    var accept_invitaion_btn: some View{
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
    
    var invite_btn : some View{
        Button(action: {
            
            SockMgr.socket_manager.which_type_room = "FRIEND"
            ChatDataManager.shared.get_card_by_card_idx(card_idx: main_vm.friend_volleh_card_detail.card_idx!)
            print("채팅방 idx: \(socket.invite_chatroom_idx)")
            print("채팅방 idx2: \(socket_manager.invite_chatroom_idx)")
            print("채팅방 idx3: \(SockMgr.socket_manager.invite_chatroom_idx)")
            print("원래 있던 채팅방 idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
            print("원래 있던 채팅방 idx2: \(socket_manager.enter_chatroom_idx)")
            print("원래 있던 채팅방 idx3: \(socket.enter_chatroom_idx)")
            
            let chatroom_idx = SockMgr.socket_manager.invite_chatroom_idx
            let meeting_date = self.main_vm.friend_volleh_card_detail.expiration_at
            let converted_date = String.kor_date_string(date_string: meeting_date)
            let meeting_time = self.main_vm.friend_volleh_card_detail.expiration_at
            let converted_time = String.time_to_kor_language(date: meeting_time)
            
            print("초대하려는 채팅방 idx: \(chatroom_idx), 카드idx: \(self.main_vm.friend_volleh_card_detail.card_idx!)")
            
            //동적링크 생성
//            SockMgr.socket_manager.make_dynamic_link(chatroom_idx: chatroom_idx, link_img: nil, card_idx: self.main_vm.friend_volleh_card_detail.card_idx!, kinds: "친구")
            SockMgr.socket_manager.make_invite_link(chatroom_idx: chatroom_idx, card_idx: self.main_vm.friend_volleh_card_detail.card_idx!, kinds: "친구", meeting_date: converted_date, meeting_time: converted_time)
            
            //본래의 채팅방 화면으로 이동.
            self.go_back_chatroom.toggle()
        }){
            Text("초대하기")
                .font(.custom(Font.t_extra_bold, size: 15))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.proco_white)
                .background(Color.main_orange)
                .cornerRadius(25)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
        }
    }
    var bottom_menu_btns : some View{
        HStack{
            Button(action: {
                //캘린더를 보려는 사람의 idx = 내 idx 저장.
                calendar_vm.calendar_owner.watch_user_idx = Int(main_vm.my_idx!)!
                
                print("친구 idx 확인: \(main_vm.friend_info_struct)")
                SimSimFeedPage.calendar_owner_idx = main_vm.friend_volleh_card_detail.creator.idx
                self.go_to_feed.toggle()
            }){
                
                HStack{
                    Image("profile_feed_icon")
                        .resizable()
                        .frame(width: 19, height: 21)
                    
                    Text("심심풀이 보기")
                        .foregroundColor(Color.proco_black)
                        .font(.custom(Font.t_extra_bold, size: 17))
                }
            }
            .padding(.all, UIScreen.main.bounds.width/20)
            Spacer()
            //카드 주인과 채팅하기
            Button(action: {
                
                print("일대일 채팅하기 클릭 내 idx: \(Int(main_vm.my_idx!)!)")
                print("일대일 채팅하기 클릭 친구 idx: \(String(describing: main_vm.friend_volleh_card_detail.creator.idx))")
                //채팅하려는 친구의 idx값 저장해두기
                socket.temp_chat_friend_model = UserChatInListModel(idx: main_vm.friend_volleh_card_detail.creator.idx, nickname: main_vm.friend_volleh_card_detail.creator.nickname, profile_photo_path: main_vm.friend_volleh_card_detail.creator.profile_photo_path ?? "")
                
                //일대일 채팅방이 기존에 존재했는지 확인하는 쿼리문
                ChatDataManager.shared.check_chat_already(my_idx: Int(main_vm.my_idx!)!, friend_idx: main_vm.friend_volleh_card_detail.creator.idx!)
                
                self.go_to_chat.toggle()
                
            }){
                HStack{
                    Image("dialog_chat_icon")
                        .resizable()
                        .frame(width: 22 , height: 19)
                    Text("채팅하기")
                        .foregroundColor(Color.proco_black)
                        .font(.custom(Font.t_extra_bold, size: 17))
                }
            }
            .padding(.all, UIScreen.main.bounds.width/20)
        }
        .padding(.bottom, UIScreen.main.bounds.width/30)
    }
    var category_tag : some View{
        HStack{
            if self.main_vm.user_selected_tag_list.count > 0{
            Capsule()
                .foregroundColor(self.main_vm.user_selected_tag_list[0] == "사교/인맥" ? .proco_yellow : self.main_vm.user_selected_tag_list[0] == "게임/오락" ? .proco_pink : self.main_vm.user_selected_tag_list[0] == "문화/공연/축제" ? .proco_olive : self.main_vm.user_selected_tag_list[0] == "운동/스포츠" ? .proco_green : self.main_vm.user_selected_tag_list[0] == "취미/여가" ? .proco_mint : self.main_vm.user_selected_tag_list[0] == "스터디" ? .proco_blue : .proco_red)
                .frame(width: 76, height: 26)
                .overlay(
                    
                    Text("\(self.main_vm.user_selected_tag_list[0])")
                        .font(.custom(Font.n_bold, size: 15))
                        .foregroundColor(.proco_white)
                )}
        }
    }
    
    var cur_user : some View{
        HStack{
            Image("cur_user_icon")
                .resizable()
                .frame(width: 15, height: 16)
            Text(self.main_vm.friend_volleh_card_detail.cur_user == 0 ? "" : "\(self.main_vm.friend_volleh_card_detail.cur_user)명")
        }
    }
    
    var send_report_btn : some View{
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
    }
    
    var like_icon : some View{
        
        HStack{
            Button(action: {
                
                //좋아요 클릭 이벤트
                if self.main_vm.friend_volleh_card_detail.like_state == 0{
                    //좋아요 클릭 이벤트
                    print("좋아요 클릭: \(String(describing: self.main_vm.friend_volleh_card_detail.like_state))")
                    
                    self.main_vm.send_like_card(card_idx: self.main_vm.friend_volleh_card_detail.card_idx!)
                    
                }else{
                    print("좋아요 취소")
                    
                    self.main_vm.cancel_like_card(card_idx: self.main_vm.friend_volleh_card_detail.card_idx!)
                }
            }){
                
                Image(self.main_vm.friend_volleh_card_detail.like_state == 1 ? "heart_fill" : "heart")
                    .resizable()
                    .frame(width: 18, height:16)
                    .padding([.leading], UIScreen.main.bounds.width/20)
            }
            Button(action: {
                let card_idx = main_vm.friend_volleh_card_detail.card_idx
                self.main_vm.get_like_card_users(card_idx: card_idx!)
                print("좋아요 목록 보기 클릭.")
                self.go_like_people_list.toggle()
            }){
                HStack{
                    Text(self.main_vm.friend_volleh_card_detail.like_count > 0 ? "좋아요\(self.main_vm.friend_volleh_card_detail.like_count)개" : "")
                        .font(.custom(Font.n_extra_bold, size: 10))
                        .foregroundColor(Color.proco_black)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("좋아요 클릭 통신 완료 받음.: \(value)")
            if let user_info = value.userInfo, let check_result = user_info["clicked_like"]{
                print("좋아요 결과 받음: \(check_result)")
                if check_result as! String == "ok"{
                    
                    self.main_vm.friend_volleh_card_detail.like_state = 1
                    self.main_vm.friend_volleh_card_detail.like_count += 1
                    
                }else if check_result as! String == "canceled_ok"{
                    
                    self.main_vm.friend_volleh_card_detail.like_state = 0
                    self.main_vm.friend_volleh_card_detail.like_count -= 1
                    
                }
            }
        })
        
    }
    
    var top_nav_bar : some View{
        
        HStack{
            //돌아가기 버튼.
            Image("card_dialog_close_icon")
                .padding()
                .onTapGesture {
                    withAnimation{
                        self.presentation.wrappedValue.dismiss()
                    }
                }
            Spacer()
            Text("")
            Spacer()
            //TODO 채팅방 드로어에서 넘어온 경우, 메인에서 넘어온 경우 사용하는 데이터 모델이 다름.그래서 경우 나눔.
            //카드를 만든 사람에게만 보이는 수정 버튼. 클릭시 수정하는 화면으로 이동.
            //1.메인에서 넘어온 경우
            if self.main_vm.friend_volleh_card_detail.creator.idx! == Int(self.main_vm.my_idx!){
                Button(action: {
                    
                    self.main_vm.selected_card_idx =  main_vm.friend_volleh_card_detail.card_idx!
                    print("메인에서 상세 페이지로 들어온 후 카드 정보 수정하기 이동. card idx: \(self.main_vm.selected_card_idx)")
                    
                    self.main_vm.get_card_detail(card_idx: self.main_vm.selected_card_idx)
                    
                    self.go_edit_from_main.toggle()
                    
                }){
                    Image("pencil")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                }
            }
            send_report_btn
                .sheet(isPresented: self.$show_report_view) {
                    ReportView(show_report: self.$show_report_view, type: "카드", selected_user_idx: -1, main_vm: self.main_vm, socket_manager: SockMgr(), group_main_vm: GroupVollehMainViewmodel())
                }
        }
    }
    
    var owner_profile : some View{
        VStack{
            //1.메인에서 넘어온 경우
            // - 내 카드를 볼 경우
            if main_vm.my_card_detail_struct.creator!.idx! == Int(main_vm.my_idx!){
                
                if self.main_vm.friend_volleh_card_detail.creator.profile_photo_path == "" || self.main_vm.friend_volleh_card_detail.creator.profile_photo_path == nil{
                    
                    Image("main_profile_img")
                        .padding()
                    
                }  else{
                    
                    KFImage(URL(string: self.main_vm.friend_volleh_card_detail.creator.profile_photo_path!))
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
                Text(self.main_vm.my_card_detail_struct.creator!.nickname)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
            }
            //1.메인에서 넘어온 경우 - 다른 사람이 카드를 볼 경우
            else{
                HStack{
                    Spacer()
                  
                if main_vm.friend_volleh_card_detail.creator.profile_photo_path == "" || main_vm.friend_volleh_card_detail.creator.profile_photo_path == nil {
                    Image("main_profile_img")
                        .resizable()
                        .frame(width: 75, height: 75)
                }else{
                    Image((self.main_vm.friend_volleh_card_detail.creator.profile_photo_path!))
                        .resizable()
                        .frame(width: 75, height: 75)
                }
                    Spacer()
                }
                HStack{
                Text(self.main_vm.friend_volleh_card_detail.creator.nickname)
                    .font(.custom(Font.n_bold, size: 17))
                    .foregroundColor(.proco_black)
                    Button(action: {
                        
                        if self.main_vm.friend_volleh_card_detail.is_favor_friend == 0{
                            self.main_vm.set_interest_friend(f_idx: self.main_vm.friend_volleh_card_detail.creator.idx, action: "관심친구")
                        print("관심친구 아이콘 클릭")
                        }else{
                            self.main_vm.set_interest_friend(f_idx: self.main_vm.friend_volleh_card_detail.creator.idx, action: "관심친구해제")
                        }
                        print("관심친구 아이콘 클릭")
                        
                    }){
                    Image(self.main_vm.friend_volleh_card_detail.is_favor_friend == 1 ? "star_fill" : "star")
                        .resizable()
                        .frame(width: 12, height: 12)
                    }
                    .onReceive(NotificationCenter.default.publisher(for: Notification.set_interest_friend), perform: {value in
                        
                        print("관심친구 설정 완료 노티 받음")
                        if let user_info = value.userInfo, let check_result = user_info["set_interest_friend"]{
                            print("알림 설정 결과 받음: \(check_result)")
                            if check_result as! String == "set_ok_관심친구"{
                                  self.main_vm.friend_volleh_card_detail.is_favor_friend = 1
                            }else if check_result as! String == "set_ok_관심친구해제"{
                                
                                self.main_vm.friend_volleh_card_detail.is_favor_friend = 0
                                
                            }
                        }
                    })
                }
            }
            
            
        }
    }
    
    var card_meeting_day : some View{
        Image("card_label_orange")
            .resizable()
            .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/14)
            .overlay(
                
                //카드 만료일
                Text("\(self.expiration_at)")
                    .font(.custom(Font.n_extra_bold, size: 15))
                    .foregroundColor(.proco_white)
                
            )
    }
    
}
