//
//  friend_volleh_main_view.swift
//  proco
//
//  Created by 이은호 on 2020/11/15.
//

import SwiftUI
import Combine
import UserNotifications
import Kingfisher

struct FriendVollehMainView: View {
    
    //필터 버튼 클릭시 나오는 모달창 구분값
    @State private var show_filter_modal = false
    @ObservedObject var main_vm = FriendVollehMainViewmodel()
    @State var volleh_category_struct = VollehTagCategoryStruct()
    
    //카드 만들기 페이지로 이동시 사용하는 값.
    @State private var go_to_make_card : Bool = false
    //카드 편집 페이지로 이동시 사용하는 값.
    @State private var go_to_edit : Bool = false
    
    //카드 삭제 버튼 클릭시 한 번 더 알림창 보여주기 위함.
    @State private var show_delete_alert : Bool = false
    //카드 상세 페이지 이동
    @State private var go_to_my_detail : Bool = false
    //내 카드 1개 클릭시 나타나는 다이얼로그
    @State var show_card_dialog: Bool = false
    //친구 카드 1개 클릭시 나타나는 다이얼로그
    @State var show_friend_card_detail : Bool = false
    //친구 리스트 열고 닫는데 구분값
    @State var open_friend : Bool = false
    //친구 상태 리스트중 1개 클릭시 나타나는 다이얼로그
    @State private var friend_info_dialog : Bool = false
    
    //온오프 버튼 구분위함
    @State private var state_on : Int? = 0
    
    //캘린더에서 카드 상세페이지로 이동시 필요했음.
    @StateObject var calendar_vm = CalendarViewModel()
    
    //심심기간으로 오늘 설정하기 버튼 클릭시 alert창 띄우는데 사용.
    @State private var set_boring_today_alert = false
    
    //오늘 심심기간인지 아닌지 구분 변수
    @State  private var today_is_boring = false
    //disclosure group 내 카드, 친구 카드 open여부
    @State private var open_my_cards : Bool = true
    @State private var open_friend_cards: Bool = true
    
