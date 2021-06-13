//
//  LikePeopleListView.swift
//  proco
//
//  Created by 이은호 on 2021/04/27.
//

import SwiftUI

struct LikePeopleListView : View{
    
    var card_idx : Int
    @ObservedObject var main_vm : FriendVollehMainViewmodel
    
    var body: some View{
              
        VStack{
            ForEach(self.main_vm.card_like_user_model){user in
                LikeUserRow(like_user_model: user)
            }
        }
        .onAppear{
            main_vm.get_like_card_users(card_idx: card_idx)
        }
    }
}

struct LikeUserRow : View{

    var like_user_model : Creator

    var body: some View{
        HStack{
            Image(like_user_model.profile_photo_path == "" || like_user_model.profile_photo_path == nil ? "main_profile_img" : like_user_model.profile_photo_path!)
                .resizable()
                .frame(width: UIScreen.main.bounds.width/6, height: UIScreen.main.bounds.width/6)
                .scaledToFit()
                .padding([.trailing], UIScreen.main.bounds.width/30)

            Text(like_user_model.nickname)
                .font(.custom(Font.n_bold, size: UIScreen.main.bounds.width/20))
                .foregroundColor(.proco_black)
        }
    }
}

