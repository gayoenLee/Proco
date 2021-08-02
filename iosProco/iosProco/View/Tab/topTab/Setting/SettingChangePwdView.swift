//
//  SettingChangePwdView.swift
//  proco
//
//  Created by 이은호 on 2021/03/22.
//

import SwiftUI


struct SettingChangePwdView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var main_vm : SettingViewModel
    @StateObject private var vm =  CheckValidatorViewModel()
    
    var body: some View {
        VStack{

        Form{

            Section(header: Text("현재 비밀번호").foregroundColor(Color.proco_black),footer: Text(vm.current_pwd_msg).foregroundColor(.red)) {
              
                SecureField("현재 비밀번호", text: $vm.current_pwd)
                    .keyboardType(.default)
            }.listRowBackground(Color.light_gray)
              
            Section(header: Text("새로운 비밀번호").foregroundColor(Color.proco_black),footer: Text(vm.passwordMessage).foregroundColor(.red)) {
                
              SecureField("새로운 비밀번호", text: $vm.new_pwd)
              SecureField("새로운 비밀번호(확인)", text: $vm.new_pwd_again)
            }.listRowBackground(Color.light_gray)
        
        }
            Spacer()
            Button(action: {
              print("버튼 클릭 isvalid확인: \(vm.isValid)")
              
              //비밀번호 변경 통신
              self.vm.setting_change_pwd(current_password: vm.current_pwd, new_password: vm.new_pwd)
              //통신 후 알림창 띄우는 메소드 등록
              self.vm.request_result_alert_func(vm.request_result_alert)
              
            }) {
              
              Text("완료")
                  .font(.custom(Font.t_extra_bold, size: 15))
                  .frame(minWidth: 0, maxWidth: .infinity)
                  .padding()
                  .foregroundColor(.proco_white)
                  .background(self.vm.isValid ? Color.main_orange : Color.gray)
                  .cornerRadius(25)
                .padding([.leading, .trailing, .bottom], UIScreen.main.bounds.width/20)
                  
            }.disabled(!self.vm.isValid)
            .padding(.bottom)
            .alert(isPresented: $vm.show_result_alert){
              switch vm.request_result_alert{
              case .ok:
                  return Alert(title: Text("비밀번호 변경"), message: Text("비밀번호 변경이 완료됐습니다."), dismissButton: Alert.Button.default(Text("확인"), action: {
                      //계정관리 페이지로 이동시키기.
                    self.presentation.wrappedValue.dismiss()
                  }))
              case .wrong:
                  return Alert(title: Text("비밀번호 변경"), message: Text("비밀번호를 다시 확인해주세요"), dismissButton: Alert.Button.default(Text("확인"), action: {
                      //비밀번호 텍스트값들 초기화시키기.
                      self.vm.new_pwd = ""
                      self.vm.new_pwd_again = ""
                      self.vm.current_pwd = ""
                  }))
              }
            }
        }
        .onAppear{
            self.vm.new_pwd = ""
            self.vm.new_pwd_again = ""
            self.vm.current_pwd = ""
            UITableView.appearance().backgroundColor = .clear
        }
        .background(Color.clear)
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("비밀번호 변경")
        
    }
}

