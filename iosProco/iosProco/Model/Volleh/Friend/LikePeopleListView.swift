//
//  LikePeopleListView.swift
//  proco
//
//  Created by 이은호 on 2021/04/27.
//

import SwiftUI
import Kingfisher

struct LikePeopleListView : View{
    
    var card_idx : Int
    @ObservedObject var main_vm : FriendVollehMainViewmodel
    
    var body: some View{
        
        VStack{
            ForEach(self.main_vm.card_like_user_model){user in
                LikeUserRow(like_user_model: user)
            }
            Spacer()
        }
        .onAppear{
            main_vm.get_like_card_users(card_idx: card_idx)
        }
    }
}

struct LikeUserRow : View{
    
    var like_user_model : Creator
    //이미지 원처럼 보이게 하기 위해 scale값을 곱함.
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width/6, height:  UIScreen.main.bounds.width/6)) |> RoundCornerImageProcessor(cornerRadius: 40)
    
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
    }
}

