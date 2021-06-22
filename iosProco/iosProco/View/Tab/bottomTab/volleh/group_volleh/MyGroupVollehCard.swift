//
//  MyGroupVollehCard.swift
//  proco
//
//  Created by 이은호 on 2020/12/27.
//

import SwiftUI
import Kingfisher

struct MyGroupVollehCard: View {
    @ObservedObject var main_vm : GroupVollehMainViewmodel
    
    //binding으로 했더니 카드 삭제시 계속 index에러 나서 state로 바꾼 것.
    @State var my_group_card : GroupCardStruct
    
    var current_card_index : Int
    @State private var expiration_at = ""
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 43, height: 43)) |> RoundCornerImageProcessor(cornerRadius: 5)
    
    //모임 카드 이미지가 없는 경우 왼쪽에 공백 생기는 문제 해결 위함.
    var has_card_img : Bool{
        if self.my_group_card.card_photo_path == "" || self.my_group_card.card_photo_path == nil{
            return false
        }else{
            return true
        }
    }
    var body: some View {
        //카드 1개
        HStack{
            VStack{
                HStack{
                    if has_card_img{
                        card_img
                    }
                    if SockMgr.socket_manager.is_from_chatroom{
                        category_and_title
                        
                    }
                   else if !my_group_card.tags!.isEmpty{
                    category_and_title
                    }
                    Spacer()
                    //카드 날짜
                    card_date
                }
                .padding(.leading)

                
                HStack{
                    current_user_num
                    Spacer()
                    lock
                }
                HStack{
                    if SockMgr.socket_manager.is_from_chatroom{}else{
                    like_icon_num
                    }
                    Spacer()
                    meeting_kinds_and_location
                }
            }

        }
        .onAppear{
            self.expiration_at = String.dot_form_date_string(date_string: my_group_card.expiration_at!)
           print("날짜 확인: \(self.expiration_at)")
            print("모임 카드 이미지 확인: \(self.my_group_card.card_photo_path ?? "")")
        }
        //화면 하나에 카드 여러개 보여주기 위해 조정하는 값
        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.09)
        .onReceive(NotificationCenter.default.publisher(for: Notification.get_data_finish), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["group_card_edited"]{
                print("모임 카드 편집 노티 \(data)")
                
                if data as! String == "ok"{
                    
                  let card_idx = user_info["card_idx"] as! String
                    
                    //편집한 카드인 경우
                    if self.my_group_card.card_idx! == Int(card_idx){
                      
                        let card_photo_path = user_info["card_photo_path"] as! String
                        let tags = user_info["tags"] as! [Tags]
                        
                        print("노티에서 받은 태그 : \(tags)")
                        
                        self.my_group_card.card_photo_path = card_photo_path
                        self.my_group_card.title = self.main_vm.card_name
                        self.my_group_card.address = self.main_vm.input_location
                        self.my_group_card.expiration_at = self.main_vm.card_expire_time
                        self.my_group_card.tags =  tags
                        
                        self.expiration_at = String.dot_form_date_string(date_string: my_group_card.expiration_at!)
                        //편집한 데이터 집어넣고는 publish변수에 있던 값들 없애주기는 노티를 받은 뷰에서 진행함.
                        self.main_vm.input_location = ""
                        self.main_vm.card_expire_time = ""
                        self.main_vm.input_introduce = ""
                        self.main_vm.card_name = ""
                        self.main_vm.user_selected_tag_list = []
                        self.main_vm.user_selected_tag_set = []
                        print("편집 후 값 없앴는지 확인 : \( self.main_vm.card_name)")
                    }
                }
            }else{
                print("모임카드 편집 노티 아님")
            }
        })
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

extension MyGroupVollehCard{
    
    var card_img : some View{
        
        HStack{
                KFImage(URL(string: self.my_group_card.card_photo_path!))
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
        .padding(.leading)
        .hidden(self.my_group_card.card_photo_path == "" || self.my_group_card.card_photo_path == nil)
    }
    
    var category_and_title : some View{
        VStack{
            Capsule()
                .foregroundColor(my_group_card.tags![0].tag_name == "사교/인맥" ? .proco_yellow : my_group_card.tags![0].tag_name == "게임/오락" ? .proco_pink : my_group_card.tags![0].tag_name == "문화/공연/축제" ? .proco_olive : my_group_card.tags![0].tag_name == "운동/스포츠" ? .proco_green : my_group_card.tags![0].tag_name == "취미/여가" ? .proco_mint : my_group_card.tags![0].tag_name == "스터디" ? .proco_blue : .proco_red)
                .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width/17)
                .overlay(
                    Text("\(my_group_card.tags![0].tag_name)")
                        .font(.custom(Font.t_extra_bold, size: 13))
                .foregroundColor(.proco_white)
                )
            
            Text("\(my_group_card.title!)")
                .font(.custom(Font.n_extra_bold, size: 18))
                .foregroundColor(.proco_black)
        }
    }
    
