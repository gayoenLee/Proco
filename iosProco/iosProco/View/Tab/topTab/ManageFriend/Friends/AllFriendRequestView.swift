//
//  AllFriendRequestView.swift
//  proco
//
//  Created by 이은호 on 2021/07/19.
//

import SwiftUI

struct AllFriendRequestView: View {
    @Environment(\.presentationMode) var presentation

    @ObservedObject  var manage_vm : ManageFriendViewModel
    @Binding var friend_total_num : Int
    //통신 시간 소요 때문에 스레드 준 후 보여주기 위해 사용하는 구분값.
    @State private var show_list : Bool  = false
    
    var body: some View {
        VStack{
            HStack{
                //돌아가기 버튼
                Button(action: {
                    withAnimation{
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2){
                        
                    self.presentation.wrappedValue.dismiss()
                    }
                    }
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                Spacer()
            }
            .padding([.leading])
            
            ScrollView{
                HStack{
                    Text("친구 요청 받은 목록")
                        .font(.custom(Font.n_extra_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                }
                .padding()
                
                if manage_vm.friend_request_struct.count <= 0{
                    Text("친구 신청한 사람이 없습니다.")
                        .font(.custom(Font.t_regular, size: 13))
                        .foregroundColor(Color.proco_black)
                    
                }else{
                    ForEach(manage_vm.friend_request_struct){request in
                        
                        FriendRequestRow(manage_viewmodel:  self.manage_vm, request_struct: request, friend_total_num: self.$friend_total_num)
                            .padding([.leading, .trailing])
                            .onReceive(NotificationCenter.default.publisher(for: Notification.friend_request_event), perform: {value in
                                print("친구 요청 수락, 거절 노티 받음: \(value)")
                                
                                if let user_info = value.userInfo, let check_result = user_info["friend_request_event"]{
                                    print("친구 요청 수락, 거절 노티 데이터: \(check_result)")
                                    
                                    //수락이벤트였을 경우
                                    if check_result as! String == "accepted"{
                                        
                                        let friend_idx = user_info["friend_idx"] as! String
                                        
                                        if request.idx == Int(friend_idx){
                                        let model_data = self.manage_vm.friend_request_struct.first(where: {
                                            $0.idx! == Int(friend_idx)
                                        })!
                                        
                                        //친구 요청 리스트에서 제거는 안하고(index out of range에러 발생) 수락됨으로 뷰 변경, 친구 리스트에 추가
                                        manage_vm.friend_list_struct.append(GetFriendListStruct(idx: model_data.idx, nickname: model_data.nickname, profile_photo: model_data.profile_photo_path, state: 0, kinds: "친구상태"))
                                            
                                            let model_data_idx = self.manage_vm.friend_request_struct.firstIndex(where: {
                                                $0.idx! == Int(friend_idx)
                                            })!
                                            
                                            withAnimation(.spring()) {
                                            self.manage_vm.friend_request_struct.remove(at: model_data_idx)
                                            }
                                        //전체 친구 수 +1
                                        self.friend_total_num += 1
                                        }
                                    }
                                    //거절 이벤트였을 경우
                                    else if check_result as! String == "declined"{
                                        let friend_idx = user_info["friend_idx"] as! String
                                                            
                                        if request.idx == Int(friend_idx){
                                            print("해당 친구인 경우")
                                        
                                            let model_data_idx = self.manage_vm.friend_request_struct.firstIndex(where: {
                                                $0.idx! == Int(friend_idx)
                                            })!
                                            
                                            withAnimation(.spring()) {
                                            self.manage_vm.friend_request_struct.remove(at: model_data_idx)
                                            }
                                        }
                                    }
                                    //두 이벤트 처리에 실패한 경우
                                    else{
                                        print("수락, 거절 이벤트 노티 받았지만 두 경우 모두 아닌 else문")
                                    }
                                }
                            })
                    }
                }
                
                HStack{
                    Text("내가 친구 신청한 목록")
                        .font(.custom(Font.n_extra_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                }
                .padding()
                
                if manage_vm.my_friend_request_struct.count <= 0{
                    Text("친구 신청한 사람이 없습니다.")
                        .font(.custom(Font.t_regular, size: 13))
                        .foregroundColor(Color.proco_black)
                    
                }else{
                    ForEach(manage_vm.my_friend_request_struct){request in
                        MyFriendRequestRow(manage_viewmodel: self.manage_vm, request_struct: request, friend_total_num: self.$friend_total_num)
                            .onReceive(NotificationCenter.default.publisher(for: Notification.request_friend), perform: {value in
                                
                                if let user_info = value.userInfo, let check_result = user_info["request_friend_manage"]{
                                    print("내 친구 요청 취소 노티 받음: \(value)")

                                   //취소가 성공한 경우
                                    if check_result as! String == "canceled_ok"{
                                        
                                        let friend_idx = user_info["friend"] as! String
                                        
                                        if request.idx == Int(friend_idx){
                                        let model_data = self.manage_vm.my_friend_request_struct.firstIndex(where: {
                                            $0.idx! == Int(friend_idx)
                                        })!
                                           
                                            withAnimation(.spring()) {
                                            manage_vm.my_friend_request_struct.remove(at: model_data)
                                            }
                                        }
                                    }
                                    //거절 이벤트였을 경우
                                    else if check_result as! String == "canceled_fail"{
                                        let friend_idx = user_info["friend"] as! String
                                                            
                                       // if self.request_struct.idx == Int(friend_idx){
                                            print("해당 친구인 경우")
                              
                                       // }
                                    }
                                    //두 이벤트 처리에 실패한 경우
                                    else{
                                        print("내 친구 요청 취소 노티 받았지만 모두 아닌 else문")
                                    }
                                }
                            })
                          
                    }
                }
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear{
            //친구 신청 받은 목록 가져온 후 내가 신청한 친구 목록 가져오기
            self.manage_vm.get_friend_list_and_request()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                self.show_list = true
            })
        }
    }
}
