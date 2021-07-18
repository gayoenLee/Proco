//
//  FriendRequestRow.swift
//  proco
//
//  Created by 이은호 on 2021/05/27.
//

import SwiftUI

//친구 신청 목록 row
struct FriendRequestRow: View{
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    @State var request_struct : FriendRequestListStruct
    var row_index: Int
    
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
                 
                }else{
                    if request_struct.processed == "수락됨"{
                        accepted_btn
                    }else{
                        declined_btn
                    }
                }
            }.padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.friend_request_event), perform: {value in
            print("친구 요청 수락, 거절 노티 받음")
            
            if let user_info = value.userInfo, let check_result = user_info["friend_request_event"]{
                print("친구 요청 수락, 거절 노티 데이터: \(check_result)")
                
                //수락이벤트였을 경우
                if check_result as! String == "accepted"{
                    
                    let friend_idx = user_info["friend_idx"] as! String
                    let model_data = self.manage_viewmodel.friend_request_struct.first(where: {
                        $0.idx! == Int(friend_idx)
                    })!
                    //친구 요청 리스트에서 제거는 안하고(index out of range에러 발생) 수락됨으로 뷰 변경, 친구 리스트에 추가
                    manage_viewmodel.friend_list_struct.append(GetFriendListStruct(idx: model_data.idx, nickname: model_data.nickname, profile_photo: model_data.profile_photo_path, state: 0, kinds: "친구상태"))
                    self.request_struct.processed = "수락됨"
                    
                    //전체 친구 수 +1
                    self.friend_total_num += 1
                }
                //거절 이벤트였을 경우
                else if check_result as! String == "declined"{
                    let friend_idx = user_info["friend_idx"] as! String
                    
                    //친구 요청 리스트에서 제거하지 않고 뷰만 거절됨으로 변경.
                    self.request_struct.processed = "거절됨"
                }
                //두 이벤트 처리에 실패한 경우
                else{
                    
                }
            }
        })
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
                                       
                                       print("수락하려는 리스트 row idx값 받았는지 확인  \(row_index)")
                                       manage_viewmodel.selected_friend_request_row = row_index
                                       print("수락하려는 리스트 row의 idx값 저장했는지 확인 : \(manage_viewmodel.selected_friend_request_row)")
                    //수락하려는 리스트의 row값 저장해서 delete할 때 사용
                    manage_viewmodel.show_alert(.accept)
                    
                }){
                    Text("수락")
                        .font(.custom(Font.n_bold, size: 13))
                        .foregroundColor(Color.proco_blue)
                })
            .alert(isPresented: $manage_viewmodel.show_alert_now){
                switch manage_viewmodel.active_alert{
                case .accept:
                    return Alert(title: Text("친구 신청"), message: Text("친구 신청을 수락하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                        //확인 눌렀을 때 통신 시작
                        manage_viewmodel.accept_friend_request()
                        //후에 통신이 끝났을 때 다시 alert창 띄우기
                        
                    }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                        
                    }))
                case .decline:
                    return Alert(title: Text("친구 신청"), message: Text("친구 신청을 거절하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                        //확인 눌렀을 때 통신 시작
                        manage_viewmodel.decline_friend_request()
                    }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                        
                    }))
                }
            }
        
    }
    
    var decline_btn : some View{
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 44, height: 30)
            .foregroundColor(.proco_dark_white)
            .overlay(
                Button(action: {
                    
                    manage_viewmodel.show_alert(.decline)
                    //거절하려는 리스트의 row값 저장해서 delete할 때 사용
                    manage_viewmodel.selected_friend_request_row = self.row_index
                    
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
            .alert(isPresented: $manage_viewmodel.show_alert_now){
                switch manage_viewmodel.active_alert{
                case .accept:
                    return Alert(title: Text("친구 신청"), message: Text("친구 신청을 수락하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                        //확인 눌렀을 때 통신 시작
                        manage_viewmodel.accept_friend_request()
                        //후에 통신이 끝났을 때 다시 alert창 띄우기
                        
                    }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                        
                    }))
                case .decline:
                    return Alert(title: Text("친구 신청"), message: Text("친구 신청을 거절하시겠습니까?"), primaryButton: Alert.Button.default(Text("확인"), action: {
                        //확인 눌렀을 때 통신 시작
                        manage_viewmodel.decline_friend_request()
                    }), secondaryButton: Alert.Button.default(Text("취소"), action: {
                        
                    }))
                }
            }
    }
}
