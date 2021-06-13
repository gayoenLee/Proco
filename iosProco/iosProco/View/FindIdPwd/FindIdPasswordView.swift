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
    @ObservedObject var phone_viewmodel = SignupViewModel()
    
    //인증번호 틀렸을 경우 경고 문구 나타내기 위한 구분값
    @State var show_warn = true
    //인증번호 요청 통신에 따라 alert창 나타내기 위한 변수
    @State private var message_sended : Bool = false
    @State private var message_failed : Bool = false
    //핸드폰 번호 형식 맞는지 구분 변수
    @State private var is_phone_number_valid: Bool = true
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
                Text("아이디/비밀번호 찾기")
                    .font(.custom(Font.n_extra_bold, size: 20))
                    .foregroundColor(Color.proco_black)
                Spacer()
            }
            .padding()
            
            VStack{
                HStack{
                    Text("+82").padding([.leading, .trailing], UIScreen.main.bounds.width/20)
                    
                    TextField("휴대폰 번호", text: self.$phone_viewmodel.phone_number, onEditingChanged: {(is_changed)in
                        if !is_changed{
                            //phone_viewmodel에 있는 정규식 체크 메소드를 사용해 핸드폰 번호 양식 확인함.
                            if self.phone_viewmodel.validator_phonenumber(self.phone_viewmodel.phone_number){
                                self.is_phone_number_valid = true
                                print("저장된 핸드폰 번호 확인 : \(self.phone_viewmodel.phone_number)")
                                
                            }else{
                                self.is_phone_number_valid = false
                                self.phone_viewmodel.phone_number = ""
                            }
                        }
                    })
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
                        Image("verify_active_btn")
                            .resizable()
                            .frame(width: 82, height: 33)
                    }
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
                
                //핸드폰 번호 양식에 알맞지 않을 경우 나타나는 경고 문구
                if self.is_auth_number_result{
                    if auth_result == "invalid"{
                        Text("잘못된 인증번호 입니다")
                            .font(.custom(Font.n_regular, size: 10))
                            .foregroundColor(Color.proco_red)
                    }else{
                        Text("이미 인증된 번호입니다")
                            .font(.custom(Font.n_regular, size: 10))
                            .foregroundColor(Color.proco_red)
                    }
                }
                Spacer()
                HStack{
                    //다음 버튼 클릭시 인증번호 서버로 보내서 맞는지 확인하고 맞아야 이동 가능, self붙여야 데이터를 그대로 담아서 보낼 수 있음.
                    NavigationLink(destination: ChangePasswordView(info_viewmodel: self.phone_viewmodel)   .navigationBarTitle("", displayMode: .inline)
                                    .navigationBarHidden(true), isActive: $is_auth_number_result){
                        
                        Text("확인")
                            .font(.custom(Font.t_extra_bold, size: 15))
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.proco_white)
                            .background(Color.proco_black)
                            .cornerRadius(25)
                            .padding([.leading, .trailing], UIScreen.main.bounds.width/25)
                        
                    }.simultaneousGesture(TapGesture().onEnded{
                        check_phone_auth()
                        print("이메일 패스워드 이동하는 네비게이션 링크 클릭")
                    })
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
        .alert(isPresented: $phone_auth_error){
            Alert(title: Text(""), message: Text("인증요청을 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $message_sended){
            Alert(title: Text("인증번호가 전송됐습니다."), dismissButton: .default(Text("확인")))
        }
        .alert(isPresented: $message_failed){
            Alert(title: Text("인증번호 전송에 실패했습니다. 다시 시도해주세요"), dismissButton: .default(Text("확인")))
        }
    }
    //view 끝
    func send_phone_auth(){
        APIClient.find_id_pwd_phone_auth(phone_num: self.phone_viewmodel.phone_number, type: "miss_pwd", completion: {result in
            if result.exists(){
                print("핸드폰 인증  뷰에서 \(result)")
                let result_string = result["result"].string
                //이미 인증된 사람일 경우 alert창으로 알리기
                if(result_string == "message_sended"){
                    self.message_sended.toggle()
                    //응답 : 인증문자 전송됨 : message sended
                }else{
                    self.message_failed.toggle()
                }
            }
        })
        
    }
    
    func check_phone_auth(){
        APIClient.check_phone_auth_api(phone_num: self.phone_viewmodel.phone_number, auth_num: self.phone_viewmodel.auth_num ,type: "confirm", completion: {result in
            
            //로그에 json으로 나옴
            print("핸드폰 인증뷰에서 \(result)")
            
            if result.exists(){
                is_auth_number_result = true
                let result_string = result["result"].string
                //만약 인증번호가 일치한다는 결과일 경우
                if (result_string ==  "invalid auth number"){
                    //뷰모델에도 데이터 저장
                    auth_result = "ok"
                    //인증번호가 일치하지 않을 경우
                }
                else if result_string == "invalid auth num"{
                    phone_viewmodel.phone_auth_ok = false
                    auth_result = "invalid"
                }
                //통신에 실패한 경우
            }else{
                print("핸드폰 인증 뷰에서 \(Error.self)")
                phone_auth_error.toggle()
                
            }
        })
    }
}

//인증요청 alert창 위한 struct
struct Message: Identifiable {
    let id = UUID()
    let text: String
}

