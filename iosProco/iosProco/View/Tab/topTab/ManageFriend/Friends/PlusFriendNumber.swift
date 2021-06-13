//
//  plusFriendNumber.swift
//  proco
//
//  Created by 이은호 on 2020/11/23.
//

import SwiftUI
import Kingfisher
import Combine

struct PlusFriendNumber: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewmodel: ManageFriendViewModel
    
    //추가할 친구를 검색한 후 결과를 보여줄 데이터 모델
    @State private var plus_friend_search_result = FriendRequestListStruct()
    //선택한 국가번호
    @State private var selected_num = 82
    @State private var is_expanded = false
    
    //핸드폰 번호 형식 맞는지 구분 변수
    @State private var is_phone_number_valid: Bool = false
    
    //친구 요청된 사용자인 경우 요청됨이라고 보여주기 위함.
    @State private var requested_friend : Bool = false
    
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 49, height: 49))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    print("돌아가기 클릭")
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                Spacer()
                
                Text("연락처로 추가")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 55, height: 37)
                    .foregroundColor(.proco_black)
                    .overlay(
                        Button(action: {
                            print("전화번호 텍스트필드에서 엔터 누름")
                            //해당 번호가 내 번호인지, 이미 친구인 사람인지, 없는 번호인지 체크
                            viewmodel.add_friend_number_check()
                            //
                            self.viewmodel.request_result_alert_func(viewmodel.request_result_alert)
                            
                            
                        }){
                            Text("확인")
                                .font(.custom(Font.t_extra_bold, size: 15))
                                .foregroundColor(Color.proco_white)
                        })
            }
            .padding()
            
            HStack{
                Text("+82")
                    .font(.custom(Font.n_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
                
                Divider()
                    .frame(height: UIScreen.main.bounds.width/40)
                
                TextField("전화번호", text: $viewmodel.add_friend_number_value, onEditingChanged: {(is_changed)in
                    if !is_changed{
                        //phone_viewmodel에 있는 정규식 체크 메소드를 사용해 핸드폰 번호 양식 확인함.
                        if self.viewmodel.validator_phonenumber(self.viewmodel.add_friend_number_value){
                            self.is_phone_number_valid = true
                            print("저장된 핸드폰 번호 확인 : \(self.$viewmodel.add_friend_number_value)")
                            
                        }else{
                            self.is_phone_number_valid = false
                            self.viewmodel.add_friend_number_value = ""
                        }
                    }
                })
                .font(.custom(Font.n_regular, size: 15))
                .foregroundColor(self.viewmodel.add_friend_number_value == "" ? Color.light_gray : Color.proco_black )
                .padding([.trailing], UIScreen.main.bounds.width/20)
                .foregroundColor(Color.gray)
                .keyboardType(.phonePad)
            }
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            
            Divider()
            HStack{
                Text("-없이 숫자만 입력해주세요")
                    .foregroundColor(Color.gray)
                    .font(.custom(Font.n_bold, size: 9))
                    .padding(.leading, UIScreen.main.bounds.width/20)
                Spacer()
            }
            
            //아직 통신을 하지 않아서 데이터가 들어가지 않은 경우 아무것도 보여주지 않는 예외처리 진행해야 처음 뷰 그릴 때 오류 안뜸
            if self.plus_friend_search_result.idx
                == nil{
                
            }else{
                HStack{
                    //프로필 사진은 의무가 아니므로 프로필 사진이 없는 경우 추가
                    if viewmodel.add_friend_check_struct.profile_photo_path == nil || viewmodel.add_friend_check_struct.profile_photo_path == ""{
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 49, height: 49)
                        
                    }else{
                        
                        KFImage(URL(string: viewmodel.add_friend_check_struct.profile_photo_path!))
                            .loadDiskFileSynchronously()
                            .cacheMemoryOnly()
                            .fade(duration: 0.25)
                            .setProcessor(img_processor)
                            .onProgress{receivedSize, totalSize in
                                print("on progress: \(receivedSize), \(totalSize)")
                            }
                            .onSuccess{result in
                                print("성공 : \(result)")
                            }
                            .onFailure{error in
                                print("실패 이유: \(error)")
                            }
                    }
                    
                    Text(viewmodel.add_friend_check_struct.nickname!)
                        .font(.custom(Font.n_bold, size: 16))
                        .foregroundColor(Color.proco_black)
                    
                    Spacer()
                    
                    //친구 신청을 이미 한 친구인 경우
                    if self.requested_friend == true{
                        
                        Text("요청됨")
                            .font(.custom(Font.t_extra_bold, size: 11))
                            .frame(width: 51, height: 30)
                            .padding()
                            .foregroundColor(.main_orange)
                            .background(Color.proco_white)
                            .cornerRadius(25)
                            .border(Color.main_orange, width: 1)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                        
                        Button(action: {
                            print("취소 버튼 클릭: \(self.viewmodel.add_friend_check_struct.idx!)")
                            self.viewmodel.cancel_request_friend(f_idx: self.viewmodel.add_friend_check_struct.idx!)
                        }){
                            Text("취소")
                                .font(.custom(Font.t_extra_bold, size: 11))
                                .frame(width: 41, height: 30)
                                .padding()
                                .foregroundColor(.gray)
                                .background(Color.light_gray)
                                .cornerRadius(25)
                                .border(Color.main_orange, width: 1)
                                .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                        }
                    }else{
                        
                        RoundedRectangle(cornerRadius: 5.0)
                            .foregroundColor(.main_orange)
                            .frame(width: 73, height: 30)
                            .overlay(
                                Button(action: {
                                    
                                    viewmodel.add_friend_number_last()
                                    print("친구추가하기 버튼 클릭")
                                    viewmodel.request_result_alert_func(viewmodel.request_result_alert)
                                }){
                                    
                                    HStack{
                                        Image("tag_plus")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                        
                                        Text("친구 요청")
                                            .font(.custom(Font.t_extra_bold, size: 11))
                                            .foregroundColor(Color.proco_white)
                                    }
                                    
                                }
                            )
                         
                    }
                }
            }
            Spacer()
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
                    
                    self.requested_friend = true
                    
                }))
            case .fail:
                return Alert(title: Text("친구 추가하기"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                    self.requested_friend = false
                }))
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        //번호 검색 후 확인 버튼 클릭시 데이터 보여주기 위해 노티 받았을 때 데이터 넣어줘서 보여줌.
        .onReceive( NotificationCenter.default.publisher(for: Notification.get_data_finish)){value in
            print("친구 리스트 모두 가져온 노티 받음")
            if let user_info = value.userInfo, let data = user_info["got_all_friend"]{
                print("친구 리스트 모두 가져온 통신 완료 받았음: \(data)")
                
                if data as! String == "ok"{
                    
                    self.plus_friend_search_result.idx = self.viewmodel.add_friend_check_struct.idx
                    self.plus_friend_search_result.nickname = self.viewmodel.add_friend_check_struct.nickname
                    self.plus_friend_search_result.profile_photo_path = self.viewmodel.add_friend_check_struct.profile_photo_path
                    print("친구 검색 후 데이터 넣은 것 확인: \(self.plus_friend_search_result)")
                }
            }else{
                print("친구 리스트 모두 가져온 노티 응답 실패: .")
            }
        }
        
    }
}



