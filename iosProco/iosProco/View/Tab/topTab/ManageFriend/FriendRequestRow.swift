//
//  FriendRequestRow.swift
//  proco
//
//  Created by 이은호 on 2021/05/27.
//

import SwiftUI

//친구 신청 받은 목록 row
struct FriendRequestRow: View{
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    @State var request_struct : FriendRequestListStruct
    
    @Binding var friend_total_num : Int
    
    var body: some View{
        
        HStack{
            //프로필 사진은 의무가 아니므로 프로필 사진이 없는 경우 추가
            user_img
            
            user_nickname
            
            Spacer()
            HStack{
                if request_struct.processed == "" || request_struct.processed == nil{
                    //수락, 거절 버튼
                    accept_btn
              
                    decline_btn
                 
                }
            }.padding()
        }
        .transition(.slide)
    }
}

extension FriendRequestRow{
    
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
    
    var accept_btn: some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_sky_blue)
            .overlay(
                Button(action: {
                    //신청한 친구의 idx값 뷰모델에 저장하고 다시 한 번 alert창 띄우기
                                       manage_viewmodel.selected_friend_request_idx = self.request_struct.idx!
                                       print("수락하려는 친구의 idx저장했는지 확인 : \(manage_viewmodel.selected_friend_request_idx)")

                    //수락하려는 리스트의 row값 저장해서 delete할 때 사용
                    manage_viewmodel.accept_friend_request()

                }){
                    Text("수락")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.proco_blue)
                }
            )
        
    }
    
    var decline_btn : some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_dark_white)
            .overlay(
                Button(action: {
                    manage_viewmodel.selected_friend_request_idx = self.request_struct.idx!
                    manage_viewmodel.decline_friend_request()
                }){
                    Text("거절")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.gray)
                } )
    }
    
    var accepted_btn : some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_sky_blue)
            .overlay(
                Text("수락됨")
                    .font(.custom(Font.n_bold, size: 13))
                    .foregroundColor(Color.proco_blue)
            )
    }
    
    var declined_btn : some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_dark_white)
            .overlay(
                Text("거절됨")
                    .font(.custom(Font.n_bold, size: 13))
                    .foregroundColor(Color.gray)
            )
    }
}
