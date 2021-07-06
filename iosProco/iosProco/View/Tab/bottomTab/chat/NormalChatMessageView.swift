//
//  NormalChatMessageView.swift
//  proco
//
//  Created by 이은호 on 2021/05/10.
//

import SwiftUI

struct NormalChatMessageView: View{
    
    @ObservedObject var socket : SockMgr
    @State var scrolled = false
    @State var message = ""
    //채팅 메세지 입력창 왼쪽 플러스 버튼 클릭시 토글값
    @State private var show_contents_menu : Bool = false
    //앨범 버튼 클릭시 토글값
    @State private var select_album : Bool = false
    //선택한 이미지
    @Binding var selected_image : Image?
    @Binding var image_url : String?
    @Binding var open_gallery : Bool
    @Binding var ui_image : UIImage?
    
    @Binding var too_big_img_size : Bool
    
    //안보내진 메세지를 다시 보내려는 알림창 띄우는 것
    @Binding var send_again_alert : Bool
    
    var body: some View{
        VStack{
            ScrollViewReader { reader in
                ScrollView(.vertical){
                    VStack(spacing: 10){
                        ForEach(SockMgr.socket_manager.chat_message_struct){msg in
                          
                            ChatRow(msg: msg, send_again_alert: self.$send_again_alert)
                                .onAppear{
                                    // 처음 스크롤
                                    if msg.id == SockMgr.socket_manager.chat_message_struct.last!.id && !scrolled{
                                        
                                        reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                                        scrolled = true
                                    }
                                }
                        }
                        .onChange(of: SockMgr.socket_manager.chat_message_struct, perform: { value in
                            
                            reader.scrollTo(SockMgr.socket_manager.chat_message_struct.last!.id,anchor: .bottom)
                        })
                    }
                    .padding(.all)
                }//스크롤뷰 끝
            }//스크롤뷰 리더 끝
            //채팅 입력창
            Divider()
                .frame(width: UIScreen.main.bounds.width, height: 1)
                .foregroundColor(Color.light_gray)
            VStack{
            HStack{
                if self.selected_image == nil{
                    
                    plus_contents_menu
                    msg_txtfield
                    if message != ""{
                        HStack{
                                msg_send_btn
                            
                        }.padding([.trailing])
                        //앨범에서 선택한 이미지가 있을 경우
                    }
                }
                else {
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
        }
           // .padding([.leading, .trailing])
        .animation(.easeOut)
        }
        .KeyboardAwarePadding()
    }
}

extension NormalChatMessageView{
    
    var go_album_btn : some View{
        VStack{
            Button(action: {
                self.open_gallery = true
                print("사진 클릭")
                
            }){
                VStack{
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.proco_pink)
                    
                    Text("앨범")
                        .font(.custom(Font.t_extra_bold, size: 15))
                        .foregroundColor(Color.proco_black)
                }
            }
        }
        .padding(.leading)
    }
    
    var plus_contents_menu : some View{
        Button(action: {
            show_contents_menu.toggle()
            print("플러스 컨텐츠 클릭")
        }){
            Image("circle_plus_icon")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
        }
    }
    
    var msg_txtfield : some View{
        TextField("", text: $message)
            .padding(.vertical, UIScreen.main.bounds.width/40)
            //.padding(.horizontal)
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width*0.7)

    }
    
