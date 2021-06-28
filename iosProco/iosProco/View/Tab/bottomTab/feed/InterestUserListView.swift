//
//  InterestUserListView.swift
//  proco
//
//  Created by 이은호 on 2021/03/14.
// 캘린더 - 상세 페이지에서 관심있어요한 사람들 목록 보여주는 뷰

import SwiftUI

struct InterestUserListView: View {
    
    @ObservedObject var main_vm : CalendarViewModel
    let bored_date : Date
    @State private var is_loading = true
    var body: some View {
        VStack{
            ScrollView{
                Text("관심있어요한 사람들")
                    .font(.custom(Font.n_bold, size: 25))
                    .foregroundColor(Color.black)
                    .padding()
                if is_loading{
                    
                    ProgressView()
                    
                }else{
                    
                ForEach(main_vm.calendar_interest_user_model){user in
                    InterestUserCell(interest_users_model: user, main_vm: self.main_vm)
                }
                Spacer()
                }
            }
        }
        .onAppear{
            print("관심있어요 유저 목록뷰 나타남.")
            
            let bored_date = self.main_vm.date_to_string(date: bored_date)
            print("관심 표시한 사람들 보려는 날짜: \(bored_date)")
            self.main_vm.get_interest_users(user_idx: self.main_vm.calendar_owner.user_idx, bored_date: bored_date)
            //데이터를 가져오고 보여주는데 시간이 걸려서 로딩 추가
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.is_loading = false

            }
        }
    }
}
