//
//  ManageFriendRow.swift
//  proco
//
//  Created by 이은호 on 2021/05/27.
//

import SwiftUI
import Kingfisher

//모든 친구 리스트
struct ManageFriendRow: View{
    @ObservedObject var manage_viewmodel : ManageFriendViewModel
    //친구 데이터 모델
    @State var friend_model : GetFriendListStruct
    @State var showFriendAction: Bool = false
    //그룹에 추가 클릭시 그룹 리스트 모달 띄우는 값
    @Binding var show_group_list_modal: Bool
    
    //친구 해제 한 번 더 물어보는 알림창
    @Binding var ask_delete_friend_model: Bool
    //삭제하려는 친구 idx
    @Binding var delete_frined_idx: Int
    @State private var show_delete_alert : Bool = false
    
    let img_processor = DownsamplingImageProcessor(size:CGSize(width: 44.86, height: 44.86))
        |> RoundCornerImageProcessor(cornerRadius: 25)
    
    var body: some View{
        
        HStack{
            user_img
            
            user_nickname
            
            interest_btn
            Spacer()

            Button(action: {
                self.show_delete_alert = true

            }){
                HStack{
                    Spacer()
                    Image("context_menu_icon")
                        .resizable()
                        .frame(width: 3.52, height: 15.16)
                }
            }
            .frame(width: UIScreen.main.bounds.width*0.2)
            .padding(.trailing, UIScreen.main.bounds.width/40)
        }
        .padding()
        .actionSheet(isPresented: self.$show_delete_alert, content: {
            ActionSheet(title: Text("\(friend_model.nickname!)"), message: Text(""), buttons: [ActionSheet.Button.default(Text("그룹에 추가"), action: {
                
                //선택한 친구의 idx를 manage_viewmodel에 저장해 나중에 그룹에 추가하는 통신시 사용
                self.manage_viewmodel.selected_friend_idx = self.friend_model.idx!
                print("추가하려는 친구 idx 저장 확인 : \(self.manage_viewmodel.selected_friend_idx)")
                self.show_group_list_modal.toggle()
            }), ActionSheet.Button.default(Text("친구 삭제"), action: {
                
                print("친구 삭제하기 클릭: \(friend_model.idx!)")
                self.delete_frined_idx = friend_model.idx!
                
                //삭제 여부 확인 알림창 한 번 더 띄운 후 삭제 통신 진행
                self.ask_delete_friend_model = true
                
                //추가한 후 통신 결과에 따라 alert창 띄우기 위함
            manage_viewmodel.show_ok_alert(manage_viewmodel.active_friend_group_alert)
            }), ActionSheet.Button.cancel(Text("취소"))])
        })
    }
}

extension ManageFriendRow{
    var user_img : some View{
        
        HStack{
        //프로필 사진은 의무가 아니므로 프로필 사진이 없는 경우 추가
        if friend_model.profile_photo == nil || friend_model.profile_photo == ""{
            
            ZStack(alignment: .bottomTrailing){
                Image("main_profile_img")
                    .resizable()
                    .frame(width: 44.86, height: 44.86)
                
                Rectangle()
                    .foregroundColor(friend_model.state == 0 ? Color.gray : Color.proco_green)
                .frame(width: 12.57, height: 12.57)
                    .clipShape(Circle())
                    .overlay(Circle()
                                .strokeBorder(Color.proco_white, lineWidth: 1)
                    )
            }
            
        }else{
            
            ZStack(alignment: .bottomTrailing){
                
                KFImage(URL(string: friend_model.profile_photo!))
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
                
                Rectangle()
                    .foregroundColor(friend_model.state == 0 ? Color.gray : Color.proco_green)
                .frame(width: 12.57, height: 12.57)
                    .clipShape(Circle())
                    .overlay(Circle()
                                .strokeBorder(Color.proco_white, lineWidth: 1)
                    )
                }
            }
        }
    }
     
    var user_nickname : some View{
        Text(friend_model.nickname!)
            .font(.custom(Font.n_bold, size: 16))
            .foregroundColor(Color.proco_black)
    }
    
    var interest_btn : some View{
        //관심친구 여부
        Button(action: {
            print("관심친구 버튼 클릭: \(self.friend_model.kinds)")
            
            if self.friend_model.kinds == "관심친구"{
                
                self.manage_viewmodel.set_interest_friend(f_idx: friend_model.idx!, action: "관심친구해제")
                
            }else{
                self.manage_viewmodel.set_interest_friend(f_idx: friend_model.idx!, action: "관심친구")
            }
            
        }){
            
            Image(friend_model.kinds == "관심친구" ? "star_fill" : "star")
                .resizable()
                .frame(width: 11.41, height: 10.95)
        }
        .onReceive( NotificationCenter.default.publisher(for: Notification.set_interest_friend)){value in
                
                if let user_info = value.userInfo, let data = user_info["set_interest_friend"]{
                    print("친구 관심친구 설정 노티 받았음: \(value)")
                             
                    if data as! String == "set_ok_관심친구"{
                        let friend_idx = user_info["friend_idx"] as! String
                        
                        if friend_model.idx! == Int(friend_idx){
                            self.friend_model.kinds = "관심친구"
                                              }
                    }else if data as! String == "set_ok_관심친구해제"{
                        let friend_idx = user_info["friend_idx"] as! String
                        if friend_model.idx! == Int(friend_idx){
                            self.friend_model.kinds = "관심친구해제"
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
