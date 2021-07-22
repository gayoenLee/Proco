//
//  change_password_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
//

import Foundation
import SwiftUI
import Alamofire
import Combine


struct ChangePasswordView: View {
    @ObservedObject var info_viewmodel :  SignupViewModel
    @Environment(\.presentationMode) var presentation
    
    //비밀번호 변경 통신 결과에 따라 alert창 띄우기

    @State private var password_change_result :Bool = false
    @State private var result_message : String = ""
    @State private var go_main : Bool = false
    //새로운 비밀번호 입력이 잘못됐을 경우
    var body: some View{
        VStack{
            HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                    
                }){
                    Image("left")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width/15, height: UIScreen.main.bounds.width/15)
                }
                Spacer()
                Text("비밀번호 재설정")
                    .font(.custom(Font.n_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            
            VStack(alignment: .leading){
                VStack(alignment: .leading){
                    //비밀번호 형식에 맞지 않을 경우 메시지가 나타나는 곳.
                    Section(footer: Text(info_viewmodel.password_message)
                                .padding(.leading, UIScreen.main.bounds.width/10)
                                .foregroundColor(Color.proco_red)
                                .font(.custom(Font.n_regular, size: 10)))
                    {
                        
                        SecureField("새로운 비밀번호 입력", text: $info_viewmodel.change_pwd)
                            .keyboardType(.default)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color.proco_white)
                            .cornerRadius(25.0)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding( UIScreen.main.bounds.width/20)
                        
                        SecureField("새로운 비밀번호(확인)", text: $info_viewmodel.change_pwd_again)
                            .keyboardType(.default)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color.proco_white)
                            .cornerRadius(25.0)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.width/5)
            }
            Spacer()
            NavigationLink("",
                destination: NormalLoginView(view_router: ViewRouter())
                .navigationBarTitle("", displayMode: .inline)
                            .navigationBarHidden(true), isActive: $go_main)
            
            Button(action:{
                change_pwd()
                print("이메일 패스워드 이동하는 네비게이션 링크 클릭")
            }){
                Text("변경")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(info_viewmodel.password_message == "" ? Color.proco_black : Color.gray)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
            .disabled(!(info_viewmodel.password_message == ""))
            .padding(.bottom, UIScreen.main.bounds.width/20)
             
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_first")
                        .resizable()
                        .scaledToFill())
        .alert(isPresented: $password_change_result){
            if self.result_message == "비밀번호가 변경되었습니다."{
                return  Alert(title: Text("비밀번호 변경"), message: Text(result_message), dismissButton: Alert.Button.default(Text("확인"), action: {
                    self.go_main.toggle()
                    
                }))
                
            }
            else{
                return Alert(title: Text("비밀번호 변경"), message: Text(result_message), dismissButton: .default(Text("확인")))
            }
        }
    
    }
    //navigation view 끝
    
    func change_pwd(){
        APIClient.change_password_api(password: info_viewmodel.change_pwd, phone_num: info_viewmodel.phone_number, auth_num: info_viewmodel.auth_num, completion: {
            result in
            if result.exists(){
                print("비밀번호 변경 결과 확인 : \(result)")
                let result_string = result["result"].string
                
                if (result_string == "ok"){
                    self.result_message = "비밀번호가 변경되었습니다."
                    self.password_change_result.toggle()
                    
                }else{
                    self.result_message = "요청을 처리하는데 문제가 발생했습니다."
                    self.password_change_result.toggle()
                   
                }
            }
            else{
                self.result_message = "요청을 처리하는데 문제가 발생했습니다."
                self.password_change_result.toggle()
            }
        })
    }
}
