//
//  friend_state_main_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/11.
// 친구들이 만든 카드들 리스트 나오는 화면(탭뷰에 넣기 위해 만드는 화면)
//필요 데이터 : 친구 이름, 친구 프로필 이미지, 친구 상태(초록색 동그라미), 카드 타입, 태그, 카드 시간

import SwiftUI
import Combine


//친구 카드 리스트 뷰
struct FriendCardListView : View{
    
    @ObservedObject var main_vm: FriendVollehMainViewmodel
    @State var friend_volleh_card_struct : FriendVollehCardStruct
    
    var current_card_index : Int
    
    @State var show = false
    @State private var expiration_at : String = ""
    
    var body: some View{
        
        //카드 1개
        HStack{
            //카드 배경 위에 프로필 이미지, 이름, 상태타입, 시간 및 날짜, 태그
            //카드 1개 hstack 2칸으로 분할해서 수직 쌓기
            VStack{
                HStack{
                    //프로필 이미지
                    owner_img
                        .padding([.leading, .top], UIScreen.main.bounds.width/20)
                    nickname_and_category
                    Spacer()
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
                
                HStack{
                //여기에 태그 나오도록.
                if main_vm.friend_volleh_card_struct.count > self.current_card_index{
                    //태그들도 리스트를 포함하고 있기 때문에 여기서 다시 foreach문 돌림.
                    //TODO 태그 없는 경우 있음.
                    ForEach(main_vm.friend_volleh_card_struct[self.current_card_index].tags!.indices, id: \.self){ index in
                        if index == 0 {
                            
                        }else{
                        HStack{
                            Image("tag_sharp")
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                                .padding([.leading], UIScreen.main.bounds.width/20)
                            
                            Text("#\(String(friend_volleh_card_struct.tags![index].tag_name!) )")
                                .font(.custom(Font.n_bold, size: 15))
                                .foregroundColor(.proco_black)
                        }
                        }
                    }
                }
            }
                HStack{
                    like_icon
                    Spacer()
                    Image(self.friend_volleh_card_struct.lock_state == 0 ? "lock_public" : "lock_private")
                }
                .padding(.bottom, UIScreen.main.bounds.width/20)
            }
        }
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.09)
        .padding([.top, .bottom], UIScreen.main.bounds.width/20)
        .onAppear{
            self.expiration_at = String.dot_form_date_string(date_string: friend_volleh_card_struct.expiration_at!)
            
        }
        
    }
}

extension FriendCardListView{
    var owner_img : some View{
        HStack{
         if friend_volleh_card_struct.creator?.profile_photo_path == nil || friend_volleh_card_struct.creator?.profile_photo_path == ""{
             Image("main_profile_img")
                 .resizable()
                 .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                 .scaledToFit()
                .padding([.trailing], UIScreen.main.bounds.width/30)
                 
             }else{
                 
                 Image((friend_volleh_card_struct.creator?.profile_photo_path!)!)
                     .resizable()
                     .background(Color.gray.opacity(0.5))
                     .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                     .cornerRadius(50)
                     .scaledToFit()
                     .padding([.trailing], UIScreen.main.bounds.width/30)
             }
        }
    }
    
    var nickname_and_category : some View{
        HStack{
            VStack{
                ///카테고리
                if SockMgr.socket_manager.is_from_chatroom{
                        
                            //카테고리 종류별로 색깔 매치되도록 변경해야 함.
                    Capsule()
                      .foregroundColor(.proco_green)
                        .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width/17)
                        .overlay(
                    Text("\(friend_volleh_card_struct.tags![0].tag_name!)")
                        .font(.custom(Font.t_extra_bold, size: UIScreen.main.bounds.width/25))
                        .foregroundColor(.proco_white)
                        )
                }else{
                //TODO: if문 - 카드 삭제시 리스트 갯수 업데이트 안돼서 문제 발생 아래 코드로 해결. 나중에 다시 볼 것.
                if main_vm.friend_volleh_card_struct.count > self.current_card_index{
                    
                    Capsule()
                      .foregroundColor(.proco_green)
                        .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width/17)
                        .overlay(
                    Text("\(friend_volleh_card_struct.tags![0].tag_name!)")
                        .font(.custom(Font.t_extra_bold, size: 10))
                        .foregroundColor(.proco_white)
                        )
                        }
                    }
                
            ///내 닉네임
            //채팅방에서 내 카드 리스트를 보여줄 때는 서버에서 creator정보 안줘서 소켓 클래스에서 가져옴.
            if SockMgr.socket_manager.is_from_chatroom{
                
                Text(ChatDataManager.shared.my_nickname!)
                    .font(.custom(Font.n_bold, size: 15))
                    .foregroundColor(.proco_black)
                
            }else{
            //친구 이름
                Text(friend_volleh_card_struct.creator!.nickname)
                .font(.custom(Font.n_bold, size: 15))
                .foregroundColor(.proco_black)
            }
        }
        }
    }
    
    var like_icon : some View{
        HStack{
        Button(action: {
            if self.friend_volleh_card_struct.like_state == 0{
            //좋아요 클릭 이벤트
            print("좋아요 클릭: \(String(describing: self.friend_volleh_card_struct.like_state))")
                
            self.main_vm.send_like_card(card_idx: self.friend_volleh_card_struct.card_idx!)
                
            }else{
                
                print("좋아요 취소")
            
            self.main_vm.cancel_like_card(card_idx: self.friend_volleh_card_struct.card_idx!)
            }
        }){
            
            Image(self.friend_volleh_card_struct.like_state == 0 ? "heart" : "heart_fill")
            .resizable()
            .frame(width: UIScreen.main.bounds.width/17, height: UIScreen.main.bounds.width/20)
            .padding([.leading], UIScreen.main.bounds.width/20)
        }
            
            Text(friend_volleh_card_struct.like_count > 0 ? "좋아요 \(friend_volleh_card_struct.like_count)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
                .foregroundColor(.proco_red)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("친구카드 좋아요 클릭 통신 완료 받음.: \(value)")
            
            if let user_info = value.userInfo{
                let check_result = user_info["clicked_like"]
                print("친구카드 좋아요 데이터 확인: \(check_result)")
                
                if check_result as! String == "ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("친구카드 좋아요 클릭한 idx: \(card_idx)")
                    
                    if card_idx == self.friend_volleh_card_struct.card_idx{
                        
                        self.friend_volleh_card_struct.like_count += 1
                        self.friend_volleh_card_struct.like_state = 1

                }
                    
                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("친구카드 좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.friend_volleh_card_struct.card_idx{
                        self.friend_volleh_card_struct.like_count -= 1
                        self.friend_volleh_card_struct.like_state = 0
                        
                }
            }
            }
        })
    }
}
