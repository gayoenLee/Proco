//
//  VerifyEmailView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import SwiftUI

struct VerifyEmailView: View {
    
    @ObservedObject var main_vm: SettingViewModel
    @State private var is_email_valid: Bool = true
    
    var body: some View {
        VStack{
            Text("더 안전한 계정 이용을 위해 2단계 인증을 등록해 주세요")
                .font(.system(size: 10))
            //이메일 인증을 완료한 경우
            if main_vm.email_sent == "ok"{
           
                Text("이메일 인증이 완료된 계정입니다.")
                
            }else{
                //이메일 입력 필드
                email_textfield
                HStack{
                    Button(action: {
                        print("인증메일 발송")
                        //이메일 인증 요청 통신
                        main_vm.verify_email(email: main_vm.email_value)
                        //이메일 인증 요청 후 alert창
                        main_vm.email_result_alert_func(main_vm.email_result_alert)
                        
                    }){
                        Text("인증메일 발송")
                    }
                    .alert(isPresented: $main_vm.show_email_result_alert){
                        switch main_vm.email_result_alert{
                        case .send:
                            return Alert(title: Text("이메일 인증"), message: Text("인증메일이 발송됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                                main_vm.email_sent = "sent"
                            }))
                        case .error:
                            return Alert(title: Text("이메일 인증"), message: Text("인증을 다시 시도해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                                main_vm.email_sent = ""
                                
                            }))
                        case .already_send:
                            return  Alert(title: Text("이메일 인증"), message: Text("이미 인증메일이 발송됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {            main_vm.email_sent = "sent"
                                
                            }))
                        case .verified:
                            return  Alert(title: Text("이메일 인증"), message: Text("이메일이 인증이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                                
                                main_vm.email_sent = "ok"
                                
                            }))
                        }
                    }
                    Spacer()
                }
            }
        }
        .onAppear{
            print("이메일 인증 페이지 나타남.")
            //이메일 인증 메일을 요청한 상태 && 아래 통신에서 ok가 오면 인증 완료로 뷰 보여주기
          //  if self.main_vm.email_sent == "sent"{
                print("인증 메일을 요청한 후인 경우")
                main_vm.check_verify_email()
           // }
        }
    }
}

private extension VerifyEmailView{
    
    var email_textfield: some View{
        VStack{
            if !self.is_email_valid{
                
                Text("이메일 형식에 맞게 작성해주세요")
                    .foregroundColor(Color.red)
                    .font(.system(size: 10, weight: .bold))
            }
            HStack{
                Text("이메일")
                TextField("", text: $main_vm.email_value, onEditingChanged: {(is_changed) in
                    //이메일 형식 체크 위한 메소드
                    if !is_changed{
                        if main_vm.validator_email(main_vm.email_value){
                            self.is_email_valid = true
                        }else{
                            self.is_email_valid = false
                            self.main_vm.email_value = ""
                        }
                    }
                })  .keyboardType(.emailAddress)
                .padding([.top, .bottom], UIScreen.main.bounds.width*1/8)
            }
        }
    }
    
    
    
}
