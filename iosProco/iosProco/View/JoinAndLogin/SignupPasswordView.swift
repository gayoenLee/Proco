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
    @ObservedObject var info_viewmodel : SignupViewModel
    
    //비밀번호 정규식 틀렸을 경우 알림 보여주기 위해 사용하는 구분값
    @State private var show_pwd_form_wrong = false
    //첫번째, 두번째 비밀번호가 다를 경우 경고 문구 보여줄 때 사용할 구분값
    @State private var show_pwd_diff = false
    //모든 조건이 충족될 경우 true로 바뀌는 값
    @State private var all_is_ok : Bool = false
    //경고 알림에 띄울 텍스트값
    @State private var first_alert_msg_txt : String = "비밀번호를 입력해주세요"
    @State private var second_alert_msg_txt : String = ""
    @State  var first_pwd = ""
    @State  var second_pwd = ""
    
    //다음 회원가입 단계로 이동
    @State private var go_next_step: Bool = false
    
    func validator_password(_ mypassword: String) -> Bool {
        if mypassword.count > 100 {
            return false
        }
        //비밀번호(숫자, 문자, 특수문자 모두 포함 8-18자)
        let passsword_format = ("(?=.*[A-Za-z])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$!%*?&].{8,20}$")
        let password_predicate = NSPredicate(format: "SELF MATCHES %@", passsword_format)
        return password_predicate.evaluate(with: mypassword)
    }
    
    func check_pwd_same(first_pwd : String, second_pwd: String) -> Bool{
        if first_pwd == second_pwd{
            return true
        }else{
            return false
        }
    }

    var body: some View {
        NavigationView{
            VStack(alignment: .leading){
            top_nav_bar
                .padding(.bottom)
           
            
            
                //비밀번호 형식에 맞지 않을 경우 메시지가 나타나는 곳.
                Section(footer:
                
                            first_wrong_pwd_guide_txt
                ) {
                    
                    first_pwd_input_field
                }
                .padding(.bottom)
            
            
                //비밀번호 형식에 맞지 않을 경우 메시지가 나타나는 곳.
                Section(footer:
                
                            second_wrong_pwd_guide_txt
                ) {
                    
                    second_pwd_input_field
                }
          

            Spacer()
            //프로필 사진, 닉네임 입력 페이지로 이동
            NavigationLink("",
                           destination: SignupProfileView(info_viewmodel: self.info_viewmodel), isActive: self.$go_next_step)
                
                Button(action: {
                    print("다음 버튼 클릭 : 모든 결과값 - \(self.all_is_ok),비밀번호 일치 결과값: \(self.show_pwd_diff)")
                    //뷰모델에 비밀번호 저장
                    self.info_viewmodel.password = self.second_pwd
                    self.go_next_step = true
                }){
                next_btn_txt
                }
            .padding(.bottom, UIScreen.main.bounds.width/25)
            //이메일과 패스워드가 형식에 맞지 않을 경우 다음 버튼 활성화 안시킴.
            .disabled(all_is_ok == false)
        }
        
        .onAppear{
            print("비밀번호 입력 페이지 나타남")
            self.show_pwd_form_wrong = true
        }
        .onDisappear{

        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_second")
                         .resizable()
                         .scaledToFill())
        }
        
    }
}

extension SignupPasswordView{
    
    var top_nav_bar: some View{
        HStack(alignment: .center){
                Button(action: {
                    self.presentation.wrappedValue.dismiss()
                }){
                Image("left")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width/20, height: UIScreen.main.bounds.width/20)
                }
                .frame(width: 45, height: 45, alignment: .leading)

            Spacer()
        Text("비밀번호 입력")
            .font(.custom(Font.n_extra_bold, size: 20))
            .foregroundColor(Color.proco_black)
            .padding(.trailing)

            Spacer()
        }
        .padding([.trailing])
    }
    
    
    var first_wrong_pwd_guide_txt: some View{
        
        Text(self.first_alert_msg_txt)
                    .foregroundColor(.red)
                    .padding(.leading, UIScreen.main.bounds.width/10)
                    .foregroundColor(Color.proco_red)
                    .font(.custom(Font.n_regular, size: 10))
    }
    
    var second_wrong_pwd_guide_txt: some View{
        
        Text(self.second_alert_msg_txt)
                    .foregroundColor(.red)
                    .padding(.leading, UIScreen.main.bounds.width/10)
                    .foregroundColor(Color.proco_red)
                    .font(.custom(Font.n_regular, size: 10))
    }
    
    var first_pwd_input_field: some View{
        SecureField("비밀번호", text: $first_pwd)
            .keyboardType(.default)
            .textContentType(.newPassword)
            .padding()
            .background(Color.proco_white)
            .cornerRadius(25.0)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            .onChange(of: self.first_pwd, perform: {
                print("비밀번호 on change들어옴: \($0)")
              let is_validate = self.validator_password($0)
                if !is_validate{
                    self.show_pwd_form_wrong = true
                    self.first_alert_msg_txt = "숫자, 대문자 또는 소문자, 특수문자를 포함한 8~20자에 맞게 입력해주세요"
                    self.second_pwd = ""
                }else{
                    
                    self.show_pwd_form_wrong = false
                    self.first_alert_msg_txt = ""
                        
                }
            })
        
    }
    
    var second_pwd_input_field: some View{
        SecureField("비밀번호(확인)", text: $second_pwd, onCommit: {
            print("온 커밋 들어옴: \(self.second_pwd)")
            let is_same = self.check_pwd_same(first_pwd: self.first_pwd, second_pwd: self.second_pwd)
            if !is_same{
                print("첫번째 비번: \(self.first_pwd), 두번째 비번: \(self.second_pwd)")
                self.show_pwd_diff = true
                self.second_alert_msg_txt = "비밀번호가 일치하지 않습니다."
            }else{
                self.second_alert_msg_txt = ""
                self.show_pwd_diff = false
            }
        })
            .keyboardType(.default)
            .textContentType(.newPassword)
            .padding()
            .background(Color.proco_white)
            .cornerRadius(25.0)
            .shadow(color: .gray, radius: 2, x: 0, y: 2)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
            .onChange(of: self.second_pwd, perform: {
                print("두번째 비밀번호 on change들어옴: \($0)")
                
                let is_same = self.check_pwd_same(first_pwd: self.first_pwd, second_pwd: self.second_pwd)
                if !is_same{
                    print("첫번째 비번: \(self.first_pwd), 두번째 비번: \(self.second_pwd)")
                    self.show_pwd_diff = true
                    self.second_alert_msg_txt = "비밀번호가 일치하지 않습니다."
                    self.all_is_ok = false
                    
                }else {
                    self.second_alert_msg_txt = ""
                    self.show_pwd_diff = false
                    if self.show_pwd_form_wrong == false && self.show_pwd_diff == false{
                        self.all_is_ok = true
                    }
                }
            })
            
    }
    
    var next_btn_txt: some View{
        Text("다음")
            .font(.custom(Font.t_extra_bold, size: 15))
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.proco_white)
            .background(self.all_is_ok == false ? Color.light_gray : Color.proco_black)
            .cornerRadius(25)
            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
    }
    
}
