//
//  EnrolledFriendListView.swift
//  proco
//
//  Created by 이은호 on 2021/04/08.
// 회원가입시 등록된 친구들 리스트 가져오기

import SwiftUI
import Contacts
import Kingfisher

struct EnrolledFriendListView: View {
    
    @ObservedObject var vm : SignupViewModel
    
    var body: some View {
        VStack{
            
            HStack{
                Text("프로코 친구를 만드세요")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(.proco_black)
                
                Spacer()
            }
            .padding(.leading)
            ScrollView{
                ForEach(self.vm.enrolled_friends_model.indices, id: \.self){idx in
                    
                    EnrolledFriendRow(vm: self.vm, friend: self.vm.enrolled_friends_model[idx])
                }
            }
            
            Button(action: {
                
            }){
                Text("다음")
                    .font(.custom(Font.t_regular, size: 21))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(Color.proco_white)
                    .background(Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
        }
        .onAppear{
            print("친구 요청하는 뷰 나타남.")
            //TODO 핸드폰 인증시 번호 저장해야함.
             self.vm.get_enrolled_friends(contacts: [self.vm.phone_number])
           
        }
    }
}

struct EnrolledFriendRow : View{
    
    
    @ObservedObject var vm : SignupViewModel
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    var friend : EnrolledFriendsModel
    
    //친구 요청을 한 다음 뷰 변화시키는데 이용.
    @State private var requested : Bool = false
    
    //친구 신청 또는 취소 통신에 실패한 경우에만 알림 띄우기 위함.
    @State private var requested_fail:Bool = false
    var body: some View{
        HStack{
            
            if friend.profile_photo_path == nil || friend.profile_photo_path == ""{
                
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 49, height: 49)
                
            }else{
                
                KFImage(URL(string: friend.profile_photo_path))
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
            
            Text("\(friend.nickname)")
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(.proco_black)
            Spacer()
            
            Button(action: {
                print("추가하기 클릭")
                vm.add_friend_request(f_idx: friend.idx)
                
            }){
                HStack{
                    if self.requested{
                        
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
                            print("취소 버튼 클릭: \(friend.idx)")
                            self.vm.cancel_request_friend(f_idx: friend.idx)
                            
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
                        RoundedRectangle(cornerRadius: 20.0)
                            .foregroundColor(.main_orange)
                            .frame(width: 73, height: 30)
                            .overlay(
                                
                                HStack{
                                    
                                    Image("tag_plus")
                                        .resizable()
                                        .frame(width: 8, height: 8)
                                    
                                    Text("친구 요청")
                                        .font(.custom(Font.n_bold, size: 15))
                                        .foregroundColor(.proco_white)
                                }
                                .padding())
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.request_friend), perform: {value in
                
                if let user_info = value.userInfo{
                    let check_result = user_info["request_friend"]
                    print("친구 요청 데이터 확인: \(String(describing: check_result))")
                    
                    if check_result as! String == "ok"{
                        
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            self.requested = true
                        }
                    }else if check_result as! String == "친구요청대기"{
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            
                        }
                    }else if check_result as! String == "친구요청받음"{
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            
                        }
                        
                    }else if check_result as! String == "친구상태"{
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            
                        }
                    }else if check_result as! String == "자기자신"{
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            
                        }
                        
                    }
                    //친구 신청 취소한 경우
                    else if check_result as! String == "canceled_ok"{
                        let friend_idx = user_info["friend"] as! String
                        
                        if friend.idx == Int(friend_idx){
                            self.requested = false
                        }
                    }else if check_result as! String == "canceled_fail"{
                        let friend_idx = user_info["friend"] as! String
                        
                        //실패 알림창 띄움
                        if friend.idx == Int(friend_idx){
                            requested_fail = true
                        }
                    }
                    else{
                        let friend_idx = user_info["friend"] as! String
                        if friend.idx == Int(friend_idx){
                            self.requested = false
                            requested_fail = true
                        }
                    }
                }
            })
            
        }
        .padding()
    }
}