    var msg_send_btn : some View{
        Button(action: {
            
            let chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
            let front_created_at = ChatDataManager.shared.get_current_time()
            let created_at = ChatDataManager.shared.make_created_at()
            let my_idx = Int(ChatDataManager.shared.my_idx!)
            let my_nickname = ChatDataManager.shared.my_nickname
            
            print("sqlite에 메세지 보낼 때 임시 저장하는 front_created_at: \(String(front_created_at))")
            SockMgr.socket_manager.stored_front_created = String(front_created_at)
            print("임시채팅방인지: \(SockMgr.socket_manager.is_first_temp_room)")
            
            //첫 임시 채팅방 생성시에는 다른 이벤트 보내야 함.
            if SockMgr.socket_manager.enter_chatroom_idx == -1{
                print("임시 채팅방 메시지 보내기 버튼 클릭: 나\(String(describing: my_idx)) 친구\(SockMgr.socket_manager.temp_chat_friend_model.idx)")
              
                //친구 유저 모델 만들기 위해 정보 가져오기
                ChatDataManager.shared.get_user_info_private_chat(user_idx: SockMgr.socket_manager.temp_chat_friend_model.idx)
                
                //내 유저 모델 가져오기
                ChatDataManager.shared.get_my_user_info(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, user_idx: my_idx!)
                
                    //서버에 이벤트 보내기
                SockMgr.socket_manager.make_private_chatroom(my_idx: my_idx!, my_nickname: my_nickname!, my_image: SockMgr.socket_manager.my_profile_photo, friend_idx: SockMgr.socket_manager.temp_chat_friend_model.idx, friend_nickname: SockMgr.socket_manager.temp_chat_friend_model.nickname, friend_image: SockMgr.socket_manager.temp_chat_friend_model.profile_photo_path!, content: self.message, created_at: created_at, front_created_at: front_created_at)
                
                //temp key 생성하기 위해 오름차순 정렬.
                 let idx_array = [Int(my_idx!), SockMgr.socket_manager.temp_chat_friend_model.idx].sorted()
                print("채팅방 안에서 idx_array: \(idx_array)")
                 let temp_key = "a\(idx_array[0])i\(idx_array[1])"
                                                
                //server idx가져오는 쿼리
                ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!, chatroom_idx: chatroom_idx)
                let server_idx =  ChatDataManager.shared.user_server_idx
                
                //sqlite에 임시 저장(메세지, 채팅방, 유저2명 각각)
                ChatDataManager.shared.insert_chatting(chatroom_idx: -1, chatting_idx: -1, user_idx: my_idx!, content: self.message, kinds: temp_key, created_at: created_at, front_created_at: String(front_created_at))
                
                //일반 채팅방
                ChatDataManager.shared.insert_chatroom(idx: -1, card_idx: 0, creator_idx: my_idx!, kinds: "일반\(temp_key)", room_name: "", created_at: created_at, updated_at: "", deleted_at: "", state: 0)
                
                //유저 테이블에 내 정보 저장
                ChatDataManager.shared.insert_user(chatroom_idx: -1, user_idx: my_idx!, nickname: my_nickname!, profile_photo_path: SockMgr.socket_manager.my_profile_photo, read_last_idx: 0, read_start_idx: 0, temp_key: temp_key, server_idx: server_idx, updated_at: "", deleted_at: "")
                
                //유저 테이블에 친구 정보 저장
                ChatDataManager.shared.insert_user(chatroom_idx: -1, user_idx: SockMgr.socket_manager.temp_chat_friend_model.idx, nickname: SockMgr.socket_manager.temp_chat_friend_model.nickname, profile_photo_path: SockMgr.socket_manager.temp_chat_friend_model.profile_photo_path!, read_last_idx: 0, read_start_idx: 0, temp_key: temp_key, server_idx: server_idx, updated_at: "", deleted_at: "")
                
                //임시 채팅방임을 알려주는 값 false로 다시 바꿈.
                socket_manager.is_first_temp_room.toggle()
            }
            else{
            /*
             보내기 버튼을 눌렀을 때 1.메시지 임시저장 2.서버에 메시지 보내기 이벤트
             3.CHAT_USER에 read last message를 이 메세지 idx로 넣기.
             */
            //sqlite에 메세지 임시 저장
            print("채팅방 메시지 보내기 버튼 클릭")
            ChatDataManager.shared.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: -1, user_idx: my_idx!, content: self.message, kinds: "C", created_at: created_at, front_created_at: SockMgr.socket_manager.stored_front_created)
            
              
                print("채팅 메세지 저장됐던 것 확인2: \(SockMgr.socket_manager.chat_message_struct)")
             
                //바로 전 메세지를 보낸 시각
                var is_same : Bool = false
                if SockMgr.socket_manager.chat_message_struct.count > 0{
                var prev_msg_created : String?
                prev_msg_created =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].created_at ?? ""
               print("바로 전 메세지 보낸 시각: \(prev_msg_created)")
                //바로 전 메세지를 보낸 사람
                var prev_msg_user : String?
                prev_msg_user  =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].sender ?? ""
                print("바로 전 메세지 보낸 prev_msg_user: \(prev_msg_user)")

                 is_same =  SockMgr.socket_manager.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(my_idx!))
                print("비교 결과: \(is_same)" )
                }
                
                var is_last_consecutive_msg : Bool = true
                if is_same{
                    is_last_consecutive_msg = true
                  
                        //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                        SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                    
                }
                
            //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
                SockMgr.socket_manager.chat_message_struct.append(ChatMessage(created_at: created_at,sender: String(my_idx!),message: self.message,message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
            
            //서버에 메세지 보내기 이벤트 실행
                SockMgr.socket_manager.send_message(message_idx: -1, chatroom_idx: chatroom_idx, user_idx: my_idx!, content: self.message, kinds: "C", created_at: created_at, front_created_at: front_created_at)
               
            }
            //입력창 초기화
            self.message = ""
            
        }, label: {
            Image("msg_send_btn")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                .rotationEffect(.init(degrees: 45))
               // .padding(.all)
        })
    }
    
    var cancel_send_img_btn : some View{
        Button(action: {
            self.selected_image = nil
            self.show_contents_menu = true
            
            print("앨범에서 사진 선택해 보내기 취소")
        }){
            Image(systemName: "chevron.left.square")
                .foregroundColor(.gray)
        }
    }
    
    var send_img_btn : some View{
        Button(action: {
            print("이미지 보내기 버튼 클릭: \(String(describing: self.image_url))")
            
            let chatroom_idx = SockMgr.socket_manager.enter_chatroom_idx
            let front_created_at = ChatDataManager.shared.get_current_time()
            let created_at = ChatDataManager.shared.make_created_at()
            let my_idx = Int(ChatDataManager.shared.my_idx!)
            let my_nickname = ChatDataManager.shared.my_nickname
            
            print("sqlite에 메세지 보낼 때 임시 저장하는 front_created_at: \(String(front_created_at))")
            SockMgr.socket_manager.stored_front_created = String(front_created_at)
            print("임시채팅방인지: \(SockMgr.socket_manager.is_first_temp_room)")
            
            //10mb이상 크기인 이미지는 보낼 수 없도록 제한하기 위해 계산.
            ImageResizer.resize(image: ui_image!, maxByte: 10*1024*1024){ img in
                guard let resized_img = img else{return}
                print("리사이즈한 이미지 : \(resized_img)")

                let image_data = ui_image?.jpegData(compressionQuality: 0.5)
                print("보낼 이미지 데이터 크기: \(image_data)")
                if image_data!.count >= 10*1024*1024{
                    print("이미지 크기가 큼")
                    self.too_big_img_size.toggle()
                }
                else{
                
                socket.save(file_name: String(front_created_at), image_data: image_data!)
            
            //서버에 보낼 이미지
                let encoded =  self.socket.convert_img_base64(image_data: image_data)
                let final_encoded = "data:image/png;base64,\(encoded)"

                    if SockMgr.socket_manager.enter_chatroom_idx == -1{
                        print("임시 채팅방 메시지 보내기 버튼 클릭: 나\(String(describing: my_idx)) 친구\(SockMgr.socket_manager.temp_chat_friend_model.idx)")
                        print("친구 idx: \(socket.temp_chat_friend_model.idx)")
                        print("친구 idx: \(socket_manager.temp_chat_friend_model.idx)")

                        //친구 유저 모델 만들기 위해 정보 가져오기
                        ChatDataManager.shared.get_user_info_private_chat(user_idx: SockMgr.socket_manager.temp_chat_friend_model.idx)
                        
                        //내 유저 모델 가져오기
                        ChatDataManager.shared.get_my_user_info(chatroom_idx: SockMgr.socket_manager.enter_chatroom_idx, user_idx: my_idx!)
                        
                            //서버에 이벤트 보내기
                        SockMgr.socket_manager.make_private_chatroom(my_idx: my_idx!, my_nickname: my_nickname!, my_image: SockMgr.socket_manager.my_profile_photo, friend_idx: SockMgr.socket_manager.temp_chat_friend_model.idx, friend_nickname: SockMgr.socket_manager.temp_chat_friend_model.nickname, friend_image: SockMgr.socket_manager.temp_chat_friend_model.profile_photo_path!, content: final_encoded, created_at: created_at, front_created_at: front_created_at)
                        
                        //temp key 생성하기 위해 오름차순 정렬.
                         let idx_array = [Int(my_idx!), SockMgr.socket_manager.temp_chat_friend_model.idx].sorted()
                        print("채팅방 안에서 idx_array: \(idx_array)")
                         let temp_key = "a\(idx_array[0])i\(idx_array[1])"
                                                        
                        //server idx가져오는 쿼리
                        ChatDataManager.shared.get_server_idx_to_chat_server(user_idx: my_idx!, chatroom_idx: chatroom_idx)
                        
                        //sqlite에 임시 저장(메세지, 채팅방, 유저2명 각각)
                        ChatDataManager.shared.insert_chatting(chatroom_idx: -1, chatting_idx: -1, user_idx: my_idx!, content: String(front_created_at), kinds: temp_key, created_at: created_at, front_created_at: String(front_created_at))
                        
                        //일반 채팅방
                        ChatDataManager.shared.insert_chatroom(idx: -1, card_idx: 0, creator_idx: my_idx!, kinds: "일반\(temp_key)", room_name: "", created_at: created_at, updated_at: "", deleted_at: "", state: 0)
                     
                        let server_idx =  ChatDataManager.shared.user_server_idx
                        
                        //유저 테이블에 내 정보 저장
                        ChatDataManager.shared.insert_user(chatroom_idx: -1, user_idx: my_idx!, nickname: my_nickname!, profile_photo_path: SockMgr.socket_manager.my_profile_photo, read_last_idx: 0, read_start_idx: 0, temp_key: temp_key, server_idx: server_idx, updated_at: "", deleted_at: "")
                        
                        //유저 테이블에 친구 정보 저장
                        ChatDataManager.shared.insert_user(chatroom_idx: -1, user_idx: SockMgr.socket_manager.temp_chat_friend_model.idx, nickname: SockMgr.socket_manager.temp_chat_friend_model.nickname, profile_photo_path: SockMgr.socket_manager.temp_chat_friend_model.profile_photo_path!, read_last_idx: 0, read_start_idx: 0, temp_key: temp_key, server_idx: server_idx, updated_at: "", deleted_at: "")
                        
                        //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
                        SockMgr.socket_manager.chat_message_struct.append(ChatMessage(kinds: "일반\(temp_key)", created_at: created_at,sender: String(my_idx!),message: String(front_created_at), message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: false, is_last_consecutive_msg: true))
                        
                        //임시 채팅방임을 알려주는 값 false로 다시 바꿈.
                        socket_manager.is_first_temp_room.toggle()
                    }
                    else{
                    /*
                     보내기 버튼을 눌렀을 때 1.메시지 임시저장 2.서버에 메시지 보내기 이벤트
                     3.CHAT_USER에 read last message를 이 메세지 idx로 넣기.
                     */
                    //sqlite에 메세지 임시 저장
                    print("채팅방 메시지 보내기 버튼 클릭")
                    ChatDataManager.shared.insert_chatting(chatroom_idx: chatroom_idx, chatting_idx: -1, user_idx: my_idx!, content: String(front_created_at), kinds: "P", created_at: created_at, front_created_at: SockMgr.socket_manager.stored_front_created)
                        print("채팅 메세지 저장됐던 것 확인2: \(SockMgr.socket_manager.chat_message_struct)")
                     
                        //바로 전 메세지를 보낸 시각
                        var is_same : Bool = false
                        if SockMgr.socket_manager.chat_message_struct.count > 0{
                        var prev_msg_created : String?
                        prev_msg_created =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].created_at ?? ""
                       print("바로 전 메세지 보낸 시각: \(prev_msg_created)")
                        //바로 전 메세지를 보낸 사람
                        var prev_msg_user : String?
                        prev_msg_user  =  SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].sender ?? ""
                        print("바로 전 메세지 보낸 prev_msg_user: \(prev_msg_user)")

                         is_same =  SockMgr.socket_manager.is_consecutive(prev_created: prev_msg_created!, prev_creator: prev_msg_user!, current_created: created_at, current_creator: String(my_idx!))
                        print("비교 결과: \(is_same)" )
                        }
                        
                        var is_last_consecutive_msg : Bool = true
                        if is_same{
                            is_last_consecutive_msg = true
                          
                                //그 이전 순서의 메세지의 is last consecutive를 false로 바꿔줘야 함.
                                SockMgr.socket_manager.chat_message_struct[SockMgr.socket_manager.chat_message_struct.endIndex-1].is_last_consecutive_msg = false
                        }
                        
                    //메세지 보내기 후 여기에 일단 보여주기 위해 데이터 모델에 넣기...idx가 -1일 때 아닐 때로 보여주는 ui변경하기.
                        SockMgr.socket_manager.chat_message_struct.append(ChatMessage(created_at: created_at,sender: String(my_idx!),message: String(front_created_at), message_idx: -1, myMsg: true, front_created_at: String(front_created_at), is_same_person_msg: is_same, is_last_consecutive_msg: is_last_consecutive_msg))
                    
                    //서버에 메세지 보내기 이벤트 실행
                        SockMgr.socket_manager.send_message(message_idx: -1, chatroom_idx: chatroom_idx, user_idx: my_idx!, content: final_encoded, kinds: "P", created_at: created_at, front_created_at: front_created_at)
                    }
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
}