    //내 프로필 사진
    @State private var my_photo_path : String = ""
    
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 40, height: 40)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View {
        VStack{
            TopNavBar(page_name: "친구")
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    //프로필 사진, 심심기간 설정 버튼, 카드 만들기 버튼
                    user_info_view
                    
                    
                    //필터 버튼
                    filter_btn
                    HStack{
                        //내 카드 리스트 나오기 시작
                        Text("오늘 심심한 친구\(self.main_vm.today_boring_friends_model.count)명")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(.proco_black)
                    }
                    .padding(.bottom, UIScreen.main.bounds.width/20)
                    HStack{
                        boring_friends_list
                    }
                    //수정 하는 페이지로 이동하는 토글 값이 true일 때 navigationlink이용해 페이지 이동
                    NavigationLink("",destination: EditCardView(main_viewmodel: self.main_vm, tag_category_struct: self.volleh_category_struct), isActive: self.$go_to_edit)
                    
                    DisclosureGroup(isExpanded:$open_my_cards, content: {
                        ForEach(self.main_vm.my_friend_volleh_card_struct){ item in
                            ZStack{
                                // 1. hstack 버튼들 배경
                                Group{
                                    HStack{
                                        Spacer()
                                        //오른쪽으로 스와이프시 빨간색 배경, 주황색 배경
                                        HStack{
                                            Color.proco_red
                                                .frame(width: UIScreen.main.bounds.width*0.3)
                                                .opacity(main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset ?? 0 < 0 ? 1 : 0)
                                            
                                            Color.main_orange
                                                .frame(width: UIScreen.main.bounds.width*0.3)
                                                .opacity(main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset ?? 0 < 0 ? 1 : 0)
                                        }
                                    }
                                }
                                
                                //2.hstack 버튼 액션 선언
                                Group{
                                    HStack{
                                        Spacer()
                                        HStack{
                                            HStack{
                                                //수정 버튼
                                                HStack{
                                                    Button(action: {
                                                        self.main_vm.selected_card_idx = self.main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].card_idx!
                                                        
                                                        
                                                        //수정하는 페이지로 이동
                                                        self.go_to_edit  = true
                                                        print("수정하는 페이지 이동 구분값: \(self.go_to_edit)")
                                                        
                                                    }, label: {
                                                        VStack{
                                                            Image("swipe_edit_icon")
                                                            Image("swipe_edit_txt")
                                                        }
                                                    })
                                                    .frame(width: UIScreen.main.bounds.width*0.2)
                                                    
                                                    //삭제버튼
                                                    Button(action: {
                                                        //지우려는 카드의 행과 idx정보 저장.
                                                        self.main_vm.selected_card_idx = self.main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].card_idx!
                                                        
                                                        withAnimation(.default){
                                                            self.show_delete_alert.toggle()
                                                        }
                                                    }, label: {
                                                        
                                                        VStack{
                                                            Image("swipe_del_icon")
                                                            Image("swipe_del_txt")
                                                        }
                                                    })
                                                    .frame(width: UIScreen.main.bounds.width*0.2)
                                                    .padding()
                                                    .alert(isPresented: $show_delete_alert){
                                                        Alert(title: Text("카드 삭제하기"), message: Text("내 카드를 지우시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                                                            
                                                            self.main_vm.my_friend_volleh_card_struct.removeAll{$0.card_idx == self.main_vm.selected_card_idx}
                                                            
                                                            //확인 눌렀을 때 통신 시작
                                                            //                                                        self.main_vm.delete_friend_volleh_card()
                                                            
                                                            //카드 idx로 채팅방 idx 가져오기
                                                            let chatroom_idx =     ChatDataManager.shared.get_chatroom_from_card(card_idx: Int(self.main_vm.selected_card_idx))
                                                            
                                                            SockMgr.socket_manager.exit_room(chatroom_idx: chatroom_idx, idx: Int(main_vm.my_idx!)!, nickname: main_vm.my_nickname, profile_photo_path: "", kinds: nil)
                                                            
                                                        }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                                                            self.show_delete_alert.toggle()
                                                        }))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                Group{
                                    //카드 1개 뷰 : foreach문에서 아이템을 넘겨주는 대신 index를 얻기 위해 뷰모델에 선언된 메소드를 이용해 해당 item의 index값 넘겨준다.
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .foregroundColor(.proco_white)
                                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                                        .overlay(
                                            MyCardListView(main_viewmodel: main_vm, my_volleh_card_struct: main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)], current_card_index: self.main_vm.get_index(item: item))
                                        )
                                        //스와이프해서 수정, 삭제 위해 offset을 데이터 모델에 임의로 넣어줬음. 이 값을 이용한 것.
                                        .offset(x:main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset ?? 0)
                                        .onTapGesture {
                                            //카드의 정보 세팅에 idx값을 이용해 데이터 꺼낼 때 사용.
                                            self.main_vm.selected_card_idx = self.main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].card_idx!
                                            
                                            print("이동하려는 카드 idx:  \( self.main_vm.selected_card_idx)")
                                            // 상세 페이지 카드 정보 갖고 오는 통신 진행. -> 상세 페이지에서
                                            self.show_friend_card_detail.toggle()
                                            
                                        }
                                        //스와이프할 때 Offset값을 얻어옴.
                                        .gesture(DragGesture().onChanged({ (value) in
                                            withAnimation(.default){
                                                main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset = value.translation.width
                                                print("해당 카드 current_idx확인 : \(self.main_vm.get_index(item: item))")
                                                
                                            }
                                        })
                                        //스와이프 동작이 끝났을 때에 따라 데이터모델의 offset값 조정.
                                        .onEnded({ (value) in
                                            withAnimation(.default){
                                                
                                                if value.translation.width < UIScreen.main.bounds.width * -0.15{
                                                    print("on ended에 들어옴 : offset 확인2")
                                                    
                                                    main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset = UIScreen.main.bounds.width * -0.6
                                                }
                                                else{
                                                    print("on ended에 들어옴 : offset 확인3")
                                                    main_vm.my_friend_volleh_card_struct[self.main_vm.get_index(item: item)].offset = 0
                                                }
                                            }
                                            //gesture끝
                                        }))
                                        .padding(.bottom, UIScreen.main.bounds.width/20)
                                }
                                //zstack끝
                            }
                            //내 카드 foreach문 끝
                        }
                        
                        
                    }, label: {
                        Text("내 카드")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(.proco_black)
                            .padding(.leading, UIScreen.main.bounds.width/20)
                    })
                    .padding(.trailing)
                    
                    //친구 카드 상세 페이지 - 액티비티로 변경함.
                    NavigationLink("", destination: FriendVollehCardDetail(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(),socket:   SockMgr.socket_manager,calendar_vm: self.calendar_vm).navigationBarTitle("", displayMode: .inline)
                                    .navigationBarHidden(true), isActive: self.$show_friend_card_detail)
                    
                    //친구 카드 리스트
                    friend_card_list
                    
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
                    print("좋아요 클릭 통신 완료 받음.: \(value)")
                    
                })
                //필터 뷰
                .sheet(isPresented: $show_filter_modal){
                    FriendFilterModal(show_filter_modal: $show_filter_modal, viewmodel: self.main_vm)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                .onAppear{
                    print("*************친구랑 볼래 메인 뷰 나타남****************")
                    self.main_vm.applied_filter = false
                    self.my_photo_path = UserDefaults.standard.string(forKey: "\(main_vm.my_idx!)_profile_photo_path") ?? ""
                    //user defaults에서 내 닉네임 꺼내오는 메소드 실행. 그래야 내 카드만 골라서 보여줄 수 있음.
                    main_vm.get_my_nickname()
                    
                    //카드 데이터 갖고 오는 통신-> 끝나면 전체 카드 내가 클릭한 좋아요 목록 가져오는 통신(카드마다 내가 좋아요 클릭했는지 여부 알기 위해 좋아요 유저 목록 미리 가져와야 함.)
                    main_vm.get_friend_volleh_cards()
                    
                    print("내 닉네임 확인 : \(main_vm.my_nickname)")
                    //on, off 상태 표시하기 위해 user defaults에서 가져와서 세팅
                    let user_idx = ChatDataManager.shared.my_idx!
                    self.state_on = UserDefaults.standard.integer(forKey: "\(user_idx)_state")
                    
                    print("저장됐던 유저 상태 확인:\(user_idx) \(self.state_on)")
                }
                .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
                    print("친구랑 볼래에서 오늘 심심기간 초기 설정 노티 받음")
                    if let user_info = value.userInfo, let check_boring = user_info["set_today_boring_data"]{
                        print("친구랑 볼래에서 오늘 심심기간 초기 설정 받았음: \(check_boring)")
                        
                        //오늘이 심심기간이었는지 확인.
                        if check_boring as! String == "-1"{
                            print("오늘 심심기간 설정 안해놨음")
                            self.today_is_boring = false
                        }else{
                            print("오늘 심심기간임")
                            self.today_is_boring = true
                        }
                        print("친구랑 볼래에서 오늘 심심기간 설정 \(check_boring)")
                    }else{
                        print("친구 메인에서 초기에 오늘 심심기간인지 노티 아님.")
                    }
                }
                .onDisappear{
                    print("*************친구랑 볼래 메인 뷰 사라짐****************")
                }
                .onReceive( NotificationCenter.default.publisher(for: Notification.set_boring_today)){value in
                    print("친구랑 볼래에서 오늘 심심기간 설정 노티 받음")
                    if let user_info = value.userInfo, let check_boring = user_info["today_boring_event"]{
                        print("친구랑 볼래에서 오늘 심심기간 설정 받았음: \(check_boring)")
                        
                        if check_boring as! String == "ok"{
                            if self.today_is_boring == false{
                                self.today_is_boring = true
                            }else{
                                self.today_is_boring = false
                            }
                            print("친구랑 볼래에서 오늘 심심기간 설정 \(check_boring)")
                        }
                    }else{
                        print("친구 메인에서 오늘 심심기간 설정 서버 통신 후 노티 응답 실패: .")
                    }
                }
            }
            
            //여기에 다이얼로그 오버레이해야 스크롤뷰 위치에 따라 오버레이 높이 결정되는 문제 해결됨.
        }
        .background(Color.proco_dark_white)
        .overlay(FriendStateDialog(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(),show_friend_info: $friend_info_dialog, socket: SockMgr.socket_manager, state_on: self.$state_on, is_friend : true, is_from_chatroom: false))
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

