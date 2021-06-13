//
//  LikeUserCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/12.
//

import SwiftUI
import Kingfisher

struct LikeUserCell: View {
    
    @State var like_user_model: LikeUserListModel
    
    var body: some View {
        HStack{
            
            Image((like_user_model.profile_photo_path! == "" ? "main_profile_img" : like_user_model.profile_photo_path)!)
                .resizable()
                .frame(width: 41.5, height: 41.5)

            Text(like_user_model.nickname)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
                      Spacer()
        }
        .padding()
    }
}
