//
//  SignupPasswordView.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/10.
//

import SwiftUI

struct SignupPasswordView: View {
    @Environment(\.presentationMode) var presentation

    //회원가입시 유저의 정보를 담을 모델 클래스
    @ObservedObject var info_viewmodel :  SignupViewModel
    //이메일 형식 체크를 위한 변수
    @State private var is_email_valid: Bool = true
    
    //아이디, 비밀번호 잘못 입력시 경고 문구 나타내기 위해 주는 구분 값
    @State var show_warn = true
    
    var body: some View {
        VStack{
            top_nav_bar
           
            Spacer()
            VStack(alignment: .leading){
                //비밀번호 형식에 맞지 않을 경우 메시지가 나타나는 곳.
                Section(footer:
                            wrong_pwd_guide_txt
                ) {
                    
                    first_pwd_input_field
                    second_pwd_input_field
                }
            }
            .padding(.bottom, UIScreen.main.bounds.width/5)
            Spacer()
            //프로필 사진, 닉네임 입력 페이지로 이동
            NavigationLink(
                destination: SignupProfileView(info_viewmodel: self.info_viewmodel)){
                next_btn_txt
            }
            .navigationBarTitle("")
            .padding(.bottom, UIScreen.main.bounds.width/25)
            
            //이메일과 패스워드가 형식에 맞지 않을 경우 다음 버튼 활성화 안시킴.
            .disabled(!info_viewmodel.email_password_valid)
            
            Spacer()
        }
        .onDisappear{
            //뷰가 사라질 때 비밀번호 저장하기
            print("이메일 페스워드 페이지에서 핸드폰 번호 확인 : \(info_viewmodel.phone_number)")
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_second")
                         .resizable()
                         .scaledToFill())
    }
}

extension SignupPasswordView{
    
    var top_nav_bar: some View{
        HStack{
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
            Spacer()
        Text("비밀번호 입력")
            .font(.custom(Font.n_extra_bold, size: 20))
            .foregroundColor(Color.proco_black)
            Spacer()
        }
        .padding()
    }
    
    var wrong_pwd_guide_txt: some View{
        Text(info_viewmodel.password_message)
                    .foregroundColor(.red)
                    .padding(.leading, UIScreen.main.bounds.width/10)
                    .foregroundColor(Color.proco_red)
                    .font(.custom(Font.n_regular, size: 10))
    }
    
    var first_pwd_input_field: some View{
        SecureField("비밀번호", text: $info_viewmodel.password)
            .keyboardType(.default)
            .textContentType(.newPassword)
            .padding()
            .background(Color.proco_white)
            .cornerRadius(25.0)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/20)
        
    }
    
    var second_pwd_input_field: some View{
        SecureField("비밀번호(확인)", text: $info_viewmodel.password_again)
            .keyboardType(.default)
            .textContentType(.newPassword)
            .padding()
            .background(Color.proco_white)
            .cornerRadius(25.0)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
    }
    
    var next_btn_txt: some View{
        Text("다음")
            .font(.custom(Font.t_extra_bold, size: 15))
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.proco_white)
            .background(info_viewmodel.email_password_valid ? Color.proco_black : Color.light_gray)
            .cornerRadius(25)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
    }
    
}

