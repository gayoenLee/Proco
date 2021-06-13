//
//  PlusFriendView.swift
//  proco
//
//  Created by 이은호 on 2021/05/25.
//

import SwiftUI
import Kingfisher

struct PlusFriendView: View {
    
    @ObservedObject var manage_vm : ManageFriendViewModel
    @State private var go_add_phone_number_view : Bool = false

    //친구 요청 통신 실패시 알림 띄우기 위함.
    @State private var request_fail : Bool = false
    
    var body: some View {
        VStack{
            NavigationLink("",destination: PlusFriendNumber(viewmodel: self.manage_vm), isActive: self.$go_add_phone_number_view)
            HStack{
                
                Button(action: {
                    print("돌아가기 클릭")
                    
                }){
                    Image("left")
                        .resizable()
                        .frame(width: 8.51, height: 17)
                }
                Spacer()
                
                Text("친구추가")
                    .font(.custom(Font.n_extra_bold, size: 22))
                    .foregroundColor(Color.proco_black)
                
                Spacer()
            }.padding()
            
            HStack{
                Image("address_book_icon")
                    .resizable()
                    .frame(width: 46, height: 46)
                
                Text("연락처로 추가")
                    .font(.custom(Font.n_extra_bold, size: 17))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            .onTapGesture {
                print("연락처로 추가하기 버튼 클릭")
                self.go_add_phone_number_view = true
            }
            
            HStack{
                Text("추천친구")
                    .font(.custom(Font.n_extra_bold, size: 18))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }.padding()
            ScrollView{
                VStack{
                    //친구 요청 보낼 친구 리스트
                    ForEach(self.manage_vm.enrolled_friends_model){friend in
                        ManageEnrolledFriendRow(manage_vm: self.manage_vm, friend_model: friend, request_fail: self.$request_fail)
                    }
                    
                    //초대문자 보낼 친구 리스트
                    ForEach(self.manage_vm.contacts_model){friend in
                        ManageAddressBookFriendRow(manage_vm: self.manage_vm, friend_model: friend, request_fail: self.$request_fail)
                    }
                }
            }
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .onAppear{
            print("친구 추가하기 뷰 나타남")
            self.manage_vm.get_enrolled_friends(contacts: ["01048077540"])
        }
        //친구 요청 실패시 띄움
        .alert(isPresented: self.$request_fail){
            Alert(title: Text("알림"), message: Text("요청을 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
    }
}

struct ManageAddressBookFriendRow: View{
    
    @ObservedObject var manage_vm : ManageFriendViewModel
    @State var friend_model : FetchedContactModel
    
    //요청 실패시 알림 띄움.
    @Binding var request_fail : Bool
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 49, height: 49))
        |> RoundCornerImageProcessor(cornerRadius: 25) |> ResizingImageProcessor(referenceSize: CGSize(width: 49, height: 49), mode: .aspectFit)
    
    var body: some View{
        HStack{
            if friend_model.profile_photo_path == "" || friend_model.profile_photo_path == nil{
                
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 49, height: 49)
            }else{
                KFImage(URL(string: friend_model.profile_photo_path!))
                    .placeholder{Image("main_profile_img")
                        .resizable()
                        .frame(width: 49, height: 49)
                    }
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
                        
                        Image("main_profile_img")
                            .resizable()
                            .frame(width: 49, height: 49)
                    }
            }
            
            Text(friend_model.lastName+friend_model.firstName)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            Spacer()
            
            if self.friend_model.sent_invite_msg == true{
                
                RoundedRectangle(cornerRadius: 5.0)
                    .foregroundColor(.main_orange)
                    .frame(width: 50, height: 30)
                    .overlay(
                        HStack{
                            Image("tag_plus")
                                .resizable()
                                .frame(width: 10, height: 10)
                            
                            Text("다시 초대")
                                .font(.custom(Font.t_extra_bold, size: 11))
                                .foregroundColor(Color.proco_white)
                        })
            }else{
                
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundColor(.main_orange)
                .frame(width: 50, height: 30)
                .overlay(
                    Button(action: {
                        print("초대 클릭")
                        self.manage_vm.send_invite_message(contacts: [friend_model.telephone])
                    }){
                        HStack{
                            Image("tag_plus")
                                .resizable()
                                .frame(width: 10, height: 10)
                            
                            Text("초대")
                                .font(.custom(Font.t_extra_bold, size: 11))
                                .foregroundColor(Color.proco_white)
                        }
                    })
                    }
                
            
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: Notification.sent_invite_msg), perform: {value in
            print("초대 문자 보낸 후 노티 받음.")
            
            if let user_info = value.userInfo, let data = user_info["sent_invite_msg"]{
                print("초대 문자 이벤트 \(data)")
                
                if data as! String == "ok"{
                   
                    let friend_contact = user_info["contact"] as! String
                    //초대 문자 보낸 사람 전화번호와 노티에서 받은 전화번호가 같을 경우에만 뷰 변경.
                    if friend_contact == friend_model.telephone{
                        
                        //userdefaults에 저장돼 있던 초대 보낸 리스트 꺼내와서 값 할당. -> 이번에 초대한 친구 append해서 다시 저장
                        let my_idx = UserDefaults.standard.string(forKey: "user_id")
                        var invited_friends =  UserDefaults.standard.array(forKey: "\(String(describing: my_idx))_invited_friends")
                          invited_friends?.append(friend_model.telephone)
                          //다시 저장
                        UserDefaults.standard.set(invited_friends, forKey: "\(String(describing: my_idx))_invited_friends")
                        
                    print("초대 문자 이벤트 초대 완료로 변경하기")
                        friend_model.sent_invite_msg = true

                    }else{
                        friend_model.sent_invite_msg = false
                    }
                }else{
                    self.request_fail = true
                }
            }else{
                //메세지 전송 실패 알림 띄우기
                print("초대 문자 이벤트 메세지 보내기 실패")
                friend_model.sent_invite_msg = false
                self.request_fail = true
            }
        })
    }
}

