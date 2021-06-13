//
//  ApplyPeopleListView..swift
//  proco
//
//  Created by 이은호 on 2020/11/24.
// 모여볼래 신청자, 참가자 리스트 뷰

import SwiftUI

struct ApplyPeopleListView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var main_vm: GroupVollehMainViewmodel
    
    //신청자 정보를 담고 있는 곳
    @State private var check_owner = true
   @Binding var show_view : Bool
    
    var body: some View {
    
        VStack{
            //상단 돌아가기, 제목, 수정하기 버튼 탭
            HStack{
                //돌아가기 버튼
                Button(action: {
                   //self.show_view = false
                   // presentationMode.wrappedValue.dismiss()
                    self.show_view.toggle()
                    print("돌아가기 클릭 :")
                }){
                Image( "left")
                    .resizable()
                    .frame(width: 8.51 , height: 17)
                    .padding(.leading, UIScreen.main.bounds.width/20)
                  
                }
                .padding()
           
                  
                Spacer()
                Text("신청자 목록")
                    .font(.custom(Font.t_extra_bold, size: 22))
                    .foregroundColor(.proco_black)
                    .padding()
                Spacer()
          
            }
            ScrollView{
                VStack{
                    if main_vm.apply_user_struct.isEmpty{
                        Text("아직 신청자가 없습니다")
                        
                    }else{
                      
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
                            ForEach(main_vm.apply_user_struct.filter{
                                $0.kinds == "대기중"
                                
                            }){ user in
                                HStack{
                                    
                                    Image(main_vm.apply_user_struct[main_vm.get_user_index(item: user)].profile_photo_path ?? "main_profile_img")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                                        .cornerRadius(50)
                                    Text(main_vm.apply_user_struct[main_vm.get_user_index(item: user)].nickname!)
                                        .font(.custom(Font.n_bold, size: 16))
                                        .foregroundColor(.proco_black)
                                    
                                    Spacer()
                                    
                                    //주최자에게만 버튼이 보이도록 함 - 드로어, 메인의 경우 나눠야 함.
                                    // 드로어에서 신청자 목록 보기로 넘어왔을 때 내가 만든 방인 경우
                                    //주최자에게만 버튼이 보이도록 함 - 드로어, 메인의 경우 나눠야 함.
                                    // 드로어에서 신청자 목록 보기로 넘어왔을 때 내가 만든 방인 경우
                                    if  SockMgr.socket_manager.current_chatroom_info_struct.creator_idx == Int(ChatDataManager.shared.my_idx!){
                                        Button(action: {
                                            
                                            print("드로어에서 신청자 목록 보기로 넘어왔을 때 내가 만든 방인 경우 수락")
                                            //수락하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                                            self.main_vm.apply_user_idx = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].idx!
                                            print("수락하려는 사람의 idx: \(self.main_vm.apply_user_idx)")
                                            self.main_vm.apply_user_struct[main_vm.get_user_index(item: user)].kinds = "수락됨"
                                            //수락하려는 사람의 프로필 사진 경로, 닉네임 저장해서 채팅 서버에 보낼 때 사용.
                                            self.main_vm.apply_user_nickname = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].nickname!
                                            self.main_vm.apply_user_profile_photo = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].profile_photo_path ?? ""
                                            
                                            //수락하는 통신
                                            self.main_vm.apply_accept()
                                            
                                        }){
                                            Text("수락")
                                                .padding()
                                                .background(Color.proco_sky_blue)
                                                .foregroundColor(Color.proco_blue)
                                                .cornerRadius(20)
                                            
                                        }
                                        
                                        Button(action: {
                                            //거절하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                                            self.main_vm.apply_user_idx = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].idx!
                                            //참가 신청 거절하는 통신
                                            self.main_vm.apply_decline()
                                            
                                        }){
                                            Text("거절")
                                                .padding()
                                                .background(Color.white_pink)
                                                .foregroundColor(Color.proco_red)
                                                .cornerRadius(20)
                                        }
                                        .padding(.trailing, UIScreen.main.bounds.width/40)
                                    }
                                    else if self.check_owner{
                                        
                                        Button(action: {
                                            //수락하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                                            self.main_vm.apply_user_idx = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].idx!
                                            self.main_vm.apply_user_struct[main_vm.get_user_index(item: user)].kinds = "수락됨"
                                            //수락하려는 사람의 프로필 사진 경로, 닉네임 저장해서 채팅 서버에 보낼 때 사용.
                                            self.main_vm.apply_user_nickname = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].nickname!
                                            self.main_vm.apply_user_profile_photo = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].profile_photo_path ?? ""
                                            
                                            //수락하는 통신
                                            self.main_vm.apply_accept()
                                            
                                        }){
                                            Text("수락")
                                                .padding()
                                                .background(Color.proco_sky_blue)
                                                .foregroundColor(Color.proco_blue)
                                                .cornerRadius(20)
                                            
                                        }
                                        
                                        Button(action: {
                                            //거절하고자 하는 사람의 idx 뷰모델에 저장해서 통신시 사용.
                                            self.main_vm.apply_user_idx = main_vm.apply_user_struct[main_vm.get_user_index(item: user)].idx!
                                            //참가 신청 거절하는 통신
                                            self.main_vm.apply_decline()
                                            
                                        }){
                                            Text("거절")
                                                .padding()
                                                .background(Color.white_pink)
                                                .foregroundColor(Color.proco_red)
                                                .cornerRadius(20)
                                        }
                                        .padding(.trailing, UIScreen.main.bounds.width/40)
                                    }
                                    else{
                                        //주최자가 아닐 경우 수락, 거절 버튼 안 보임
                                    }
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
                                $0.kinds == "수락됨"
                            }){ user in
                                
                                HStack{
                                    Image(main_vm.apply_user_struct[main_vm.get_user_index(item: user)].profile_photo_path ?? "main_profile_img")
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
                                        .cornerRadius(50)
                                    
                                    Text(main_vm.apply_user_struct[main_vm.get_user_index(item: user)].nickname!)
                                        .font(.custom(Font.n_bold, size: 16))
                                        .foregroundColor(.proco_black)
                                    
                                    Spacer()
                                }
                            }
                    }
                }
            }
        }
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
