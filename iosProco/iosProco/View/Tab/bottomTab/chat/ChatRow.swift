//
//  ChatRow.swift
//  proco
//
//  Created by 이은호 on 2021/01/24.
//

import SwiftUI
import Kingfisher
import UIKit

struct ChatRow : View{
    
    var msg: ChatMessage
    
    var nickname : String{
        let index = SockMgr.socket_manager.user_drawer_struct.first(where: {
            $0.user_idx == Int(msg.sender!)
        })
        let nickname = index?.nickname
        return nickname ?? ""
    }
    
    var msg_time_converted : String{
        
        var time : String
        time = String.msg_time_formatter(date_string: msg.created_at!)
        print("시간 변환 확인: \(time)")
        return time
    }
    
    
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width*0.2, height: UIScreen.main.bounds.width))
        |> RoundCornerImageProcessor(cornerRadius: 20)
    
    //메세지 전송 취소된 아이콘 클릭시 다시 전송 alert창
    @Binding var send_again_alert : Bool
    
    //카드 초대하기에서 친구 카드 초대한 경우
    @State private var invited_friend_card = false
    //카드 초대하기에서 모임카드 초대한 경우
    @State private var invited_group_card = false
    
    var body: some View{
        HStack{
            //1.내 메세지
            if msg.myMsg{
                Spacer(minLength: 25)
                //-1일 경우 메세지를 서버에서 보낸 후 응답받기 전일 경우, -2는 메세지 데이터 끊은 상태에서 보냈을 때
                if msg.message_idx == -1 || msg.message_idx == -2 {
                    //아이콘, 메세지
                    msg_send_error_case
                    
                    //동적링크 메세지인 경우
                }else {
                    Spacer()
                    //메세지 보낸 시각, 읽음처리
                    read_num_and_send_time
                
                    if msg.kinds == "D"{
                        
                      invitation_link
     
                    }
                    else if msg.kinds == "P"{
                        
                        KFImage(URL(string: msg.message!))
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
                        
                        //일반 메세지일 때
                    }
                    else{
                        //메세지 버블, 텍스트뷰
                        ZStack{
                            Image("my_big_bubble")
                                .resizable(capInsets: EdgeInsets(top: 20, leading: 27, bottom: 20, trailing: 27))
                            
                            Text(msg.message!)
                                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/25))
                                .foregroundColor(.proco_black)
                                .padding(.horizontal, UIScreen.main.bounds.width/30)
                                .padding(.vertical, UIScreen.main.bounds.width/30)
                                .layoutPriority(1)
                        }
                        .frame( maxWidth: UIScreen.main.bounds.width*0.6, maxHeight: .infinity)
                    }
                }
            }
            //2.서버 메세지
            else if msg.kinds == "S"{
                Spacer()
                Text(msg.message!)
                    .padding(.all)
                    .background(Color.black.opacity(0.06))
                    .cornerRadius(15)
                Spacer()
                
            }
            //3.상대방 메세지
            else{
                HStack(alignment:.lastTextBaseline){
                    //같은 사람이 연속으로 보낸 메세지이지만 그 연속된 순서중 마지막이 아닌 경우
                    if msg.is_same_person_msg == true && msg.is_last_consecutive_msg == false{
                        Spacer()
                            .frame(width: UIScreen.main.bounds.width/7)
                        message_view

                        VStack{
                            friend_read_num
                        }
                        //같은 사람이 연속으로 보냈고 연속된 순서의 마지막 메세지인 경우
                    }else if msg.is_same_person_msg == true && msg.is_last_consecutive_msg == true{
                        Spacer()
                            .frame(width: UIScreen.main.bounds.width/7)
                        message_view

                        VStack{
                            
                            friend_read_num

                            friend_send_time
                        }
                        //제일 처음으로 보낸 메세지인 경우
                    } else if msg.is_same_person_msg == false && msg.is_last_consecutive_msg == false{
                        
                        //프로필 이미지
                        friend_profile_img
                        VStack(alignment: .leading){
                            friend_nickname
                            message_view

                        }
                        HStack{
                            Spacer()
                            friend_read_num
                        }
                    }else if msg.is_same_person_msg == false && msg.is_last_consecutive_msg == true{
                        //프로필 이미지
                        friend_profile_img

                        VStack(alignment: .leading){
                            friend_nickname
                            message_view

                        }
                        HStack{
                            Spacer()
                            friend_read_num
                            friend_send_time
                        }
                    }
                    Spacer(minLength: 25)
                }
            }
        }
    }
}