struct ManageEnrolledFriendRow:  View{
    
    @ObservedObject var manage_vm : ManageFriendViewModel
    @State var friend_model : EnrolledFriendsModel
    
    //요청 실패시 알림 띄우기 위함.
    @Binding var request_fail : Bool
    
    var body: some View{
        HStack{
            if friend_model.profile_photo_path == "" || friend_model.profile_photo_path == nil{
                
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 49, height: 49)
            }else{
                Image(friend_model.profile_photo_path)
                    .resizable()
                    .frame(width: 49, height: 49)
            }
            
            Text(friend_model.nickname)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(Color.proco_black)
            Spacer()
            
            //친구 요청을 이미 한 이후에는 요청됨, 취소버튼 2개 나타남
            if self.friend_model.sent_rquest == true{
                
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
                    print("취소 버튼 클릭: \(friend_model.idx)")
                    self.manage_vm.cancel_request_friend(f_idx: friend_model.idx)
                    
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
             //친구 요청 아직 안한 경우
            RoundedRectangle(cornerRadius: 5.0)
                .foregroundColor(.main_orange)
                .frame(width: 73, height: 30)
                .overlay(
                    Button(action: {

                        print("친구 요청 클릭: \(friend_model.idx)")
                       self.manage_vm.add_friend_request(f_idx: friend_model.idx)
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
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: Notification.request_friend), perform: {value in
            
            if let user_info = value.userInfo{
                let check_result = user_info["request_friend_manage"]
                print("친구 요청 데이터 확인: \(String(describing: check_result))")
                
                if check_result as! String == "ok"{
                    
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        friend_model.sent_rquest = true
                    }
                }else if check_result as! String == "친구요청대기"{
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        
                    }
                }else if check_result as! String == "친구요청받음"{
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        
                    }
                    
                }else if check_result as! String == "친구상태"{
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        
                    }
                }else if check_result as! String == "자기자신"{
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        
                    }
                    
                }
                //친구 신청 취소한 경우
                else if check_result as! String == "canceled_ok"{
                    let friend_idx = user_info["friend"] as! String
                    
                    if friend_model.idx == Int(friend_idx){
                        friend_model.sent_rquest = false
                    }
                }else if check_result as! String == "canceled_fail"{
                    let friend_idx = user_info["friend"] as! String
                    
                    //실패 알림창 띄움
                    if friend_model.idx == Int(friend_idx){
                        request_fail = true
                    }
                }
                else{
                    let friend_idx = user_info["friend"] as! String
                    if friend_model.idx == Int(friend_idx){
                        friend_model.sent_rquest = false
                        request_fail = true
                    }
                }
            }
        })
      
    }
}


