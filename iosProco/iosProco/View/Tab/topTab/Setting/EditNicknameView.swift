//
//  EditNicknameView.swift
//  proco
//
//  Created by 이은호 on 2021/06/01.
//

import SwiftUI

struct EditNicknameView: View {
    
    @Binding var open_view : Bool
    @Binding var nickname : String
    @ObservedObject var main_vm : SettingViewModel
    //닉네임 변경 실패시 알림창 띄우기
    @State private var show_fail_alert: Bool = false
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    self.open_view = false
                }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                Spacer()
                Text("닉네임 변경")
                    .font(.custom(Font.n_extra_bold, size: 16))
                    .foregroundColor(Color.proco_black)
        Spacer()
            }
            .padding()
            
            HStack{
                Spacer()
                Text("\(self.nickname.count)/10")
                    .font(.custom(Font.n_extra_bold, size: 12))
                    .foregroundColor(Color.gray)
            }
            .padding()
            
            TextField("", text: self.$nickname, onEditingChanged: {(is_changed) in
                if self.nickname.count > 10{
                    self.nickname = String(self.nickname.prefix(10))
                }
            })
            .padding()
            
            Divider()
                .frame(width: UIScreen.main.bounds.width*0.9, height: 2, alignment: .center)
                .foregroundColor(Color.proco_black)
                
            Spacer()
            
            Button(action: {
                
                print("수정 버튼 클릭 닉네임: \(self.nickname)")
                self.main_vm.edit_user_info(gender: 0, birthday: "", nickname: self.nickname)
                
            }){
                Text("수정")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(Color.main_orange)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
            .padding()
            .alert(isPresented: self.$show_fail_alert){
                Alert(title: Text("알림"), message: Text("다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인")))
            }
            
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.move_view), perform: {value in
            
            if let user_info = value.userInfo, let data = user_info["nickname_change"]{
                print("닉네임 변경 노티 \(data)")
                
                if data as! String == "ok"{
                    //창 닫기
                    self.open_view = false
                    
                }else {
                    print("닉네임 변경 노티 fail옴")
                    self.show_fail_alert = true
                }
            }else{
                print("설정에서 변경한 알림 아님")
            }
        })
        .onAppear{
            
        }
    }
}

