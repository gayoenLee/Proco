//
//  MyLikeCardsListView.swift
//  proco
//
//  Created by 이은호 on 2021/05/31.
//

import SwiftUI

struct MyLikeCardsListView: View {
    @Environment(\.presentationMode) var presentation

    @ObservedObject var main_vm : SettingViewModel
    @StateObject var friend_vm = FriendVollehMainViewmodel()
    @StateObject var meeting_vm = GroupVollehMainViewmodel()
    
    //친구 카드 상세 페이지 이동값
    @State private var show_friend_info : Bool = false
    //모임 카드 상세 페이지 이동값
    @State private var go_meeting_card_detail : Bool = false
    //온오프 버튼 구분위함
    @State private var state_on : Int? = 0
    var body: some View {
       
        VStack{
            
            HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                }, label: {
                    
                    Image("white_left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                })
                
                Spacer()
                Text("내가 좋아요한 카드")
                    .font(.custom(Font.t_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                
                Spacer()

            }
            .padding()
            
            ScrollView{
            HStack{
                Text("친구카드")
                    .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                    .foregroundColor(.proco_black)
                Spacer()
                
            }.padding([.leading, .top])
            
                ForEach(self.main_vm.friend_card_model){card in

                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(.proco_white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                        .overlay(
                            MyLikeFriendCardsRow(main_vm: self.main_vm, friend_card_model: card, current_card_index: self.main_vm.get_index(item: card)))
                        .onTapGesture {
                            print("친구 카드 한 개 클릭: \(card.card_idx!)")
//                            self.friend_vm.friend_info_struct = GetFriendListStruct(idx: card.creator?.idx, nickname: card.creator?.nickname, profile_photo_path: card.creator?.profile_photo_path ?? "", state: 0, kinds: String(card.is_favor_friend!))
//                            self.show_friend_info = true
                        }


                }
            
            HStack{
                Text("모임 카드")
                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                .foregroundColor(.proco_black)
                Spacer()
                
            }
            .padding(.leading)
                
                ForEach(self.main_vm.group_card_model){card in

                    RoundedRectangle(cornerRadius: 25.0)
                        .foregroundColor(.proco_white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .frame(width: UIScreen.main.bounds.width*0.95, height: UIScreen.main.bounds.width*0.4)
                        .overlay(
                            MyLikeGroupCardsRow(main_vm: self.main_vm, group_card_model: card, current_card_index: self.main_vm.get_group_card_index(item: card)))
                        .onTapGesture {
                            print("모임 카드 한 개 클릭: \(card.card_idx!)")
                            self.meeting_vm.selected_card_idx = card.card_idx!
                            self.go_meeting_card_detail = true
                        }
                }
            }
            
            NavigationLink("",destination: GroupVollehCardDetail(main_vm: self.meeting_vm, calendar_vm: CalendarViewModel()).navigationBarHidden(true), isActive: self.$go_meeting_card_detail)
            
        }.onAppear{
            print("내가 좋아요한 카드 리스트뷰 나옴.")
            self.main_vm.get_liked_cards()
        }
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        //.navigationBarTitle("내가 좋아요한 카드")
        
    }
}

struct MyLikeFriendCardsRow : View{
    @StateObject var main_vm : SettingViewModel
    @State var friend_card_model : FriendVollehCardStruct
    //선택한 카드의 인덱스값
    var current_card_index : Int

    @State private var expiration_at = ""
    var body: some View{
        HStack{
            //카드 배경 위에 프로필 이미지, 이름, 상태타입, 시간 및 날짜, 태그
            //카드 1개 hstack 2칸으로 분할해서 수직 쌓기
            VStack{
                HStack{
                    //채팅방에서 내 카드 리스트를 보여줄 때는 서버에서 creator정보 안줘서 소켓 클래스에서 가져옴.
                    card_owner_img
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
                tags

                HStack{

                    like_icon

                    Spacer()
                    Image(self.friend_card_model.lock_state == 0 ? "lock_public" : "lock_private")
                        .padding(.trailing)

                }
                .padding(.bottom, UIScreen.main.bounds.width/20)
            }
        }
        .onAppear{
            self.expiration_at = String.dot_form_date_string(date_string: friend_card_model.expiration_at!)
        }
    }
}

private extension MyLikeFriendCardsRow{

    var like_icon : some View{
        HStack{
        Button(action: {
            if self.friend_card_model.like_state == 0{
            //좋아요 클릭 이벤트
            print("좋아요 클릭: \(String(describing: self.friend_card_model.like_state))")

            self.main_vm.send_like_card(card_idx:  self.friend_card_model.card_idx!)

            }else{

                print("좋아요 취소")

            self.main_vm.cancel_like_card(card_idx:  self.friend_card_model.card_idx!)
            }
        }){

            Image(self.friend_card_model.like_state == 0 ? "heart" : "heart_fill")
            .resizable()
            .frame(width: UIScreen.main.bounds.width/17, height: UIScreen.main.bounds.width/20)
            .padding([.leading], UIScreen.main.bounds.width/20)
        }

            Text(friend_card_model.like_count > 0 ? "좋아요 \(friend_card_model.like_count)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
                .foregroundColor(.proco_red)
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.clicked_like), perform: {value in
            print("내 카드 좋아요 클릭 통신 완료 받음.: \(value)")

            if let user_info = value.userInfo{
                let check_result = user_info["clicked_like"]
                print("내 카드 좋아요 데이터 확인: \(check_result)")

                if check_result as! String == "ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("내 카드 좋아요 클릭한 idx: \(card_idx)")

                    if card_idx == self.friend_card_model.card_idx{

                        self.friend_card_model.like_count += 1
                        self.friend_card_model.like_state = 1

                }

                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.friend_card_model.card_idx{
                        self.friend_card_model.like_count -= 1
                        self.friend_card_model.like_state = 0

                }
            }
            }
        })
    }


    var tags: some View{

        HStack{

            //TODO: if문 - 카드 삭제시 리스트 갯수 업데이트 안돼서 문제 발생 아래 코드로 해결. 나중에 다시 볼 것.
            if main_vm.friend_card_model.count > self.current_card_index{

                //태그들도 리스트를 포함하고 있기 때문에 여기서 다시 foreach문 돌림.
                ForEach(main_vm.friend_card_model[self.current_card_index].tags!.indices, id: \.self){ index in
                    if index == 0{

                    }else{
                    HStack{

                        Image("tag_sharp")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                            .padding([.leading], UIScreen.main.bounds.width/20)

                        Text("\(friend_card_model.tags![index].tag_name ?? "")")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(.proco_black)
                    }
                    }
                }
            }

            Spacer()
        }
    }

    var nickname_and_category: some View{

            VStack{
                ///카테고리

                //TODO: if문 - 카드 삭제시 리스트 갯수 업데이트 안돼서 문제 발생 아래 코드로 해결. 나중에 다시 볼 것.
                if main_vm.friend_card_model.count > self.current_card_index{

                 Capsule()
                    .foregroundColor(friend_card_model.tags![0].tag_name! == "사교/인맥" ? .proco_yellow : friend_card_model.tags![0].tag_name! == "게임/오락" ? .proco_pink : friend_card_model.tags![0].tag_name! == "문화/공연/축제" ? .proco_olive : friend_card_model.tags![0].tag_name! == "운동/스포츠" ? .proco_green : friend_card_model.tags![0].tag_name! == "취미/여가" ? .proco_mint : friend_card_model.tags![0].tag_name! == "스터디" ? .proco_blue : .proco_red)
                      .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width/17)
                      .overlay(
                    Text("\(friend_card_model.tags![0].tag_name!)")
                        .font(.custom(Font.t_extra_bold, size: 10))
                        .foregroundColor(.proco_white)
                        )
                        }

            //친구 이름
                Text(friend_card_model.creator!.nickname)
                .font(.custom(Font.n_bold, size: 15))
                .foregroundColor(.proco_black)
        }

    }

    var card_owner_img : some View{
        VStack{

            //프로필 이미지는 없을 수 있기 때문에 나눔.
            if friend_card_model.creator?.profile_photo_path == nil || friend_card_model.creator?.profile_photo_path == ""{

                    Image("main_profile_img")
                        .resizable()
                        .background(Color.gray.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .cornerRadius(50)
                        .scaledToFit()
                        .padding([.trailing], UIScreen.main.bounds.width/30)

                }else{

                    Image((friend_card_model.creator?.profile_photo_path!)!)
                        .resizable()
                        .background(Color.gray.opacity(0.5))
                        .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                        .cornerRadius(50)
                        .scaledToFit()
                        .padding([.trailing], UIScreen.main.bounds.width/30)
                }


        }
    }
}
struct MyLikeGroupCardsRow : View{

    @StateObject var main_vm : SettingViewModel
    @State var group_card_model : GroupCardStruct

    var current_card_index : Int
    @State private var expiration_at = ""


    var body: some View{
        HStack{
            VStack{
                HStack{
                    if group_card_model.card_photo_path != nil || group_card_model.card_photo_path != ""{
                        card_img
                    }

                    if !group_card_model.tags!.isEmpty{
                    category_and_title
                    }
                    Spacer()
                    //카드 날짜
                    card_date
                }

                HStack{
                    current_user_num
                    Spacer()
                    lock
                }
                HStack{

                    like_icon_num

                    Spacer()
                    meeting_kinds_and_location
                }
            }
        }
        .onAppear{
            self.expiration_at = String.dot_form_date_string(date_string: group_card_model.expiration_at!)
        }
    }
}


private extension MyLikeGroupCardsRow{
    var card_img : some View{
        HStack{
            Image( self.group_card_model.card_photo_path ?? "")
                .frame(width: 43, height: 43)
        }
        .padding(.leading)
    }

    var category_and_title : some View{
        VStack{
            Capsule()
                .foregroundColor(group_card_model.tags![0].tag_name == "사교/인맥" ? .proco_yellow : group_card_model.tags![0].tag_name == "게임/오락" ? .proco_pink : group_card_model.tags![0].tag_name == "문화/공연/축제" ? .proco_olive : group_card_model.tags![0].tag_name == "운동/스포츠" ? .proco_green : group_card_model.tags![0].tag_name == "취미/여가" ? .proco_mint : group_card_model.tags![0].tag_name == "스터디" ? .proco_blue : .proco_red)
                .frame(width: UIScreen.main.bounds.width*0.15, height: UIScreen.main.bounds.width/17)
                .overlay(
                    Text("\(group_card_model.tags![0].tag_name)")
                .font(.custom(Font.t_extra_bold, size: 13))
                .foregroundColor(.proco_white)
                )

            Text("\(group_card_model.title!)")
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
            Image(self.group_card_model.cur_user ?? 0 > 0 ? "meeting_user_num_icon" : "")
                .resizable()
                .frame(width: 11, height: 11)

            Text(self.group_card_model.cur_user ?? 0 > 0 ? "\(self.group_card_model.cur_user!)명" : "")
                .font(.custom("", size: 13))
                .foregroundColor(.proco_black)
        }
        .padding(.leading)
    }

    var lock : some View{
        HStack{
            Image(self.group_card_model.lock_state == 0 ? "lock_public" : "lock_private")
                .resizable()
                .frame(width: 14, height: 11)
        }
        .padding(.trailing)
    }

    var like_icon_num : some View{
        HStack{
            Button(action: {

                if self.group_card_model.like_state == 0{

                    print("모임 카드 좋아요 클릭")
                    self.main_vm.send_like_card(card_idx: self.group_card_model.card_idx!)

                }else{
                    print("모임 카드 좋아요 취소")
                    self.main_vm.cancel_like_card(card_idx: self.group_card_model.card_idx!)
                }

            }){
            Image(group_card_model.like_state == 0 ? "heart" : "heart_fill")
            .resizable()
            .frame(width: 14, height: 12)

            }
            Text(group_card_model.like_count ?? 0 > 0 ? "좋아요\(group_card_model.like_count!)개" : "")
                .font(.custom(Font.t_extra_bold, size: 12))
            .foregroundColor(.proco_red)

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

                    if card_idx == self.group_card_model.card_idx{

                        self.group_card_model.like_count! += 1
                        self.group_card_model.like_state = 1

                }

                }else if check_result as! String == "canceled_ok"{
                    let card = user_info["card_idx"] as! String
                    let card_idx = Int(card)
                    print("좋아요 취소한 idx: \(card_idx)")
                    if card_idx == self.group_card_model.card_idx{
                        self.group_card_model.like_count! -= 1
                        self.group_card_model.like_state = 0

                }
            }
            }
        })
    }

    var meeting_kinds_and_location : some View{
        HStack{
            if group_card_model.kinds == "오프라인 모임"{
                Image("meeting_location_icon")
                    .resizable()
                    .frame(width: 12, height: 14)
                Text("\(self.group_card_model.address!)")
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
