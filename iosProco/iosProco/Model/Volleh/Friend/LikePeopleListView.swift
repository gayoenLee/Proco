//
//  LikePeopleListView.swift
//  proco
//
//  Created by 이은호 on 2021/04/27.
// 친구 쪽에서만 쓰임

import SwiftUI
import Kingfisher

struct LikePeopleListView : View{
    @Environment(\.presentationMode) var presentation
    var card_idx : Int
    @ObservedObject var main_vm : FriendVollehMainViewmodel
    @State private var show_dialog : Bool = false
    @State private var state_on : Int? = 0
    var body: some View{
        NavigationView{
        VStack{
            ForEach(self.main_vm.card_like_user_model){user in
                LikeUserRow(main_vm : self.main_vm, like_user_model: user, show_dialog: self.$show_dialog)
            }
            Spacer()
        }
        .onAppear{
            main_vm.get_like_card_users(card_idx: card_idx)
        }
        .overlay(FriendStateDialog(main_vm: self.main_vm, group_main_vm: GroupVollehMainViewmodel(), calendar_vm: CalendarViewModel(),show_friend_info: $show_dialog, socket: SockMgr.socket_manager, state_on: self.$state_on, is_friend : true))
        .navigationBarTitle("좋아요한 사람", displayMode: .inline)
        .navigationBarItems(leading:
        Button(action: {
            print("뒤로 가기 클릭")
            presentation.wrappedValue.dismiss()
        }){
            Image("left")
        })
        }
    }
}

struct LikeUserRow : View{
    
    @StateObject var main_vm : FriendVollehMainViewmodel

    var like_user_model : Creator
    //이미지 원처럼 보이게 하기 위해 scale값을 곱함.
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width/6, height:  UIScreen.main.bounds.width/6)) |> RoundCornerImageProcessor(cornerRadius: 40)
    @Binding var show_dialog : Bool
    
    var body: some View{
        HStack{
            if like_user_model.profile_photo_path == "" || like_user_model.profile_photo_path == nil {
                
                Image( "main_profile_img")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                    .scaledToFit()
                    .padding([.trailing], UIScreen.main.bounds.width/30)
                
            }else{
                
                KFImage(URL(string: like_user_model.profile_photo_path!))
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
            
            Text(like_user_model.nickname)
                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                .foregroundColor(.proco_black)
            Spacer()
        }
        .onTapGesture {
            
            if like_user_model.idx == Int(self.main_vm.my_idx!){}else{
            self.main_vm.friend_info_struct = GetFriendListStruct(idx: like_user_model.idx,nickname: like_user_model.nickname, profile_photo_path: like_user_model.profile_photo_path ?? "", state: 0, kinds:  "")
            self.show_dialog = true
            }
        }
    }
}