    var card_date : some View{
        VStack{
            Image("card_label_blue")
                .resizable()
                .frame(width: UIScreen.main.bounds.width*0.3, height: UIScreen.main.bounds.width/14)
                .overlay(
                    
            //카드 만료일
                    Text("\(self.expiration_at)")
                .font(.custom(Font.n_extra_bold, size: 15))
                .foregroundColor(.proco_white))
                .padding(.top, UIScreen.main.bounds.width/20)
            Spacer()
        }
    }
    
    var current_user_num : some View{
        HStack{
            Image(self.my_group_card.cur_user ?? 0 > 0 ? "meeting_user_num_icon" : "")
                .resizable()
                .frame(width: 11, height: 11)
            
            Text(self.my_group_card.cur_user ?? 0 > 0 ? "\(self.my_group_card.cur_user!)명" : "")
                .font(.custom("", size: 13))
                .foregroundColor(.proco_black)
        }
        .padding(.leading)
    }
    
    var lock : some View{
        HStack{

            Button(action: {
                print("잠금 버튼 클릭")
                //0: 안 잠금 1: 잠금
                if self.my_group_card.lock_state == 0{
                    print("카드 잠그기")
                    self.main_vm.lock_card(card_idx: self.my_group_card.card_idx!, lock_state: 1)
                }else{
                    print("카드 열기")
                    
                    self.main_vm.lock_card(card_idx: self.my_group_card.card_idx!, lock_state: 0)
                }
            }){
                Image(self.my_group_card.lock_state == 0 ? "lock_public" : "lock_private")
                    .resizable()
                    .frame(width: 15, height: 16.61)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.event_finished), perform: {value in
                print("내 카드 잠금 통신 완료 받음.: \(value)")
                
                if let user_info = value.userInfo, let check_result = user_info["lock"]{
                    
                    print("내 카드 잠금 데이터 확인: \(check_result)")
                    
                    if check_result as! String == "잠금"{
                        let card = user_info["card_idx"] as! String
                        let card_idx = Int(card)
                        print("내 카드 잠금한 idx: \(card_idx)")
                        
                        if card_idx == self.my_group_card.card_idx{
                            
                            self.my_group_card.lock_state = 1
                    }
                    }else if check_result as! String == "잠금해제"{
                        
                        let card = user_info["card_idx"] as! String
                        let card_idx = Int(card)
                        print("잠금 취소한 idx: \(card_idx)")
                        if card_idx == self.my_group_card.card_idx{
                            self.my_group_card.lock_state = 0
                    }
                }
                }
            })
            
        }
    .padding(.trailing)
    }
    
    var like_icon_num : some View{
        HStack{
            Button(action: {
                
                if self.my_group_card.like_state == 0{
                   
                    print("모임 카드 좋아요 클릭")
                    self.main_vm.send_like_card(card_idx: self.my_group_card.card_idx!)
                    
                }else{
                    print("모임 카드 좋아요 취소")
                    self.main_vm.cancel_like_card(card_idx: self.my_group_card.card_idx!)
                }
                
            }){
            Image(my_group_card.like_state == 0 ? "heart" : "heart_fill")
            .resizable()
            .frame(width: 14, height: 12)
            
            }
            Text(my_group_card.like_count ?? 0 > 0 ? "좋아요\(my_group_card.like_count!)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
            .foregroundColor(.proco_black)

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
                    print("내 카드 좋아요 클릭한 idx: \(card_idx)")
                    
                    if card_idx == self.my_group_card.card_idx{
                        
                        self.my_group_card.like_count! += 1
                        self.my_group_card.like_state = 1

                }
                    
                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.my_group_card.card_idx{
                        self.my_group_card.like_count! -= 1
                        self.my_group_card.like_state = 0
                        
                }
            }
            }
        })
    }
    
    var meeting_kinds_and_location : some View{
        HStack{
            if my_group_card.kinds == "오프라인 모임"{
                Image("meeting_location_icon")
                    .resizable()
                    .frame(width: 12, height: 14)
                Text("\(self.my_group_card.address!)")
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(Color.proco_black)
                
            }else{
                
                Image("small_chat_bubble_icon")
                    .resizable()
                    .frame(width: 12, height: 14)
                Text("온라인 채팅")
                    .font(.custom(Font.n_bold, size: 12))
                    .foregroundColor(Color.proco_black)
            }
        }
        .padding([.trailing, .bottom])
    }
}


