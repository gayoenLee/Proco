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
    @State private var change_success : Bool = false
    @State private var change_failed : Bool = false
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
                        
                        SecureField("새로운 비밀번호 입력", text: $info_viewmodel.password)
                            .keyboardType(.default)
                            .textContentType(.newPassword)
                            .padding()
                            .background(Color.proco_white)
                            .cornerRadius(25.0)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding( UIScreen.main.bounds.width/20)
                        
                        SecureField("새로운 비밀번호(확인)", text: $info_viewmodel.password_again)
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
            NavigationLink(
                destination: NormalLoginView(view_router: ViewRouter())){
                Text("변경")
                    .font(.custom(Font.t_extra_bold, size: 15))
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.proco_white)
                    .background(Color.proco_black)
                    .cornerRadius(25)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
            }
            .padding(.bottom, UIScreen.main.bounds.width/20)
            //이 부분 디버깅시 주석 풀 것. 디자인 적용한 것 보느라 주석처리함.
            // .disabled(!info_viewmodel.password_valid)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_first")
                        .resizable()
                        .scaledToFill())
        .alert(isPresented: $change_success){
            Alert(title: Text("비밀번호 변경"), message: Text("비밀번호가 변경됐습니다."), dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $change_failed){
            Alert(title: Text("비밀번호 변경"), message: Text("비밀번호가 변경에 실패했습니다."), dismissButton: .default(Text("확인")))
        }
    }
    //navigation view 끝
    
    func change_pwd(){
        APIClient.change_password_api(password: info_viewmodel.password, phone_num: info_viewmodel.phone_number, auth_num: info_viewmodel.auth_num, completion: {
            result in
            if result.exists(){
                print("비밀번호 변경 결과 확인 : \(result)")
                let result_string = result["result"].string
                if (result_string == "ok"){
                    self.change_success = true
                    
                }else{
                    print("비밀번호 변경 통신은 성공했지만 result ok 아님 : \(result)")
                    self.change_failed.toggle()
                }
            }
            else{
                print("비밀번호 변경 통신 오류 발생 : \(result) ")
                self.change_failed.toggle()
                
            }
        })
    }
}

