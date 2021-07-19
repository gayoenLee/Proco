//
//  MyFriendRequestRow.swift
//  proco
//
//  Created by 이은호 on 2021/07/19.
//

import SwiftUI

struct MyFriendRequestRow: View {
    
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    @State var request_struct : MyRequestFriendModel
    
    @Binding var friend_total_num : Int
    
    var body: some View {
        HStack{
            //프로필 사진은 의무가 아니므로 프로필 사진이 없는 경우 추가
            user_img
            
            user_nickname
            Spacer()

            HStack{
                  
                    requested_btn
                    cancel_request_btn
                 
                
            }.padding()
        }
        .transition(.move(edge: .leading))

    }
}

extension MyFriendRequestRow{
    
    var user_img : some View{
        HStack{
        if request_struct.profile_photo_path == nil || request_struct.profile_photo_path == ""{
            Image("main_profile_img")
                .resizable()
                .frame(width: 41.5, height: 41.5)
            
        }else{
            Image(request_struct.profile_photo_path!)
                .resizable()
                .frame(width: 41.5, height: 41.5)
                .cornerRadius(50)
        }
        }
    }
    
    var user_nickname: some View{
        Text(request_struct.nickname!)
            .font(.custom(Font.n_bold, size: 16))
            .foregroundColor(Color.proco_black)
    }
    
    var requested_btn : some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_sky_blue)
            .overlay(
                    Text("요청됨")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.proco_blue)
            )
    }
    
    var cancel_request_btn: some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_dark_white)
            .overlay(
                Button(action: {
                    print("요청 취소하려는 친구 idx: \(request_struct.idx!)")
                    self.manage_viewmodel.cancel_request_friend(f_idx: request_struct.idx!)
                }){
                    Text("취소")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.gray)
                } )
    }
}
