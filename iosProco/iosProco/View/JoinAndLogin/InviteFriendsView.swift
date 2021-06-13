//
//  InviteFriendsView.swift
//  proco
//
//  Created by 이은호 on 2021/04/08.
// 회원가입시 내 주소록에 등록된 친구들 가져오는것.

import SwiftUI
import Contacts
import Kingfisher

struct InviteFriendsView: View {
    
    @ObservedObject var vm : SignupViewModel
    @State private var requested_fail : Bool = false
    var my_idx : Int
    
    var body: some View {
        VStack{
            HStack{
            Text("프로코로 초대하세요")
                .font(.custom(Font.t_extra_bold, size: 22))                .foregroundColor(Color.proco_black)
            Spacer()
            }
            .padding(.leading)
            
        ScrollView{
        VStack{
            ForEach(self.vm.contacts_model.indices, id: \.self){idx in
                
                InviteUserRow(friend: self.vm.contacts_model[idx], vm: self.vm, requested_fail: self.$requested_fail, my_idx: my_idx)
            }
        }
       
        }
            
            Button(action: {
                print("다음 버튼 클릭")
                
                
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
            print("친구 초대하기 뷰 나타남.")
            self.vm.fetchContacts()
            }
        .alert(isPresented: self.$requested_fail) {
            Alert(title: Text("알림"), message: Text("초대 메세지 전송에 실패했습니다. 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
    }
}

extension InviteFriendsView{
    
}

struct InviteUserRow: View{
    
    var friend : FetchedContactModel
    @ObservedObject var vm : SignupViewModel
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    @State private var reqeusted_invite : Bool = false
    @Binding var requested_fail : Bool
    var my_idx: Int
    
    var body: some View{
        HStack{
            if friend.profile_photo_path == nil || friend.profile_photo_path == ""{
               
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 49, height: 49)
                
            }else{
           
                KFImage(URL(string: friend.profile_photo_path!))
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
            
            Text("\(friend.firstName)")
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(.proco_black)
            
            Text("\(friend.lastName)")
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(.proco_black)
            
            Spacer()
            
            Button(action: {
              
                self.vm.send_invite_message(contacts: [friend.telephone])
                print("초대하기 클릭 친구 전화번호: \(friend.telephone)")
                
            }){
                if self.reqeusted_invite == false{
               Rectangle()
                .cornerRadius(5)
                    .foregroundColor(.main_orange)
                    .frame(width: 50, height: 30)
                    .overlay(
                        HStack{
                            
                        Image("tag_plus")
                            .resizable()
                            .frame(width: 8, height: 8)
                      
                        Text("초대")
                            .font(.custom(Font.n_bold, size: 15))
                            .foregroundColor(.proco_white)
                            .padding()
                            
                        }.padding()
               
                    )}else{
                     //초대한 경우
                        
                            Text("초대됨")
                                .font(.custom(Font.n_bold, size: 11))
                                .foregroundColor(.main_orange)
                                .padding()
                        
                        .frame(width: 51, height: 30)
                        .overlay(Capsule()
                                    .stroke(Color.main_orange, lineWidth: 5)
                        )
                        .cornerRadius(5.0)
                    }
                    
                }
            .onReceive(NotificationCenter.default.publisher(for: Notification.sent_invite_msg), perform: {value in
                print("초대 문자 보낸 후 노티 받음.")
                
                if let user_info = value.userInfo, let data = user_info["sent_invite_msg"]{
                    print("초대 문자 이벤트 \(data)")
                    
                    if data as! String == "ok"{
                       
                        let friend_contact = user_info["contact"] as! String
                        
                        //초대 문자 보낸 사람 전화번호와 노티에서 받은 전화번호가 같을 경우에만 뷰 변경.
                        if friend_contact == friend.telephone{
                            //userdefaults에 저장돼 있던 초대 보낸 리스트 꺼내와서 값 할당. -> 이번에 초대한 친구 append해서 다시 저장
                          var invited_friends =  UserDefaults.standard.array(forKey: "\(my_idx)_invited_friends")
                            invited_friends?.append(friend.telephone)
                            //다시 저장
                            UserDefaults.standard.set(invited_friends, forKey: "\(my_idx)_invited_friends")
                            
                        print("초대 문자 이벤트 초대 완료로 변경하기")
                            self.reqeusted_invite = true
                            
                          
                        }else{
                            //메세지 전송 실패 알림 띄우기
                            self.requested_fail = true
                        }
                    }
                }else{
                    //메세지 전송 실패 알림 띄우기
                    print("초대 문자 이벤트 메세지 보내기 실패")
                    self.requested_fail = true
                    
                }
            })
    
        }
        .padding()
    }
}

