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
                    //친구 요청 통신
                    self.main_vm.add_friend_request(f_idx: SimSimFeedPage.calendar_owner_idx!)
                    self.main_vm.request_result_alert_func(main_vm.request_result_alert)
                    
                }){
                    
                    Rectangle()
                        .foregroundColor(Color.green)
                        .overlay(
                            Text("친구 신청")
                                .font(.system(size: 15))
                        )
                }
                .alert(isPresented: $main_vm.show_result_alert){
                    switch main_vm.request_result_alert{
                    case .no_friends, .denied:
                        return Alert(title: Text("친구 추가하기"), message: Text("없는 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .request_wait:
                        return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .requested:
                        return Alert(title: Text("친구 추가하기"), message: Text("친구 요청된 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .already_friend:
                        return Alert(title: Text("친구 추가하기"), message: Text("이미 친구 상태인 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .myself:
                        return Alert(title: Text("친구 추가하기"), message: Text("내 번호입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .success:
                        return Alert(title: Text("친구 추가하기"), message: Text("친구 신청이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    case .fail:
                        return Alert(title: Text("친구 추가하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                            
                        }))
                    }
                }
            }
        }
    }
}

