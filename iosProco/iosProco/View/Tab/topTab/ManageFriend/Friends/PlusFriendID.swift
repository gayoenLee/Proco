//
//  plusFriendNumber.swift
//  proco
//
//  Created by 이은호 on 2020/11/23.
//

import SwiftUI

struct PlusFriendID: View {
    @ObservedObject var viewmodel: ManageFriendViewModel
    
    var body: some View {
        VStack{
            //상단 네비게이션 바 위치 메뉴들
            HStack{
                Image("left")
                    .resizable()
                    .frame(width: 8.51, height: 17)
                Spacer()
                
                Text("친구추가")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                
                //확인 버튼을 누르면 아이디 존재 여부 등을 서버에서 확인하고 보내줌.
                Button(action: {
                    print("이메일 텍스트필드에서 엔터 누름")
                    viewmodel.add_friend_email_check()
                    
                }){
                    Text("확인")
                }
                .padding()
//                .alert(isPresented: $viewmodel.show_alert_no_friend){
//
//                    Alert(title: Text("친구 추가하기"), message: Text("없는 사용자입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
//
//                    }))
//                }
//                .alert(isPresented: $viewmodel.show_alert_myself){
//                    Alert(title: Text("친구 추가하기"), message: Text("내 번호입니다"), dismissButton: Alert.Button.default(Text("확인"), action: {
//
//                    }))
//                }
//            }
//            .padding()
            
            //친구 아이디 검색 부분
            TextField("친구 아이디", text: $viewmodel.add_friend_id_value)
                .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            
            HStack{
                Spacer()
                Text("내 아이디 \(UserDefaults.standard.string(forKey: "user_id") ?? "")")
                    .padding(.trailing, UIScreen.main.bounds.width/20)
                    .font(.caption2)
            }
            Spacer()
            
            //아직 통신을 하지 않아서 데이터가 들어가지 않은 경우 아무것도 보여주지 않는다.
            //idx가 nil인 것은 친구 데이터를 받은 것이 아니라 result만 받은 것. 위에 alert창으로 예외처리 진행함.
            if viewmodel.add_friend_check_struct.idx == nil{
                
            }else{
                HStack{
                    //프로필 사진은 의무가 아니므로 프로필 사진이 없는 경우 추가
                    if viewmodel.add_friend_check_struct.profile_photo_path == nil{
                        Image(systemName: "person")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                            .cornerRadius(50)
                    }else{
                        Image(viewmodel.add_friend_check_struct.profile_photo_path!)
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                            .cornerRadius(50)
                    }
                    
                    Text(viewmodel.add_friend_check_struct.nickname!)
                        .padding()
                    
                    Button(action: {
                        viewmodel.add_friend_email_last()
                        print("친구추가하기 버튼 클릭")
                        viewmodel.request_result_alert_func(viewmodel.request_result_alert)
                        
                    }){
                        
                        Text("친구추가하기")
                    }
                    .alert(isPresented: $viewmodel.show_request_result_alert){
                        switch viewmodel.request_result_alert{
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
                        default:
                            return Alert(title: Text("친구 추가하기"), message: Text("완료"), dismissButton: Alert.Button.default(Text("확인"), action: {
                                
                            }))
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    }
}