private extension FriendVollehMainView{
    
    var user_info_view : some View{
        //상단에 내 프로필, on.off버튼, 필터 버튼 그룹
        Group{
            HStack{
                ZStack(alignment: .bottomTrailing){
                    
                    if self.my_photo_path == "" || self.my_photo_path == nil{
                        //내 프로필
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                            .cornerRadius(50)
                            .scaledToFit()
                            .overlay(self.today_is_boring ? Circle()
                                        .stroke(Color.proco_yellow , lineWidth: 2) : nil)
                            .padding([.leading], UIScreen.main.bounds.width/30)
                        
                    }else{
                        
                        KFImage(URL(string: self.my_photo_path))
                            .placeholder{Image("main_profile_img")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
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
                                    .frame(width: 40, height: 40)
                            }
                            .overlay(self.today_is_boring ? Circle()
                                        .stroke(Color.proco_yellow , lineWidth: 2) : nil)
                        
                    }
                    
                    Rectangle()
                        .foregroundColor(self.state_on == 0 ? Color.gray : Color.proco_green)
                        .frame(width: 14, height: 14)
                        .clipShape(Circle())
                        .overlay(Circle()
                                    .strokeBorder(Color.proco_white, lineWidth: 1)
                        )
                }
                .onTapGesture {
                    
                    self.main_vm.friend_info_struct = GetFriendListStruct(idx: Int(self.main_vm.my_idx!),nickname: main_vm.my_nickname, profile_photo: self.my_photo_path, state: self.state_on, kinds:  "")
                    
                    // 내 프로필 이미지 클릭시 다이얼로그 나오고 = on, off 선택 가능
                    self.friend_info_dialog = true
                }
                
                Spacer()
                Group{
                    HStack{
                        Text(main_vm.my_nickname)
                            .font(.custom(Font.n_bold, size: 13))
                            .foregroundColor(.proco_black)
                        
                        Spacer()
                        //심심기간 설정 버튼
                        Button(action: {
                            
                            print("심심기간 설정 버튼 클릭")
                            self.set_boring_today_alert.toggle()
                            //오늘을 심심기간으로 설정했는지 안했는지 알아야 함.
                            // let boring_today = String.date_string(date: today)
                            
                            
                        }){
                            Image(self.today_is_boring ? "boring_set_btn" : "not_boring_set_btn")
                            
                        }
                        .alert(isPresented: self.$set_boring_today_alert, content: {
                            Alert(title: Text(""), message: Text(self.today_is_boring == true ? "오늘을 심심한 날 설정을 취소할까요?" : "오늘을 심심한 날로 설정할까요?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                                let today = Date()
                                let boring_today = String.date_string(date: today)
                                var action : Int = 0
                                if self.today_is_boring == false {
                                    action = 1
                                }
                                print("오늘 심심기간 설정시 서버에 보내는 파라미터 확인: \(String(describing: action)), \(boring_today)")
                                self.main_vm.set_boring_today(action:action , date: boring_today)
                                
                            }), secondaryButton: Alert.Button.cancel(Text("아니요"), action: {
                                
                            }))
                        })
                        
                        NavigationLink("", destination: MakeCardView(main_viewmodel: self.main_vm, tag_category_struct: self.volleh_category_struct)
                                       , isActive: self.$go_to_make_card)
                        
                        //카드 추가하기 버튼
                        Button(action: {
                            //여기에서 남아있을 수 있는 데이터 제거 해줌. 만들기 뷰의 onappear에서 하면 네비게이션바가 제대로 안나타남
                            self.main_vm.user_selected_tag_set.removeAll()
                            self.main_vm.user_selected_tag_list.removeAll()
                            
                            self.go_to_make_card.toggle()
                            print("카드 추가하는 뷰로 이동 토글 값 : \(self.go_to_make_card)")
                            
                        }, label: {
                            Image("main_plus")
                        })
                        .padding([.trailing], UIScreen.main.bounds.width/20)
                    }
                }
            }
        }
    }
    
    var filter_btn : some View{
        Group{
            HStack{
                Spacer()
                NavigationLink("",
                               destination: FriendFilterModal(show_filter_modal: self.$show_filter_modal, viewmodel: self.main_vm),
                               isActive: self.$show_filter_modal
                )
                //필터 버튼 클릭시 지금.이날.모두.접속 선택하는 뷰로 이동.
                Button(action: {
                    
                    self.show_filter_modal = true
                    //만약 필터 결과가 없을 시에 alert창 띄우기
                    self.main_vm.result_alert(main_vm.alert_type)
                    
                }){
                    HStack{
                        
                        ZStack(alignment: .leading){
                            
                            Image("main_filter")
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            if self.main_vm.applied_filter{
                                
                                Image("check_end_btn")
                                    .resizable()
                                    .frame(width: 13, height: 13)
                            }
                        }
                        Text("필터")
                            .font(.custom(Font.n_bold, size: 10))
                            .foregroundColor(.proco_black)
                    }
                }
                
                Button(action: {
                    //전체보기 클릭시 필터 적용 해제 = 친구 메인 on appear에서 하는 통신 다시 진행.
                    self.main_vm.get_friend_volleh_cards()
                    self.main_vm.applied_filter = false
                }){
                    Text("전체보기")
                        .font(.custom(Font.n_bold, size: 10))
                        .foregroundColor(self.main_vm.applied_filter ? .light_gray : .proco_white)
                        .cornerRadius(25)
                        .padding(UIScreen.main.bounds.width/40)
                }
                .background(self.main_vm.applied_filter ? Color.gray : Color.proco_black)
                .overlay(Capsule()
                            .stroke(self.main_vm.applied_filter ? Color.gray : Color.proco_black, lineWidth: 1.5)
                         
                )
                .cornerRadius(25.0)
            }
            .padding([.trailing], UIScreen.main.bounds.width/20)
        }
    }
    
    var friend_card_list : some View{
        VStack{
            DisclosureGroup(isExpanded:$open_friend_cards, content: {
                ForEach(self.main_vm.friend_volleh_card_struct){ item in
                    
                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(.proco_white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                        
                        .overlay(
                            
                            FriendCardListView(main_vm: main_vm, friend_volleh_card_struct: main_vm.friend_volleh_card_struct[self.main_vm.get_friend_index(item: item)], current_card_index: self.main_vm.get_friend_index(item: item))
                        )
                        
                        //상세 정보 뷰로 이동
                        .onTapGesture {
                            //카드의 정보 세팅에 idx값을 이용해 데이터 꺼낼 때 사용.
                            self.main_vm.selected_card_idx = self.main_vm.friend_volleh_card_struct[self.main_vm.get_friend_index(item: item)].card_idx!
                            print("이동하려는 카드 idx: \(self.main_vm.friend_volleh_card_struct[self.main_vm.get_friend_index(item: item)].card_idx ?? -1)")
                            //TODO 상세 페이지 카드 정보 갖고 오는 통신 진행 안함.
                            // self.main_vm.get_friend_detail()
                            self.show_friend_card_detail.toggle()
                        }
                        .padding(.bottom, UIScreen.main.bounds.width/20)
                }
            }, label: {
                Text("친구")
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                    .padding(.leading, UIScreen.main.bounds.width/20)
            })
            .padding(.trailing)
            
        }
    }
    
    var boring_friends_list : some View{
        ScrollView(.horizontal, showsIndicators: false){
            
            HStack{
                
                ForEach(self.main_vm.today_boring_friends_model){friend in
                    
                    Button(action: {
                        print("친구 한 명 클릭")
                        self.main_vm.friend_info_struct = GetFriendListStruct(idx: friend.idx,nickname: friend.nickname, profile_photo: friend.profile_photo_path ?? "", state: friend.state, kinds: friend.kinds )
                        self.friend_info_dialog.toggle()
                    }){
                        VStack{
                            if friend.profile_photo_path == "" || friend.profile_photo_path == nil{
                                
                                Image("main_profile_img")
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                                    .scaledToFit()
                                    .overlay(Capsule()
                                                .stroke(Color.proco_yellow, lineWidth: 2)
                                    )
                                    .padding([.trailing], UIScreen.main.bounds.width/40)
                            }else{
                                
                                KFImage(URL(string: friend.profile_photo_path!))
                                    .placeholder{Image("main_profile_img")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
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
                                            .frame(width: 40, height: 40)
                                    }
                                    .overlay(Capsule()
                                                .stroke(Color.proco_yellow, lineWidth: 2)
                                    )
                                
                                
                            }
                            
                            if friend.idx == Int(ChatDataManager.shared.my_idx!)!{
                                
                                HStack{
                                    Image("check_end_btn")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                    
                                    Text("나")
                                        .font(.custom(Font.n_bold, size: 10))
                                        .foregroundColor(.proco_black)
                                }
                                
                            }else{
                                Text(friend.nickname)
                                    .font(.custom(Font.n_bold, size: 10))
                                    .foregroundColor(.proco_black)
                            }
                            
                        }
                    }
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/40)
                }
                
            }
            
        }
    }
    
}

