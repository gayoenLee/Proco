//
//  InterestUserListView.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
// 캘린더 - 상세 페이지에서 관심있어요한 사람들 목록 보여주는 뷰

import SwiftUI

struct InterestUserListView: View {
    
    @ObservedObject var main_vm : CalendarViewModel
    
    var body: some View {
        VStack{
            Text("관심있어요한 사람들")
                .font(.subheadline)
                .foregroundColor(Color.black)
                .padding()
            
            ForEach(main_vm.calendar_interest_user_model){user in
                InterestUserCell(interest_users_model: user, main_vm: self.main_vm)
            }
            Spacer()
        }
        .onAppear{
            print("관심있어요 유저 목록뷰 나타남.")
        }
    }
}