private extension ChatRow{
    
    var invitation_link : some View{
        
        //메세지 버블, 텍스트뷰
        ZStack{
//            Image("my_big_bubble")
////                .resizable(capInsets: EdgeInsets(top: 20, leading: 27, bottom: 20, trailing: 27))
//                .resizable(capInsets: EdgeInsets(top: UIScreen.main.bounds.width*0.35, leading: UIScreen.main.bounds.width*0.4, bottom: UIScreen.main.bounds.width*0.35, trailing: UIScreen.main.bounds.width*0.4))
            
            VStack{
                HStack{
                    Spacer()
                    
                    Image("logo")
                        .resizable()
                        .frame(width:141, height:55)
                    Spacer()
                }
                Divider()
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width*0.4, height: UIScreen.main.bounds.width*0.1, alignment: .center)
                    .overlay(
                        VStack{
                            HStack{
                                Spacer()
                                Text("\(nickname)님의 ")
                                    .font(.custom(Font.n_bold, size: 14))
                                    .foregroundColor(.proco_white)
                                Spacer()
                            }
                            
                            HStack{
                                Spacer()
                                Text("약속카드 초대")
                                    .font(.custom(Font.n_bold, size: 14))
                                    .foregroundColor(.proco_white)
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.proco_blue)
                        .cornerRadius(10)
                    )
                Text("약속을 함께해 보세요!")
                    .font(.custom(Font.n_regular, size: 12))
                    .foregroundColor(.proco_black)
                    .padding(.top, UIScreen.main.bounds.width/30)
                
                HStack{
                    Text("약속일 :")
                        .font(.custom(Font.n_bold, size: 10))
                        .foregroundColor(.gray)
                    Text((msg.message?.split(separator: "-")[3]) ?? "")
                        .font(.custom(Font.n_bold, size: 10))
                        .foregroundColor(.gray)
                }
                HStack{
                    Spacer()
                    Text((msg.message?.split(separator: "-")[4]) ?? "")
                        .font(.custom(Font.n_bold, size: 10))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .background(Color.white)
            .padding()
            .border(Color.proco_yellow, width: 2)
            .cornerRadius(10)
        }
        .frame(maxWidth: UIScreen.main.bounds.width*0.6, maxHeight: .infinity)
        .onTapGesture {
            print("동적링크 메세지 클릭: \(String(describing: msg.message))")
            
            //초대하려는 채팅방idx
            let info = msg.message
            NotificationCenter.default.post(name: Notification.clicked_invite_link, object: nil, userInfo: ["clicked_invite_link" : "ok", "info": String(info!) ])
        }
    }
    
    var msg_send_error_case : some View{
        HStack{
            Spacer()
            if msg.message_idx == -1{
                
                Image("msg_sending_icon")
                
            }else if msg.message_idx == -2{
                
                Button(action: {
                    let selected_msg_front = String(self.msg.front_created_at!)
                    let selected_msg_content = msg.message!
                    //임시 채팅방인 경우 temp key가 kinds로 감.
                    let selected_msg_kinds = msg.kinds!
                    print("안보내진 메세지 다시 보내기 클릭 : \(selected_msg_front). \(selected_msg_content), \(selected_msg_kinds)")
                    
                    NotificationCenter.default.post(name: Notification.send_msg_again, object: nil, userInfo: ["send_msg_again" : selected_msg_front, "msg_content": selected_msg_content, "msg_kind" : selected_msg_kinds])
                    
                    self.send_again_alert = true
                }){
                    Image("msg_error_icon")
                        .resizable()
                        .frame(width: 36, height:16)
                }
            }
            if msg.kinds == "P"{
                
                Image(uiImage: SockMgr.socket_manager.load(fileName: msg.front_created_at!)!)
                    .renderingMode(.original)
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width*0.2, maxWidth: UIScreen.main.bounds.width*0.6, minHeight: UIScreen.main.bounds.width*0.2, maxHeight: UIScreen.main.bounds.width*1.2)
                    .cornerRadius(20)
                
            }
            else if msg.kinds == "D"{
                
                    invitation_link
            
            }
            //일반 채팅방의 경우 kinds에 P가 저장되지 않고 temp key를 넣어서 구분못하므로 이 조건으로 이미지인 경우를 확인.
            else if msg.message == msg.front_created_at!{
                
                Image(uiImage: SockMgr.socket_manager.load(fileName: msg.front_created_at!)!)
                    .renderingMode(.original)
                    .resizable()
                    .frame(minWidth: UIScreen.main.bounds.width*0.2, maxWidth: UIScreen.main.bounds.width*0.6, minHeight: UIScreen.main.bounds.width*0.2, maxHeight: UIScreen.main.bounds.width*1.2)
                    .cornerRadius(20)
            }
            else{
                Text(msg.message!)
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(.proco_black)
                    .padding(.all)
                    .background(Color.green.opacity(0.06))
                    .cornerRadius(15)
            }
        }
    }
    
    var read_num_and_send_time : some View{
        VStack{
            Spacer()
            //1분 안에 연속으로 보낸 메세지이지만 연속인데 마지막 메세지가 아닌 경우
            if msg.is_same_person_msg == false && msg.is_last_consecutive_msg == false{
                VStack{
                    Spacer()
                 
                    Text(String(msg.read_num) == "0" ? "" : String(msg.read_num))
                        .font(.custom(Font.n_extra_bold, size: 9))
                        .foregroundColor(.proco_yellow)
                }
                
                //1분 안에 연속으로 보낸 메세지이고 연속인데 마지막인 경우
            }else if msg.is_same_person_msg == true && msg.is_last_consecutive_msg == true{
                VStack{
                    Spacer()
                   
                    Text(String(msg.read_num) == "0" ? "" : String(msg.read_num))
                        .font(.custom(Font.n_extra_bold, size: 9))
                        .foregroundColor(.proco_yellow)
                    
                    Text("\(msg_time_converted)")
                        .font(.custom(Font.n_bold, size: 9))
                        .foregroundColor(.gray)
                }
                //연속으로 보낸 메세지가 아닌 경우
            } else if msg.is_same_person_msg == false && msg.is_last_consecutive_msg == true{
                VStack{
                    Spacer()
                   
                    Text(String(msg.read_num) == "0" ? "" : String(msg.read_num))
                        .font(.custom(Font.n_extra_bold, size: 9))
                        .foregroundColor(.proco_yellow)
                    
                    Text("\(msg_time_converted)")
                        .font(.custom(Font.n_bold, size: 9))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    //서버 메세지 뷰
    var server_msg_view: some View{
        
        Text(msg.message!)
            .font(.custom(Font.n_bold, size: 12))
            .foregroundColor(.proco_black)
            .padding(.all)
            .background(Color.black.opacity(0.06))
            .cornerRadius(15)
    }
    
    
    var message_view : some View{
        HStack{
            if msg.kinds == "C"{
                ZStack{
                    Image("friend_big_bubble")
                        .resizable(capInsets: EdgeInsets(top: 20, leading: 27, bottom: 20, trailing: 27))
                    
                    Text(msg.message!)
                        .font(.custom(Font.n_bold, size: 12))
                        .foregroundColor(.proco_black)
                        .padding(.horizontal, UIScreen.main.bounds.width/30)
                        .padding(.vertical)
                        .layoutPriority(1)
                }
                .frame( maxWidth: UIScreen.main.bounds.width*0.6, maxHeight: .infinity)
                
            }else if msg.kinds == "P"{
                
                KFImage(URL(string: msg.message!))
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
                //동적링크인 경우
            }else if msg.kinds == "D"{
                //카드 초대 링크 뷰
                invitation_link
              
            }
        }
    }
    
    var friend_read_num : some View{
        Text(String(msg.read_num) == "0" ? "" : String(msg.read_num))
            .font(.custom(Font.n_extra_bold, size: 9))
            .foregroundColor(.proco_yellow)
    }
    
    var friend_send_time : some View{
        Text("\(msg_time_converted)")
            .font(.custom(Font.n_bold, size: 9))
            .foregroundColor(.gray)
    }
    
    var friend_profile_img : some View{
        Image((msg.profilePic == "" ? "main_profile_img" : msg.profilePic) ??  "main_profile_img")
            .resizable()
            .frame(width: 47.46, height: 47.46)
    }
    
    var friend_nickname : some View{
        Text(nickname)
            .font(.custom(Font.n_bold, size: 11))
    }
    
}



