//
//  find_id_password_view.swift
//  iosProco
//
//  Created by 이은호 on 2020/11/09.
//

import Foundation
import SwiftUI

struct FindIdPasswordView: View{
    
    @Environment(\.presentationMode) var presentation
    
    //핸드폰 번호 맞는지 체크, 값 저장하기 위함.
    @StateObject var phone_viewmodel = SignupViewModel()
    
    //인증번호 틀렸을 경우 경고 문구 나타내기 위한 구분값
    @State var show_warn = true
    //인증번호 요청 통신에 따라 alert창 나타내기 위한 변수
    @State private var auth_send_result : Bool = false
    @State private var result_message : String = ""
    //핸드폰 번호 형식 맞는지 구분 변수
    @State private var is_phone_number_valid: Bool = false
    //인증번호 맞는지 체크
    @State private var is_auth_number_result: Bool = false
    //인증 확인 결과 alert창 나타내기 위한 변수
    @State private var auth_result_message: alert_message? = nil
    //인증 alert창에 메세지 구분값 주기 위한 변수
    @State private var auth_result: String = ""
    
    //인증번호 통신 과정에서 에러가 발생한 경우 alert창 띄우기 위함
    @State private var phone_auth_error :Bool = false
    
    //+82선택창 다이얼로그 띄우기 위한 변수
    @State private var selection = 0
    let location_numbers = ["+82", "+81"]
    
    @Binding var root_is_active : Bool
    
    var body: some View{
        NavigationView{
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
                Text("아이디/비밀번호 찾기")
                    .font(.custom(Font.n_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            
            VStack{
                HStack{
                    Text("+82").padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    
                    TextField("휴대폰 번호", text: self.$phone_viewmodel.phone_number)
            } .keyboardType(.phonePad)
                .padding()
                .background(Color.proco_white)
                .cornerRadius(25.0)
                .shadow(color: .gray, radius: 2, x: 0, y: 2)
                .padding([.leading, .trailing, .top], UIScreen.main.bounds.width/20)
                
                HStack{
                    Spacer()
                    Button(action:{
                        send_phone_auth()
                    }){
                        Image(self.phone_viewmodel.phone_is_valid ? "verify_active_btn" : "verify_inactive_btn")
                            .resizable()
                            .frame(width: 82, height: 33)
                    }
                    .disabled(!self.phone_viewmodel.phone_is_valid)
                    .padding(.trailing, UIScreen.main.bounds.width/25)
                }
            }
            
            VStack(alignment: .leading){
                //self를 붙여서 회원가입 정보 저장하는 클래스에 데이터 저장.
                TextField("인증번호 6자리", text: self.$phone_viewmodel.auth_num)
                    .padding()
                    .background(Color.proco_white)
                    .cornerRadius(25.0)
                    .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    .padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    .keyboardType(.phonePad)
                    
                
                //핸드폰 번호 양식에 알맞지 않을 경우 나타나는 경고 문구
                if !self.is_auth_number_result{
                    if auth_result == "invalid"{
                        Text("잘못된 인증번호 입니다")
                            .font(.custom(Font.n_regular, size: 10))
                            .foregroundColor(Color.proco_red)
                            .padding([.leading])
                    }
                    else if auth_result == "auth_result"{
                        Text("이미 인증번호를 보냈습니다.")
                            .font(.custom(Font.n_regular, size: 10))
                            .foregroundColor(Color.proco_red)
                            .padding([.leading])
                        
                    }
                    else{
                        

                    }
                }
                Spacer()
                HStack{
                    //다음 버튼 클릭시 인증번호 서버로 보내서 맞는지 확인하고 맞아야 이동 가능, self붙여야 데이터를 그대로 담아서 보낼 수 있음.
                    NavigationLink("",destination: ChangePasswordView(info_viewmodel: self.phone_viewmodel, root_is_active: self.$root_is_active)   .navigationBarTitle("", displayMode: .inline)
                                    .navigationBarHidden(true), isActive: $is_auth_number_result)
                        //완료 버튼 누른 후 로그인 페이지로 이동시키기 위함
                        .isDetailLink(false)
                    Button(action:{
                        check_phone_auth()
                        print("이메일 패스워드 이동하는 네비게이션 링크 클릭")
                    }){
                        Text("확인")
                            .font(.custom(Font.t_extra_bold, size: 15))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.proco_white)
                            //인증번호가 6자리이고 전화번호 형식이 맞을때만 활성화
                            .background(self.phone_viewmodel.auth_num.count == 6 && (self.phone_viewmodel.phone_is_valid) ? Color.proco_black : Color.gray)
                            .cornerRadius(25)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                    }
                    .disabled(!(self.phone_viewmodel.auth_num.count == 6) && !(self.phone_viewmodel.phone_is_valid))
                    .padding(.trailing, UIScreen.main.bounds.width/25)
                    
                    

                    //뷰가 사라질 때 값 저장하기
                    .onDisappear{
                        print("핸드폰 확인 : \(self.phone_viewmodel.phone_number)")
                    }
                }.padding(.bottom, UIScreen.main.bounds.width/20)
            }
            //큰 vstack끝
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background( Image("signup_first")
                        .resizable()
                        .scaledToFill())
        //body끝
        //핸드폰 인증때 서버 통신 과정에서 알 수 없는 오류가 발생한 경우 띄우는 창

        .alert(isPresented: $auth_send_result){
            Alert(title: Text(result_message), dismissButton: .default(Text("확인")))
        }
        }
    }
    //view 끝
    func send_phone_auth(){
        APIClient.find_id_pwd_phone_auth(phone_num: self.phone_viewmodel.phone_number, type: "miss_pwd", completion: {result in
            if result.exists(){
                print("핸드폰 인증 뷰에서 \(result)")
                let result_string = result["result"].string
                //이미 인증된 사람일 경우 alert창으로 알리기
                switch result_string {
                case "message sended":
                    self.result_message = "인증번호가 전송되었습니다."
                    break
                case "already send auth message" :
                    self.result_message = "이미 인증요청을 보냈습니다."
                    break
                case "message send error" :
                    self.result_message = "요청을 처리하는데 문제가 발생했습니다."
                    break
                case "no user phone_num":
                    self.result_message = "존재하지 않는 회원입니다."
                    break
                default :
                    self.result_message = "알수 없는 응답 또는 에러"
                    break
                }
                self.auth_send_result.toggle()
            }
        })
        
    }
    
    func check_phone_auth(){
        APIClient.check_phone_auth_api(phone_num: self.phone_viewmodel.phone_number, auth_num: self.phone_viewmodel.auth_num ,type: "confirm", completion: {result in
            
            //로그에 json으로 나옴
            print("핸드폰 인증뷰에서 \(result)")
            
            if result.exists(){
                
                let result_string = result["result"].string
                switch result_string {
                case "invalid auth number":
                    auth_result = "invalid"
                    break
                case "no user phone_num":
                    auth_result = "no user phone_num"
                    break
                case "ok":
                    auth_result = "ok"
                    is_auth_number_result = true
                    break
                default:
                    auth_result = "error"
                    break
                }

            }else{
                print("핸드폰 인증 뷰에서 \(Error.self)")
                self.result_message = "요청을 처리하는데 문제가 발생하였습니다."
                auth_send_result.toggle()
                
            }
        })
    }
}

//인증요청 alert창 위한 struct
struct Message: Identifiable {
    let id = UUID()
    let text: String
}
