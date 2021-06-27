//
//  FeedNotFriendView.swift
//  proco
//
//  Created by 이은호 on 2021/03/18.
//

import SwiftUI

struct FeedLimitedView: View {
    
    @ObservedObject var main_vm : CalendarViewModel
    //친구지만 비공개, 친구 아닌 경우
    let show_range : String
    
    var body: some View {
        
        VStack{
            if self.show_range == "friend_disallow"{
                
                Text("비공개 피드입니다.")
                Image(systemName: "lock.rectangle.stack.fill")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
                    .foregroundColor(Color.orange)
                
            }else{
                
                Button(action: {
                    print("친구 신청 버튼 클릭")
                    self.main_vm.friend_request_result_alert_func(main_vm.friend_request_result_alert)
                    
                    //친구 요청 통신
                    self.main_vm.add_friend_request(f_idx: SimSimFeedPage.calendar_owner_idx!)
                }){
                    
                    Text("친구 신청")
                        .font(.system(size: 15))
                    
                }
            }
        }
    }
}

