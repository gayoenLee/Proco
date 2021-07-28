//
//  ChatMessageListView.swift
//  proco
//
//  Created by 이은호 on 2021/01/24.
//

import SwiftUI

struct ChatMessageListView: View{
    
    @ObservedObject var socket : SockMgr
    @State var scrolled = false
    @State var message = ""
    //채팅 메세지 입력창 왼쪽 플러스 버튼 클릭시 토글값
    @State private var show_contents_menu : Bool = false
    
    //앨범 버튼 클릭시 토글값
   // @State private var select_album : Bool = false
    //선택한 이미지
    @Binding var selected_image : Image?
    @Binding var image_url : String?
    @Binding var open_gallery : Bool
    @Binding var ui_image : UIImage?
    
    @Binding var too_big_img_size : Bool
    
    //안보내진 메세지를 다시 보내려는 알림창 띄우는 것
    @Binding var send_again_alert : Bool
    //이미지 확대 뷰 띄우는 것
    @Binding var show_img_bigger : Bool
    //드로어 유저 한 명 클릭했을 때 다이얼로그 띄우기
    @Binding var show_profile : Bool
    //채팅방 메세지 보낸 유저 한 명 클릭한 idx값 바인딩 -> 채팅룸에서 전달받기 -> 프로필 띄우기
    @Binding var selected_user_idx: Int
    
    var body: some View{
        VStack{
            ScrollViewReader { reader in
                ScrollView(.vertical){
                    VStack(spacing: 10){
                        
                        ForEach(SockMgr.socket_manager.chat_message_struct.filter({
                            $0.message_idx! != -2
                            
                        })){msg in
                            
                            ChatRow(msg: msg, send_again_alert: self.$send_again_alert, show_img_bigger: self.$show_img_bigger, image_url: self.$image_url, show_profile: self.$show_profile, selected_user_idx: self.$selected_user_idx)
                                
                                .onAppear{
                                    if SockMgr.socket_manager.chat_message_struct.count > 0{
                                    // 처음 스크롤
                                    if msg.id == SockMgr.socket_manager.chat_message_struct.last!.id && !scrolled{
                                        
                                        reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                                        scrolled = true
                                    }
                                    }
                                }
                        }
                        .onChange(of: SockMgr.socket_manager.chat_message_struct, perform: { value in
                            if SockMgr.socket_manager.chat_message_struct.count > 0{
                            reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                            }
                            
                        })
                        
                        ForEach(SockMgr.socket_manager.chat_message_struct.filter({
                            $0.message_idx! == -2
                            
                        })){msg in
                            
                            ChatRow(msg: msg, send_again_alert: self.$send_again_alert, show_img_bigger: self.$show_img_bigger, image_url: self.$image_url, show_profile: self.$show_profile, selected_user_idx: self.$selected_user_idx)
                                
                                .onAppear{
                                    if SockMgr.socket_manager.chat_message_struct.count > 0{
                                    // 처음 스크롤
                                    if msg.id == SockMgr.socket_manager.chat_message_struct.last!.id && !scrolled{
                                        
                                        reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                                        scrolled = true
                                    }
                                    }
                                }
                        }
                        .onChange(of: SockMgr.socket_manager.chat_message_struct, perform: { value in
                            if SockMgr.socket_manager.chat_message_struct.count > 0{
                                
                            reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                            }
                        })
                        
                    }
                    .padding(.all)
                }//스크롤뷰 끝
            }//스크롤뷰 리더 끝
            //채팅 입력창
            //채팅 입력창
            Divider()
                .frame(width: UIScreen.main.bounds.width, height: 1)
                .foregroundColor(Color.light_gray)
            VStack{
                HStack{
                    if self.selected_image == nil{
                    plus_contents_menu
                    chat_input_field
                    if message != ""{
                        HStack{
                                send_msg_btn
                            
                        }.padding([.trailing])
                        //앨범에서 선택한 이미지가 있을 경우
                    }
                }
                //앨범에서 선택한 이미지가 있을 경우 보내기 버튼 및 취소 버튼
                else{
                   
                        cancel_send_img_btn
                        Spacer()
                        send_img_btn
                    
                }
                }
                if show_contents_menu{
                    
                    HStack{
                        ScrollView(.horizontal){
                            if  self.selected_image != nil{
                                self.selected_image!
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                                    .clipShape(Rectangle())
                                
                            }
                            else {
                                go_album_btn
                            }
                        }
                    }
                    .animation(.easeOut)
                    
                }
            }//채팅 입력창 끝
            .animation(.easeOut)
        }
        .KeyboardAwarePadding()
    }
}

