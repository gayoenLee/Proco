//
//  InterestUserCell.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
//

import SwiftUI

struct InterestUserCell: View {
    
    @State var interest_users_model : InterestUsersModel
    @StateObject var main_vm : CalendarViewModel
    //관심있어요한 사람 한명 클릭시 피드페이지로 이동하는 값.
    @State private var show_friend_feed: Bool = false
    
    var body: some View {
        HStack{
            
            NavigationLink("",destination: SimSimFeedPage(main_vm: self.main_vm), isActive: self.$show_friend_feed)
            
            Image(systemName: (interest_users_model.profile_photo_path == "" ? "person" : interest_users_model.profile_photo_path) ?? "person")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                .foregroundColor(Color.black)

            Spacer()
            
            Text(interest_users_model.nickname)
                .font(.system(size: 10))
                .foregroundColor(Color.black)
        }
        .padding()
        .onTapGesture {
            print("유저 클릭 이벤트: \(interest_users_model.idx)")
           //피드 페이지로 이동하는 값 변경.
            self.show_friend_feed.toggle()
        }
        
    }
}

