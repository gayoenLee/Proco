//
//  ApplyPeopleListView..swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
// 모여볼래 신청자, 참가자 리스트 뷰

import SwiftUI
import Kingfisher

struct ApplyPeopleListView: View {
    
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    
    //신청자 정보를 담고 있는 곳
    @State private var check_owner = true
    @Binding var show_view : Bool
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: 40, height: 40)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View {
        
        VStack{
            //상단 돌아가기, 제목, 수정하기 버튼 탭
            HStack{
                //돌아가기 버튼
                Button(action: {
                    
                    self.show_view.toggle()
                    print("돌아가기 클릭 :")
                }){
                    Image( "left")
                        .resizable()
                        .frame(width: 8.51 , height: 17)
                        .padding(.leading, UIScreen.main.bounds.width/20)
                    
                }
                
                Spacer()
                
                Text("신청자 목록")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(.proco_black)
                    .padding()
                Spacer()
                
            }
            .padding(UIScreen.main.bounds.width/30)
            
            ScrollView{
                VStack{
                        
                        //신청자 카테고리
                        HStack{
                            Text("신청자")
                                .font(.custom(Font.n_extra_bold, size: 18))
                                .foregroundColor(.proco_black)
                            Spacer()
                        }
                        .padding(.leading)
                        //모든 신청자들중 상태가 거절, 수락이 처리되지 않은 사람들만 보여준다.
                        //수락 또는 거절 클릭시 신청자 리스트에서 제거
                    if main_vm.apply_user_struct.filter({
                        $0.kinds! == "대기중"
                        
                    }).count<=0{
                        
                        Text("아직 신청자가 없습니다")
                            .font(.custom(Font.n_regular, size: 15))
                            .foregroundColor(.proco_black)
                            .padding([.top, .bottom])
                        
                    }else{
                        
                        ForEach(main_vm.apply_user_struct.filter{
                            $0.kinds == "대기중"
                            
                        }){ user in
                            
                            ApplyPeopleRow(main_vm: self.main_vm, show_view: self.$show_view, user: user)
                      
                        }
                    }
                        HStack{
                            Text("참여자")
                                .font(.custom(Font.n_extra_bold, size: 18))
                                .foregroundColor(.proco_black)
                            Spacer()
                        }
                        .padding(.leading)
                        
                        //참가 신청 수락된 사용자만 보여주는 리스트.
                        ForEach(main_vm.apply_user_struct.filter{
                            $0.kinds == "수락됨" || $0.kinds == "모임장"
                            
                        }){ user in
                            
                            ApplyPeopleRow(main_vm: self.main_vm, show_view: self.$show_view, user: user)

                        }
                    
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.apply_meeting_result), perform: {value in
            
            if let user_info = value.userInfo{
                let check_result = user_info["owner_event"]
                print("참가 거절 후 데이터 확인: \(String(describing: check_result))")
                
                //참가 거절한 경우
                if check_result as! String == "owner_decline"{
                    let friend_idx = user_info["user_idx"] as! String
                    
                        let model_idx = self.main_vm.apply_user_struct.firstIndex(where: {
                            $0.idx! == Int(friend_idx)
                        })
                        withAnimation(.spring()) {
                            print("참가 거절당한 유저인경우")
                            main_vm.apply_user_struct.remove(at: model_idx!)
                        }
                    
                }else if check_result as! String == "owner_accept"{
                    let friend_idx = user_info["user_idx"] as! String
                    
                        withAnimation(.spring()) {
                            let model_idx = self.main_vm.apply_user_struct.firstIndex(where: {
                                $0.idx! == Int(friend_idx)
                            })
                            self.main_vm.apply_user_struct[model_idx!].kinds = "수락됨"
                        }
                    
                }
            }
        })
        .navigationBarHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .onAppear{
            print("신청자 참가자 리스트 나옴.")
            self.main_vm.get_apply_people_list()
            self.check_owner = self.main_vm.find_owner()
        }
        .onDisappear{
            print("신청자 참가자 리스트 사라짐.")
            
        }
        
    }
}

struct ApplyPeopleRow : View{
    
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    
    //신청자 정보를 담고 있는 곳
    @State private var check_owner = true
    @Binding var show_view : Bool
    let scale = UIScreen.main.scale
    let img_processor = ResizingImageProcessor(referenceSize: CGSize(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)) |> RoundCornerImageProcessor(cornerRadius: 25)
    
    @State var user : ApplyUserStruct
    
    var body: some View{
        HStack{
            HStack{
                
                profile_img
                
                nickname
                
                Spacer()
                
                if user.kinds == "수락됨" || user.kinds == "모임장"{
                    
                }else{
                //주최자에게만 버튼이 보이도록 함 - 드로어, 메인의 경우 나눠야 함.
                // 드로어에서 신청자 목록 보기로 넘어왔을 때 내가 만든 방인 경우
                if  SockMgr.socket_manager.current_chatroom_info_struct.creator_idx == Int(ChatDataManager.shared.my_idx!) || self.check_owner{
                    
                    accept_btn
                        decline_btn
                }
                else{
                    //주최자가 아닐 경우 수락, 거절 버튼 안 보임
                }
                }
            }
        }
        .padding(.leading)
    }
    
}

extension ApplyPeopleRow{
    
    var profile_img : some View{
        
        HStack{
        if user.profile_photo_path == nil || user.profile_photo_path == ""{
            
            Image("main_profile_img")
                .resizable()
                .frame(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)
        }else{
            
            KFImage(URL(string: user.profile_photo_path!))
                .placeholder{Image("main_profile_img")
                    .resizable()
                    .frame(width:  UIScreen.main.bounds.width/7, height:  UIScreen.main.bounds.width/7)
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
                        .frame(width: 40, height: 40)
                }
        }
        }
    }
    
    var nickname : some View{
        HStack{
            Text(user.nickname!)
                .font(.custom(Font.n_bold, size: 16))
                .foregroundColor(.proco_black)
        }
    }
    
    var accept_btn : some View{
        HStack{
            Button(action: {
                
                print("드로어에서 신청자 목록 보기로 넘어왔을 때 내가 만든 방인 경우 수락")
                //수락하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                self.main_vm.apply_user_idx = user.idx!
                
                //수락하려는 사람의 프로필 사진 경로, 닉네임 저장해서 채팅 서버에 보낼 때 사용.
                self.main_vm.apply_user_nickname = user.nickname!
                self.main_vm.apply_user_profile_photo = user.profile_photo_path ?? ""
                
                //수락하는 통신
                self.main_vm.apply_accept()
                
            }){
                Text("수락")
                    .padding()
                    .font(.custom(Font.n_bold, size: 16))
                    .background(Color.proco_sky_blue)
                    .foregroundColor(Color.proco_blue)
                    .cornerRadius(20)
                
            }
 
        }
    }
    
    var decline_btn : some View{
        HStack{
            Button(action: {
                //거절하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                self.main_vm.apply_user_idx = user.idx!
                //참가 신청 거절하는 통신
                self.main_vm.apply_decline()
                
            }){
                Text("거절")
                    .padding()
                    .font(.custom(Font.n_bold, size: 16))
                    .background(Color.white_pink)
                    .foregroundColor(Color.proco_red)
                    .cornerRadius(20)
            }
            .padding(.trailing, UIScreen.main.bounds.width/40)
   
        }
    }
}
