//
//  ChatFriendRoomView.swift
//  proco
//
//  Created by 이은호 on 2021/03/11.
//

import SwiftUI
import Kingfisher

struct ChatFriendRoomView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var calendar_vm = CalendarViewModel()

    @ObservedObject var socket : SockMgr
    //햄버거 메뉴 클릭 여부
    @State var show_menu = false
    //추방당한 사람을 메인으로 보내기 위해 이용하는 구분값
    @State private var banished : Bool = false
    @State private var move_to_invitaion = false
    
    //사진 선택 여부 값
    @State private var open_gallery : Bool = false
    //선택한 사진
    @State private var selected_image : Image? = nil
    @State private var image_url : String? = ""
    @State private var ui_image : UIImage? = nil
    
    //이미지 크기가 클 경우 보낼 수 없닫는 알림창
    @State private var too_big_img_size : Bool = false
    
    //안보내진 메세지를 다시 보내려는 알림창 띄우는 것
    @State private var send_again_alert : Bool = false
    //에러 메세지 front created at
    @State private var error_msg_front_created : String = ""
    //에러 메세지 내용
    @State private var error_msg_content : String = ""
    //에러 메세지 temp key
    @State private var error_msg_kind : String = ""
    @State private var go_back : Bool = false
    
    //이미지 확대 뷰 띄우기 위한 구분값
    @State private var show_img_bigger: Bool = false
    //드로어 유저 한 명 클릭했을 때 다이얼로그 띄우기
    @State private var show_profile : Bool = false
    //친구 다이얼로그에서 신고하기 클릭시 다이얼로그 띄우는 구분값.
    @State private var show_report_view : Bool = false
    //드로어에서 유저 한 명 클릭한 idx값 바인딩 -> 채팅룸에서 전달받기 -> 프로필 띄우기
    @State private var selected_user_idx: Int = -1
    
    var user_profile_info : UserInDrawerStruct?{

        if self.show_profile{
         let model =   SockMgr.socket_manager.user_drawer_struct.first(where: {
                $0.user_idx! == self.selected_user_idx
            })
            print("드로어에서 클릭한 유저 정보: \(model)")
            if model != nil{
    return model!
            }else{
            return nil
        }
        }else{
            return nil
        }
    }
    //하단 텝이 있는 뷰에서 왔는지 구분하는 변수 . 기본적으로 true이지만 탭이 없었던 곳에서 뷰를 선언한다면 인자로 false를 전달함.
        var from_tab: Bool = true
    //유저 한 명 클릭시 피드 페이지 이동값
    @State private var go_feed: Bool = false
    //유저 한 명 클릭시 일대일 채팅 페이지 이동값
    @State private var go_private_chatroom: Bool = false
    //신고하기, 추방하기 컨텍스트 메뉴 띄우기
    @State private var show_context_menu : Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                //추방 당한 사람 메인 뷰로 이동시키기 위함.
                NavigationLink("",
                               destination: FriendVollehMainView(),
                               isActive: self.$banished)
                NavigationLink("",
                               destination: ChatMainView().navigationBarTitle("", displayMode: .inline).navigationBarHidden(true),
                               isActive: self.$go_back)
                
                //상단바
                HStack{
                    Button(action: {
                        print("뒤로가기 클릭")
                        //self.presentation.wrappedValue.dismiss()
                        if self.from_tab{  self.go_back = true}
                        else{self.presentation.wrappedValue.dismiss()}
                    }){
                        Image("left")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    }
                    Spacer()
                    if SockMgr.socket_manager.current_chatroom_info_struct.room_name == ""{
                        //채팅방 주인 이름
                        Text("\(SockMgr.socket_manager.creator_nickname)님과의 약속")
                            .padding()
                            .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/18))
                            .foregroundColor(.proco_black)
                        
                        //커스텀한 채팅방 이름이 있을 경우
                    }else{
                        Text(SockMgr.socket_manager.current_chatroom_info_struct.room_name)
                            .padding()
                            .font(.custom(Font.n_extra_bold, size: UIScreen.main.bounds.width/15))
                            .foregroundColor(.proco_black)
                    }
                    
                    Spacer()
                    //드로어 여는 햄버거 메뉴 버튼.
                    Button(action: {
                        
                        withAnimation{
                            self.show_menu.toggle()
                        }
                        print("드로어 보여주는 값: \(self.show_menu)")
                    }){
                        Image("drawer_menu_icon")
                            .resizable()
                            .frame(width: 20, height: 16)
                    }
                }
                .padding([.leading, .trailing, .top], UIScreen.main.bounds.width/10)
               
                //메인 채팅 메세지 나오는 부분 + 텍스트 입력창
                ChatMessageListView(socket: SockMgr.socket_manager, selected_image: self.$selected_image, image_url: self.$image_url, open_gallery: self.$open_gallery, ui_image: self.$ui_image, too_big_img_size: self.$too_big_img_size, send_again_alert: self.$send_again_alert, show_img_bigger : self.$show_img_bigger, show_profile: self.$show_profile ,selected_user_idx: self.$selected_user_idx)
                    .onTapGesture(perform: {
                        withAnimation{
                            if self.show_menu{
                            self.show_menu = false
                            }
                        }
                    })
                
                //유저 프로필에서 신고하기 클릭시 신고하는 페이지 이동.
                NavigationLink("",destination:  ReportView(show_report: self.$show_report_view, type: "채팅방회원", selected_user_idx: self.selected_user_idx, main_vm: FriendVollehMainViewmodel(), socket_manager: socket_manager, group_main_vm: GroupVollehMainViewmodel()), isActive: self.$show_report_view)
                
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.new_message), perform: {value in
                
                if let user_info = value.userInfo, let check_result = user_info["banished"]{
                    print("추방하기 이벤트 노티 친구 룸에서 받음")
                    
                    if check_result as! String == "ok"{
                        
                        let chatroom_idx = user_info["chatroom_idx"] as! String
                        let chatroom_idx_int = Int(chatroom_idx)
                        let user_idx = user_info["banished_user"] as! String
                        
                        //추방당한 채팅방 idx가 현재 채팅방인지 && 내가 추방당했는지 체크
                        if SockMgr.socket_manager.enter_chatroom_idx == chatroom_idx_int && ChatDataManager.shared.my_idx! == user_idx{
                            
                            self.go_back = true
                            
                        }
                    }
                    
                }
            })
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.9)
            .alert(isPresented: self.$too_big_img_size){
                Alert(title: Text("알림"), message: Text("10MB이상의 이미지는 보낼 수 없습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                    self.too_big_img_size = false
                    print("확인 클릭")
                }))
            }
            .alert(isPresented: self.$send_again_alert){
                Alert(title: Text("알림"), message: Text("메세지를 재전송하겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                    
                    let chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
                    let created_at = ChatDataManager.shared.make_created_at()
                    let my_idx = Int(ChatDataManager.shared.my_idx!)
                    let my_nickname = ChatDataManager.shared.my_nickname
                    
                    SockMgr.socket_manager.stored_front_created = String(error_msg_front_created)
                    //이미지 보낼 경우 서버에 보낼 content
                    var final_encoded : String = ""
                    
                    //다시 보내는 메세지가 이미지인 경우
                    if error_msg_kind == "P"{
                        //10mb이상 크기인 이미지는 보낼 수 없도록 제한하기 위해 계산.
                        ImageResizer.resize(image: ui_image!, maxByte: 10*1024*1024){ img in
                            guard let resized_img = img else{return}
                            print("리사이즈한 이미지 : \(resized_img)")
                            
                            let image_data = ui_image?.jpegData(compressionQuality: 0.5)
                            print("보낼 이미지 데이터 크기: \(String(describing: image_data))")
                            if image_data!.count >= 10*1024*1024{
                                print("이미지 크기가 큼")
                                self.too_big_img_size = true
                            }else{
                                socket.save(file_name: String(error_msg_front_created), image_data: image_data!)
                                
                                //서버에 보낼 이미지
                                let encoded =  self.socket.convert_img_base64(image_data: image_data)
                                final_encoded = "data:image/png;base64,\(encoded)"
                            }
                        }
                    }
                    
                    if self.too_big_img_size == false{
                        /*
                         보내기 버튼을 눌렀을 때 1.메시지 임시저장 2.서버에 메시지 보내기 이벤트
                         3.CHAT_USER에 read last message를 이 메세지 idx로 넣기.
                         */
                        //sqlite에 메세지 임시 저장
                        print("채팅방 메시지 보내기 버튼 클릭")
                        ChatDataManager.shared.update_send_message(chatroom_idx: chatroom_idx, chatting_idx: -1, front_created_at: error_msg_front_created, content: error_msg_content)
                        
                        print("채팅 메세지 데이터 확인: \(SockMgr.socket_manager.chat_message_struct)")
                        print("채팅 메세지 데이터 확인2: \(socket_manager.chat_message_struct)")
                        print("채팅 메세지 데이터 확인3: \(socket.chat_message_struct)")
                        
                        var is_same : Bool = false
                        
                        if !SockMgr.socket_manager.chat_message_struct.isEmpty{
                            //바로 전 메세지를 보낸 시각
                            var prev_msg_created : String?
                            prev_msg_created =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].created_at ?? ""
                            print("바로 전 메세지 보낸 시각: \(String(describing: prev_msg_created))")
                            //바로 전 메세지를 보낸 사람
                            var prev_msg_user : String?
                            prev_msg_user  =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].sender ?? ""
                            print("바로 전 메세지 보낸 prev_msg_user: \(String(describing: prev_msg_user))")
                            is_same =  SockMgr.socket_manager.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(my_idx!))
                            print("비교 결과: \(is_same)" )
                            
                        }else{
                            is_same = false
                            print("기존에 메세지가 없었을 경우: \(is_same)")
                        }
                        var is_last_consecutive_msg : Bool = true
                        if is_same{
                            is_last_consecutive_msg = true
                            
                            //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                            SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                        }
                        //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기
                        
                        let model_idx = SockMgr.socket_manager.chat_message_struct.firstIndex(where: {
                            $0.front_created_at == self.error_msg_front_created
                        })
                        SockMgr.socket_manager.chat_message_struct[model_idx!].created_at = created_at
                        SockMgr.socket_manager.chat_message_struct[model_idx!].message_idx = -1
                        
                        //서버에 메세지 보내기 이벤트 실행
                        SockMgr.socket_manager.send_message(message_idx: -1, chatroom_idx: chatroom_idx, user_idx: my_idx!, content: self.error_msg_content, kinds: error_msg_kind, created_at: created_at, front_created_at: CLong(error_msg_front_created)!)
                        
                        print("확인 클릭")
                    }
                }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                    
                    //모델에 저장돼 있던 데이터 삭제
                    let data_idx = SockMgr.socket_manager.chat_message_struct.firstIndex(where: {
                        $0.front_created_at! == error_msg_front_created
                    })
                    SockMgr.socket_manager.chat_message_struct.remove(at: data_idx!)
                    
                    //디비에서 채팅 메세지 삭제
                    ChatDataManager.shared.delete_chat_msg(front_created_at: self.error_msg_front_created)
                    
                    print("취소 클릭")
                }))
            }
            .onReceive( NotificationCenter.default.publisher(for: Notification.new_message)){value in
                print("친구 채팅방에서 노티  받음")
                if let user_info = value.userInfo, let check_banished = user_info["banished"]{
                    print("추방 당한 이벤트: \(check_banished)")
                    
                    if check_banished as! String == "banished"{
                        print("추방 당한 이벤트 true: \(check_banished)")
                        
                        self.banished = true
                    }
                }else{
                    print("추방 이벤트 아님")
                }
            }
            //채팅 읽음 처리 이벤트 수행.
            //서버에 unread이벤트 전달
            .onAppear{
                print("------------------친구 채팅방 onappear-----------------------")
                print("현재 enter chatroom idx 채팅방 idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
                let my_idx = Int(ChatDataManager.shared.my_idx!)
                print("서버에 보내기 전에 idx확인: \(String(describing: ChatDataManager.shared.my_idx))")
                print("채팅방 입장시 user read에 보내는 read last idx: \(ChatDataManager.shared.read_last_message)")
                
                ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                let server_idx = ChatDataManager.shared.user_server_idx
                
                let updated_at = ChatDataManager.shared.make_created_at()
                //서버에 내 user chat model보내기.user read이벤트 보내는 것.
                SockMgr.socket_manager.enter_friend_card_chat(server_idx:  server_idx, user_idx: my_idx!,chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, nickname:ChatDataManager.shared.my_nickname!, profile_photo_path: "", read_start_idx: ChatDataManager.shared.read_start_message, read_last_idx: ChatDataManager.shared.read_last_message, updated_at: updated_at, deleted_at: "")
                
                //내가 마지막으로 읽은 메세지 최신 메세지idx로 업데이트(나)
                ChatDataManager.shared.update_user_read(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, read_last_idx: ChatDataManager.shared.last_message_idx, user_idx: my_idx!, updated_at: updated_at)
                
                //새로운 채팅 메세지가 왔을 때 어떤 뷰에 있느냐에 따라 노티피케이션을 띄워주는게 다르기 때문에 알기 위해 사용.
                //채팅 목록 페이지 : 222, 채팅방 안: 333(기본: 111)
                SockMgr.socket_manager.current_view = 333
                
                //메시지별로 안읽은 갯수 표현하기 위해 계산하는 것.
                if  ChatDataManager.shared.get_read_last_list(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx){
                    print("친구랑 볼래에서 채팅방 마지막 메세지 idx 가져옴: \(ChatDataManager.shared.user_read_list)")
                }
                
                //채팅 메세지 데이터 가져오기
                ChatDataManager.shared.get_message_data(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, user_idx: Int(ChatDataManager.shared.my_idx!)!)
                //안읽은 메세지 계산 메소드.
                ChatDataManager.shared.calculate_last()
                
                //채팅 방 안 유저 정보들 가져와서 데이터 모델에 넣기(드로어에 보여줌)
                ChatDataManager.shared.read_chat_user(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                print("친구 채팅방 onappear 현재 채팅방 idx: \(SockMgr.socket_manager.enter_chatroom_idx)")
                
                //현재 채팅방의 주인 idx를 이용해 닉네임 가져와서 상단에 표시하기, 드로어 예외처리에 사용.
                ChatDataManager.shared.get_creator_nickname(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                
                print("현재 채팅방 데이터 확인: \(SockMgr.socket_manager.current_chatroom_info_struct)")
                print("읽음 처리 위한 user read list: \(ChatDataManager.shared.user_read_list)")
                
            }
            .onDisappear(perform: {
                print("채팅룸 사라짐")
                SockMgr.socket_manager.exit_chatroom(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx)
                SockMgr.socket_manager.chat_message_struct.removeAll()
                
            })
            .onReceive(NotificationCenter.default.publisher(for: Notification.send_msg_again), perform: {value in
                print("에러 메세지 다시 보내기 노티 받음")
                
                if let user_info = value.userInfo,  let check_result = user_info["send_msg_again"]{
                    
                    print("선택한 메세지 front created at: \(check_result)")
                    self.error_msg_front_created = check_result as! String
                    self.error_msg_content = user_info["msg_content"] as! String
                    self.error_msg_kind = user_info["msg_kind"] as! String
                    self.send_again_alert = true
                }
            })
            .background(Color.black.opacity(self.show_menu ? 0.28 : 0).edgesIgnoringSafeArea(.all).onTapGesture(perform: {
                withAnimation{self.show_menu.toggle()}
            }))
            .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
            .fullScreenCover( isPresented: self.$open_gallery, content: {
                ImagePicker(image: self.$selected_image, image_url: self.$image_url, ui_image: self.$ui_image)
            })
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            //채팅룸 드로어 부분.show_menu의 값에 따라서 열리고 닫힘.
            Spacer()
            HStack{
                
                ChatroomDrawer(socket: socket_manager, main_vm : FriendVollehMainViewmodel(), group_main_vm: GroupVollehMainViewmodel(), show_profile: self.$show_profile,selected_user_idx: self.$selected_user_idx, show_menu: self.$show_menu)
                    .background(Color.proco_white)
                    .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height*0.9)
                    .offset(x: self.show_menu ? UIScreen.main.bounds.width*0.08: UIScreen.main.bounds.width)
            }
            
            //유저 1명 프로필 뷰 보여주는 구분값 이 true일 때 다이얼로그 띄워서 보여주는 뷰
            if show_profile{
                ChatRoomUserProfileView(friend: user_profile_info!, show_profile: self.$show_profile, socket: socket_manager, selected_friend_idx: self.$selected_user_idx, show_report_view: self.$show_report_view, go_feed:self.$go_feed, calendar_vm: self.calendar_vm, go_private_chatroom: self.$go_private_chatroom, show_context_menu: self.$show_context_menu)

            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



