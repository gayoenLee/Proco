//
//  MyInterestFriendsListView.swift
//  proco
//
//  Created by 이은호 on 2021/05/31.
// 마이페이지 - 내 관심친구

import SwiftUI
import Kingfisher

struct MyInterestFriendsListView: View {
    @StateObject var friend_vm = FriendVollehMainViewmodel()
    @ObservedObject var main_vm : SettingViewModel
    
    var body: some View {
        NavigationView{
        VStack{
            
            ForEach(self.main_vm.friend_model){friend in
                MyInterestFriendsRow(main_vm: self.main_vm, friend_struct: friend)
            }
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear{
            self.main_vm.get_interest_friends(friend_type: "관심친구")
        }
        }
    }
}

struct MyInterestFriendsRow : View{
    
    @ObservedObject var main_vm : SettingViewModel

    @State var friend_struct : GetFriendListStruct
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 41.5, height: 41.5))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        
        HStack{
            if friend_struct.profile_photo_path == "" || friend_struct.profile_photo_path == nil{
                
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 41.5, height: 41.5)
                
            }else{
                KFImage(URL(string:friend_struct.profile_photo_path!))
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
        
            Text(friend_struct.nickname!)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            
            interest_btn
                      Spacer()
        }
        .padding()
    }
}

extension MyInterestFriendsRow{
    
    var interest_btn : some View{
        //관심친구 여부
        Button(action: {
            print("관심친구 버튼 클릭: \(self.friend_struct.kinds)")
            
            if self.friend_struct.kinds == "관심친구"{
                
                self.main_vm.set_interest_friend(f_idx: friend_struct.idx!, action: "관심친구해제")
                
            }else{
                self.main_vm.set_interest_friend(f_idx: friend_struct.idx!, action: "관심친구")
            }
            
        }){
            
            Image(friend_struct.kinds == "관심친구" ? "star_fill" : "star")
                .resizable()
                .frame(width: 11.41, height: 10.95)
        }
        .onReceive( NotificationCenter.default.publisher(for: Notification.set_interest_friend)){value in
                
                if let user_info = value.userInfo, let data = user_info["set_interest_friend"]{
                    print("친구 관심친구 설정 노티 받았음: \(value)")
                             
                    if data as! String == "set_ok_관심친구"{
                        print("관심친구 설정한 경우 노티")

                        let friend_idx = user_info["friend_idx"] as! String
                        
                        if friend_struct.idx! == Int(friend_idx){
                            self.friend_struct.kinds = "관심친구"
                                              }
                    }else if data as! String == "set_ok_관심친구해제"{
                        print("관심친구 해제한 경우 노티")
                        let friend_idx = user_info["friend_idx"] as! String
                        if friend_struct.idx! == Int(friend_idx){
                            self.friend_struct.kinds = "관심친구해제"
                        }
                    }else{
                        print("관심친구 이벤트 오류 발생")
                    }
                    
                }else{
                    print("관심친구 설정 노티 아님")
                }
        }
    }
}