extension ChatMessageListView{
    
    var chat_input_field : some View{
        HStack{
            TextField("", text: $message)
                .padding(.vertical, UIScreen.main.bounds.width/40)
                .background(Color.white)
                .frame(width: UIScreen.main.bounds.width*0.7)

        }
        .animation(.default)
        .padding()
    }
    
    var plus_contents_menu : some View{
        Button(action: {
            show_contents_menu.toggle()
            print("플러스 컨텐츠 클릭")
            
        }){
            
            if show_contents_menu{
                
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    .foregroundColor(Color.proco_black)
                
            }else{
                Image("circle_plus_icon")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    
    var send_img_btn : some View{
        Button(action: {
            print("이미지 보내기 버튼 클릭: \(String(describing: self.image_url))")
            
            //10mb이상 크기인 이미지는 보낼 수 없도록 제한하기 위해 계산.
            ImageResizer.resize(image: ui_image!, maxByte: 10*1024*1024){ img in
                guard let resized_img = img else{return}
                print("리사이즈한 이미지 : \(resized_img)")
                
                let chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
                let front_created_at = ChatDataManager.shared.get_current_time()
                let created_at = ChatDataManager.shared.make_created_at()
                let my_idx = Int(ChatDataManager.shared.my_idx!)
                let my_nickname = ChatDataManager.shared.my_nickname
                print("sqlite에 메세지 보낼 때 임시 저장하는 front_created_at: \(String(front_created_at))")
                SockMgr.socket_manager.stored_front_created = String(front_created_at)
                
                
                let image_data = ui_image?.jpegData(compressionQuality: 1.0)
                print("보낼 이미지 데이터 크기: \(image_data)")
                if image_data!.count >= 10*1024*1024{
                    print("이미지 크기가 큼")
                    self.too_big_img_size.toggle()
                }else{
                
                socket.save(file_name: String(front_created_at), image_data: image_data!)
                
                //서버에 보낼 이미지
                let encoded =  self.socket.convert_img_base64(image_data: image_data)
                let final_encoded = "data:image/png;base64,\(encoded)"
                
                /*
                 보내기 버튼을 눌렀을 때 1.메시지 임시저장 2.서버에 메시지 보내기 이벤트
                 3.CHAT_USER에 read last message를 이 메세지 idx로 넣기.
                 */
                //sqlite에 메세지 임시 저장
                print("채팅방 메시지 보내기 버튼 클릭")
                ChatDataManager.shared.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: -1, user_idx: my_idx!, content: String(front_created_at), kinds: "P", created_at: created_at, front_created_at: SockMgr.socket_manager.stored_front_created)
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
                //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
                    SockMgr.socket_manager.chat_message_struct.append(ChatMessage(kinds: "P",created_at: created_at,sender: String(my_idx!),message:  String(front_created_at) ,message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
                
                //서버에 메세지 보내기 이벤트 실행
                SockMgr.socket_manager.send_message(message_idx: -1, chatroom_idx: chatroom_idx, user_idx: my_idx!, content: final_encoded, kinds: "P", created_at: created_at, front_created_at: front_created_at)
                }
            }
            //입력창 초기화
            self.message = ""
            
            
        }, label: {
            Image(systemName: "arrow.up")
                .frame(width: UIScreen.main.bounds.width/15, height:  UIScreen.main.bounds.width/15)
                .padding(.trailing)
                .rotationEffect(.init(degrees: 45))
        })
    }
    
    var cancel_send_img_btn : some View{
        Button(action: {
            self.selected_image = nil
            self.show_contents_menu = true
            print("앨범에서 사진 보내기 취소")
        }){
            Image(systemName: "chevron.left.square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.proco_black)
                
        }
    }
    
    var go_album_btn : some View{
        VStack{
            Button(action: {
                self.open_gallery = true
                print("사진 클릭")
                
            }){
                VStack{
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.proco_mint)
                    
                    Text("앨범")
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .foregroundColor(Color.proco_black)
                }
            }
        }
        .padding(.leading)
    }
    
    var send_msg_btn : some View{
        Button(action: {
            let chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
            let front_created_at = ChatDataManager.shared.get_current_time()
            let created_at = ChatDataManager.shared.make_created_at()
            let my_idx = Int(ChatDataManager.shared.my_idx!)
            let my_nickname = ChatDataManager.shared.my_nickname
            print("메세지 보내기 버튼 클릭 후 sqlite에 메세지 보낼 때 임시 저장하는 front_created_at: \(String(front_created_at))")
            SockMgr.socket_manager.stored_front_created = String(front_created_at)
            
            /*
             보내기 버튼을 눌렀을 때 1.메시지 임시저장 2.서버에 메시지 보내기 이벤트
             3.CHAT_USER에 read last message를 이 메세지 idx로 넣기.
             */
            //sqlite에 메세지 임시 저장
            print("채팅방 메시지 보내기 버튼 클릭")
            ChatDataManager.shared.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: -1, user_idx: my_idx!, content: self.message, kinds: "C", created_at: created_at, front_created_at: SockMgr.socket_manager.stored_front_created)
            print("메세지 보내기 버튼 클릭 후 채팅 메세지 데이터 확인1: \(SockMgr.socket_manager.chat_message_struct)")
            
            var is_same : Bool = false
            
            if !SockMgr.socket_manager.chat_message_struct.isEmpty{
                //바로 전 메세지를 보낸 시각
                var prev_msg_created : String?
                prev_msg_created =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].created_at ?? ""
                print("메세지 보내기 버튼 클릭 후 바로 전 메세지 보낸 시각: \(String(describing: prev_msg_created))")
                //바로 전 메세지를 보낸 사람
                var prev_msg_user : String?
                prev_msg_user  =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].sender ?? ""
                print("메세지 보내기 버튼 클릭 후 바로 전 메세지 보낸 prev_msg_user: \(String(describing: prev_msg_user))")
                is_same =  SockMgr.socket_manager.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(my_idx!))
                print("메세지 보내기 버튼 클릭 후 비교 결과: \(is_same)" )
                
            }else{
                is_same = false
                print("기존에 메세지가 없었을 경우: \(is_same)")
            }
            var is_last_consecutive_msg : Bool = true
            if is_same{
                is_last_consecutive_msg = true
                //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                //이 값도 바꿔줘야 맨 첫번째 메세지 ui도 맞게 변경 가능함.단, 연속된 메세지의 첫번째 메세지에서 값은 false여야 하므로 체크.
//                SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_same_person_msg = true
            }
            //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
            SockMgr.socket_manager.chat_message_struct.append(ChatMessage(created_at: created_at,sender: String(my_idx!),message: self.message,message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
            print("메세지 보내기 버튼 클릭 후 채팅 메세지 데이터 확인2: \(SockMgr.socket_manager.chat_message_struct)")
            //서버에 메세지 보내기 이벤트 실행
            SockMgr.socket_manager.send_message(message_idx: -1, chatroom_idx: chatroom_idx, user_idx: my_idx!, content: self.message, kinds: "C", created_at: created_at, front_created_at: front_created_at)
            
            //입력창 초기화
            self.message = ""
            
        }, label: {
            Image("msg_send_btn")
                .padding(.all)
            //.rotationEffect(.init(degrees: 45))
            
        })
    }
}

